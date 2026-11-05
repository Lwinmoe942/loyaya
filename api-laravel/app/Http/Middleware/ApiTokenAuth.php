<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Services\UserPresenter;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiTokenAuth
{
    public function __construct(private readonly UserPresenter $presenter) {}

    public function handle(Request $request, Closure $next): Response
    {
        $header = $request->header('Authorization', '');
        $token = str_starts_with($header, 'Bearer ') ? substr($header, 7) : null;

        if (! $token) {
            return response()->json(['error' => 'UNAUTHORIZED'], 401);
        }

        $user = User::query()->where('api_token', $token)->first();
        if (! $user) {
            return response()->json(['error' => 'UNAUTHORIZED'], 401);
        }

        $deviceId = trim((string) $request->header('X-Device-Id', ''));
        if ($deviceId !== '' && (strlen($deviceId) < 8 || strlen($deviceId) > 80)) {
            return response()->json(['error' => 'DEVICE_REQUIRED'], 400);
        }

        // Bind first device for legacy accounts; reject any other phone after that.
        if ($user->device_id) {
            if ($deviceId === '' || ! hash_equals((string) $user->device_id, $deviceId)) {
                return response()->json(['error' => 'DEVICE_MISMATCH'], 403);
            }
        } elseif ($deviceId !== '') {
            $user->forceFill([
                'device_id' => $deviceId,
                'device_bound_at' => now(),
            ])->save();
        }

        $request->attributes->set('auth_user', $user->fresh());
        $request->attributes->set('auth_token', $token);
        $request->attributes->set('auth_user_payload', $this->presenter->format($user->fresh()));

        return $next($request);
    }
}
