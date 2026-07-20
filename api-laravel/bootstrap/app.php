<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->trustProxies(
            at: '*',
            headers: Request::HEADER_X_FORWARDED_FOR
                | Request::HEADER_X_FORWARDED_HOST
                | Request::HEADER_X_FORWARDED_PORT
                | Request::HEADER_X_FORWARDED_PROTO,
        );

        $middleware->alias([
            'api.token' => \App\Http\Middleware\ApiTokenAuth::class,
            'admin.key' => \App\Http\Middleware\AdminApiKey::class,
            'admin.session' => \App\Http\Middleware\AdminSession::class,
            'admin.access' => \App\Http\Middleware\AdminAccess::class,
            'region.block' => \App\Http\Middleware\BlockMyanmarRegion::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );

        $exceptions->render(function (\Illuminate\Session\TokenMismatchException $e, Request $request) {
            if ($request->is('exchange') || $request->is('exchange/*')) {
                return redirect()
                    ->route('exchange.index')
                    ->with('error', 'Session သက်တမ်းကုန်ပါပြီ။ Page ကို refresh လုပ်ပြီး ထပ်စမ်းပါ။');
            }

            return null;
        });
    })->create();
