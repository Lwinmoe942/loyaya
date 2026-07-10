<?php

use App\Http\Controllers\AdminPanelController;
use App\Http\Controllers\ExchangeController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json(['ok' => true, 'service' => 'lotaya-shwe-oh-api']);
});

Route::get('/', function () {
    return redirect()->route('exchange.index');
});

Route::get('/join', function () {
    $ref = request('ref');
    $appName = 'Lotaya Dinga';

    return response()->view('join', [
        'ref' => $ref,
        'appName' => $appName,
    ]);
})->name('join');

Route::get('/exchange', [ExchangeController::class, 'index'])->name('exchange.index');
Route::post('/exchange', [ExchangeController::class, 'submit'])->name('exchange.submit');
Route::get('/exchange/status', [ExchangeController::class, 'status'])->name('exchange.status.form');
Route::post('/exchange/status', [ExchangeController::class, 'statusCheck'])->name('exchange.status.check');

Route::get('/robots.txt', function () {
    $base = rtrim(config('app.url') ?: url('/'), '/');
    $content = "User-agent: *\n";
    $content .= "Allow: /\n";
    $content .= "Disallow: /api/\n";
    $content .= "Disallow: /admin\n";
    $content .= "Sitemap: {$base}/sitemap.xml\n";

    return response($content, 200)->header('Content-Type', 'text/plain');
});

Route::get('/sitemap.xml', function () {
    $base = rtrim(config('app.url') ?: url('/'), '/');
    $urls = [
        "{$base}/",
        "{$base}/exchange",
        "{$base}/exchange/status",
        "{$base}/health",
    ];

    $xml = '<?xml version="1.0" encoding="UTF-8"?>';
    $xml .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
    foreach ($urls as $u) {
        $xml .= '<url><loc>'.e($u).'</loc><changefreq>daily</changefreq><priority>0.8</priority></url>';
    }
    $xml .= '</urlset>';

    return response($xml, 200)->header('Content-Type', 'application/xml');
});

$adminPath = trim((string) config('lotaya.admin_panel_path', 'admin'), '/');

Route::middleware('admin.access')->prefix($adminPath)->name('admin.')->group(function () {
    Route::get('/', [AdminPanelController::class, 'loginForm'])->name('login');
    Route::post('/login', [AdminPanelController::class, 'login'])
        ->middleware('throttle:5,1')
        ->name('login.submit');
    Route::post('/logout', [AdminPanelController::class, 'logout'])->name('logout');

    Route::middleware('admin.session')->group(function () {
        Route::get('/dashboard', [AdminPanelController::class, 'dashboard'])->name('dashboard');
        Route::get('/withdraws', [AdminPanelController::class, 'withdraws'])->name('withdraws');
        Route::get('/gift-codes', [AdminPanelController::class, 'giftCodes'])->name('gift-codes');
        Route::post('/gift-codes', [AdminPanelController::class, 'createGiftCodes'])->name('gift-codes.create');
        Route::post('/withdraws/{id}/approve', [AdminPanelController::class, 'approve'])->name('withdraws.approve');
        Route::post('/withdraws/{id}/reject', [AdminPanelController::class, 'reject'])->name('withdraws.reject');
    });
});
