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

Route::get('/admin', [AdminPanelController::class, 'loginForm'])->name('admin.login');
Route::post('/admin/login', [AdminPanelController::class, 'login'])->name('admin.login.submit');
Route::post('/admin/logout', [AdminPanelController::class, 'logout'])->name('admin.logout');

Route::middleware('admin.session')->prefix('admin')->group(function () {
    Route::get('/withdraws', [AdminPanelController::class, 'withdraws'])->name('admin.withdraws');
    Route::post('/withdraws/{id}/approve', [AdminPanelController::class, 'approve'])->name('admin.withdraws.approve');
    Route::post('/withdraws/{id}/reject', [AdminPanelController::class, 'reject'])->name('admin.withdraws.reject');
});
