<?php

use App\Http\Controllers\Api\AdminWithdrawController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PointsController;
use App\Http\Controllers\Api\WithdrawController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::middleware('api.token')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::get('/points/balance', [PointsController::class, 'balance']);
    Route::get('/points/history', [PointsController::class, 'history']);
    Route::post('/points/earn', [PointsController::class, 'earn']);
});

Route::post('/withdraw/request', [WithdrawController::class, 'request']);
Route::get('/withdraw/status', [WithdrawController::class, 'status']);

Route::middleware('admin.key')->prefix('admin')->group(function () {
    Route::get('/withdraws', [AdminWithdrawController::class, 'index']);
    Route::post('/withdraws/{id}/approve', [AdminWithdrawController::class, 'approve']);
    Route::post('/withdraws/{id}/reject', [AdminWithdrawController::class, 'reject']);
});
