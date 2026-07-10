<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\PointService;
use App\Services\UserPresenter;
use App\Support\PublicId;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function __construct(
        private readonly PointService $points,
        private readonly UserPresenter $presenter,
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

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $request->attributes->get('auth_user_payload'),
            'token' => $request->attributes->get('auth_token'),
        ]);
    }
}
