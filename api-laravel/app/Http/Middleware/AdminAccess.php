<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminAccess
{
    public function handle(Request $request, Closure $next): Response
    {
        $allowedIps = config('lotaya.admin_allowed_ips', []);

        if ($allowedIps !== []) {
            $clientIp = $request->ip();
            if (! in_array($clientIp, $allowedIps, true)) {
                abort(404);
            }
        }

        return $next($request);
    }
}
