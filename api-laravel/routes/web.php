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

Route::get('/exchange', [ExchangeController::class, 'index'])->name('exchange.index');
Route::post('/exchange', [ExchangeController::class, 'submit'])->name('exchange.submit');
Route::get('/exchange/status', [ExchangeController::class, 'statusForm'])->name('exchange.status.form');
Route::post('/exchange/status', [ExchangeController::class, 'statusCheck'])->name('exchange.status.check');

$adminPath = trim((string) config('lotaya.admin_panel_path', 'admin'), '/');

Route::middleware('admin.access')->prefix($adminPath)->name('admin.')->group(function () {
    Route::get('/', [AdminPanelController::class, 'loginForm'])->name('login');
    Route::post('/login', [AdminPanelController::class, 'login'])
        ->middleware('throttle:5,1')
        ->name('login.submit');
    Route::post('/logout', [AdminPanelController::class, 'logout'])->name('logout');

    Route::middleware('admin.session')->group(function () {
        Route::get('/withdraws', [AdminPanelController::class, 'withdraws'])->name('withdraws');
        Route::post('/withdraws/{id}/approve', [AdminPanelController::class, 'approve'])->name('withdraws.approve');
        Route::post('/withdraws/{id}/reject', [AdminPanelController::class, 'reject'])->name('withdraws.reject');
    });
});
