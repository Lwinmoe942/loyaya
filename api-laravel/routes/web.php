<?php

use App\Http\Controllers\AdminPanelController;
use App\Http\Controllers\ExchangeController;
use App\Http\Controllers\LegalController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json(['ok' => true, 'service' => 'lotaya-shwe-oh-api']);
});

Route::get('/', [ExchangeController::class, 'index'])->name('home');
Route::get('/lotaya-shwe-oh-withdraw', [ExchangeController::class, 'index'])->name('withdraw.seo');

Route::get('/join', function () {
    $ref = request('ref');
    $appName = 'Lotaya Shwe Oh';

    return response()->view('join', [
        'ref' => $ref,
        'appName' => $appName,
    ]);
})->name('join');

Route::get('/exchange', [ExchangeController::class, 'index'])->name('exchange.index');
Route::post('/exchange', [ExchangeController::class, 'submit'])->name('exchange.submit');
Route::get('/exchange/status', [ExchangeController::class, 'status'])->name('exchange.status.form');
Route::post('/exchange/status', [ExchangeController::class, 'statusCheck'])->name('exchange.status.check');

Route::get('/privacy', [LegalController::class, 'privacy'])->name('privacy');
Route::get('/account-deletion', [LegalController::class, 'accountDeletionForm'])->name('account-deletion');
Route::post('/account-deletion', [LegalController::class, 'accountDeletionSubmit'])
    ->middleware('throttle:5,1')
    ->name('account-deletion.submit');

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
    $today = now()->toDateString();
    $urls = [
        ['loc' => "{$base}/", 'priority' => '1.0'],
        ['loc' => "{$base}/exchange", 'priority' => '1.0'],
        ['loc' => "{$base}/lotaya-shwe-oh-withdraw", 'priority' => '0.95'],
        ['loc' => "{$base}/exchange/status", 'priority' => '0.7'],
        ['loc' => "{$base}/privacy", 'priority' => '0.8'],
        ['loc' => "{$base}/account-deletion", 'priority' => '0.6'],
    ];

    $xml = '<?xml version="1.0" encoding="UTF-8"?>';
    $xml .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
    foreach ($urls as $item) {
        $xml .= '<url>';
        $xml .= '<loc>'.e($item['loc']).'</loc>';
        $xml .= '<lastmod>'.e($today).'</lastmod>';
        $xml .= '<changefreq>daily</changefreq>';
        $xml .= '<priority>'.e($item['priority']).'</priority>';
        $xml .= '</url>';
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
        Route::get('/course-applications', [AdminPanelController::class, 'courseApplications'])->name('course-applications');
        Route::post('/course-applications/{id}/approve', [AdminPanelController::class, 'approveCourseApplication'])->name('course-applications.approve');
        Route::post('/course-applications/{id}/reject', [AdminPanelController::class, 'rejectCourseApplication'])->name('course-applications.reject');
    });
});
