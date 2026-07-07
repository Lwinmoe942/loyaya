<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminApiKey
{
    public function handle(Request $request, Closure $next): Response
    {
        $key = $request->header('X-Admin-Key');
        $expected = config('lotaya.admin_api_key');

        if (! $key || ! $expected || ! hash_equals($expected, $key)) {
            return response()->json(['error' => 'FORBIDDEN'], 403);
        }

        return $next($request);
    }
}
