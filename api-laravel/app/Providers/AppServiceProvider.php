<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (config('app.env') === 'production') {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        // Keep generated URLs on the configured public domain (custom domain),
        // not the temporary *.up.railway.app hostname.
        $appUrl = rtrim((string) config('app.url'), '/');
        if ($appUrl !== '' && str_starts_with($appUrl, 'http')) {
            \Illuminate\Support\Facades\URL::forceRootUrl($appUrl);
        }
    }
}
