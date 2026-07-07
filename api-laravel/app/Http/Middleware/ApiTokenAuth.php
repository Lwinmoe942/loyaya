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

        $request->attributes->set('auth_user', $user);
        $request->attributes->set('auth_token', $token);
        $request->attributes->set('auth_user_payload', $this->presenter->format($user));

        return $next($request);
    }
}
