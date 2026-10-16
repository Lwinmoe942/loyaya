<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpMailSender;
use App\Services\PointService;
use App\Services\UserPresenter;
use App\Support\PublicId;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;

class AuthController extends Controller
{
    public function __construct(
        private readonly PointService $points,
        private readonly UserPresenter $presenter,
        private readonly OtpMailSender $otpMail,
    ) {}

    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190'],
            'password' => ['required', 'string', 'min:6'],
            'phone' => ['nullable', 'string', 'max:30'],
            'referral_code' => ['nullable', 'string', 'max:12'],
        ]);

        $email = strtolower(trim($data['email']));
        if ($email === '') {
            return response()->json(['error' => 'VALIDATION_ERROR'], 422);
        }

        if (User::query()->whereRaw('LOWER(email) = ?', [$email])->exists()) {
            return response()->json([
                'error' => 'EMAIL_EXISTS',
                'message' => 'This email already has an account. Please sign in.',
            ], 409);
        }

        $token = PublicId::token();
        $user = User::query()->create([
            'public_id' => PublicId::generate(),
            'name' => $data['name'],
            'email' => $email,
            'password' => $data['password'],
            'phone' => $data['phone'] ?? null,
            'tier' => 'bronze',
            'api_token' => $token,
        ]);

        if (! empty($data['referral_code'] ?? null)) {
            try {
                app(\App\Services\ReferralService::class)
                    ->linkOnRegister($user, $data['referral_code']);
            } catch (\RuntimeException) {
                // Invalid referral on sign-up is ignored so registration still succeeds.
            }
        }

        app(\App\Services\ReferralService::class)->ensureReferralCode($user->fresh());

        return response()->json([
            'user' => $this->presenter->format($user),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $email = strtolower(trim($data['email']));
        $user = User::query()->whereRaw('LOWER(email) = ?', [$email])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['error' => 'INVALID_CREDENTIALS'], 401);
        }

        $token = PublicId::token();
        $user->update(['api_token' => $token]);

        return response()->json([
            'user' => $this->presenter->format($user->fresh()),
            'token' => $token,
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email', 'max:190'],
        ]);
        $email = strtolower(trim($data['email']));

        $throttleKey = 'forgot:'.$email.'|'.$request->ip();
        if (RateLimiter::tooManyAttempts($throttleKey, 5)) {
            return response()->json(['error' => 'OTP_RATE_LIMIT'], 429);
        }
        RateLimiter::hit($throttleKey, 3600);

        if (Cache::has('forgot_cd:'.$email)) {
            return response()->json(['error' => 'OTP_COOLDOWN'], 429);
        }

        if (! $this->otpMail->hasHttpMailer()) {
            $mailer = (string) config('mail.default');
            if (in_array($mailer, ['log', 'array'], true)) {
                return response()->json(['error' => 'MAIL_NOT_CONFIGURED'], 503);
            }

            return response()->json(['error' => 'MAIL_API_REQUIRED'], 503);
        }

        $user = User::query()->whereRaw('LOWER(email) = ?', [$email])->first();
        if ($user) {
            $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            DB::table('password_reset_tokens')->updateOrInsert(
                ['email' => $email],
                ['token' => Hash::make($otp), 'created_at' => now()],
            );
            Cache::put('otp_attempts:'.$email, 0, now()->addMinutes(15));

            try {
                $this->otpMail->send($email, $user->name, $otp);
            } catch (\Throwable $e) {
                report($e);

                return response()->json(['error' => self::mailErrorCode($e)], 503);
            }

            Cache::put('forgot_cd:'.$email, true, now()->addSeconds(60));
        }

        return response()->json([
            'ok' => true,
            'message' => 'If this email has an account, an OTP was sent.',
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'otp' => ['required', 'string', 'size:6'],
            'password' => ['required', 'string', 'min:6'],
        ]);
        $email = strtolower(trim($data['email']));
        $otp = preg_replace('/\D+/', '', $data['otp']) ?? '';
        if (strlen($otp) !== 6) {
            return response()->json(['error' => 'INVALID_OTP'], 400);
        }

        $row = DB::table('password_reset_tokens')->where('email', $email)->first();
        if (! $row || empty($row->created_at) || Carbon::parse($row->created_at)->lt(now()->subMinutes(10))) {
            return response()->json(['error' => 'INVALID_OTP'], 400);
        }

        $attempts = (int) Cache::get('otp_attempts:'.$email, 0);
        if ($attempts >= 5) {
            return response()->json(['error' => 'OTP_LOCKED'], 429);
        }

        if (! Hash::check($otp, $row->token)) {
            Cache::put('otp_attempts:'.$email, $attempts + 1, now()->addMinutes(15));

            return response()->json(['error' => 'INVALID_OTP'], 400);
        }

        $user = User::query()->whereRaw('LOWER(email) = ?', [$email])->first();
        if (! $user) {
            return response()->json(['error' => 'INVALID_OTP'], 400);
        }

        $token = PublicId::token();
        $user->update([
            'password' => $data['password'],
            'api_token' => $token,
        ]);

        DB::table('password_reset_tokens')->where('email', $email)->delete();
        Cache::forget('otp_attempts:'.$email);
        Cache::forget('forgot_cd:'.$email);

        return response()->json([
            'ok' => true,
            'user' => $this->presenter->format($user->fresh()),
            'token' => $token,
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $request->attributes->get('auth_user_payload'),
            'token' => $request->attributes->get('auth_token'),
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $data = $request->validate([
            'password' => ['required', 'string'],
        ]);

        /** @var User $user */
        $user = $request->attributes->get('auth_user');
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['error' => 'INVALID_CREDENTIALS'], 401);
        }

        // Null out referrals pointing at this user, then delete (cascades related rows).
        User::query()
            ->where('referred_by_user_id', $user->id)
            ->update(['referred_by_user_id' => null]);

        $user->delete();

        return response()->json([
            'ok' => true,
            'message' => 'Account and associated data deleted.',
        ]);
    }

    private static function mailErrorCode(\Throwable $e): string
    {
        $message = strtolower($e->getMessage());
        if (str_contains($message, '535')
            || str_contains($message, '534')
            || str_contains($message, 'authentica')
            || str_contains($message, 'username and password')) {
            return 'MAIL_AUTH_FAILED';
        }
        if (str_contains($message, 'timed out')
            || str_contains($message, 'connection')
            || str_contains($message, 'network is unreachable')) {
            return 'MAIL_CONNECTION_FAILED';
        }

        return 'MAIL_FAILED';
    }
}
