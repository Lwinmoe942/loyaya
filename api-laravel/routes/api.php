<?php

use App\Http\Controllers\Api\AdminWithdrawController;
use App\Http\Controllers\Api\AiController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CatalogController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\GamesController;
use App\Http\Controllers\Api\GiftCodeController;
use App\Http\Controllers\Api\LeaderboardController;
use App\Http\Controllers\Api\ReferralController;
use App\Http\Controllers\Api\WithdrawController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::get('/leaderboard', [LeaderboardController::class, 'index']);
Route::get('/content/tutorials', [CatalogController::class, 'tutorials']);
Route::get('/content/classroom', [CatalogController::class, 'classroom']);
Route::get('/content/watch', [CatalogController::class, 'watchVideos']);

Route::middleware('api.token')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::get('/points/balance', [PointsController::class, 'balance']);
    Route::get('/points/history', [PointsController::class, 'history']);
    Route::post('/points/earn', [PointsController::class, 'earn']);
    Route::get('/content/locks', [ContentController::class, 'locks']);
    Route::post('/content/fail', [ContentController::class, 'fail']);
    Route::post('/gift/redeem', [GiftCodeController::class, 'redeem']);
    Route::get('/games/status', [GamesController::class, 'status']);
    Route::post('/games/scratch', [GamesController::class, 'scratch']);
    Route::post('/games/spin', [GamesController::class, 'spin']);
    Route::post('/games/tic-tac-toe', [GamesController::class, 'ticTacToe']);
    Route::post('/games/tic-tac-toe/loss', [GamesController::class, 'ticTacToeLoss']);
    Route::post('/games/tic-tac-toe/bonus', [GamesController::class, 'ticTacToeBonus']);
    Route::get('/ai/history', [AiController::class, 'history']);
    Route::post('/ai/estimate', [AiController::class, 'estimate']);
    Route::post('/ai/record-to-text', [AiController::class, 'recordToText']);
    Route::post('/ai/text-to-voice', [AiController::class, 'textToVoice']);
    Route::get('/referral/status', [ReferralController::class, 'status']);
    Route::post('/referral/apply', [ReferralController::class, 'apply']);
});

Route::post('/withdraw/request', [WithdrawController::class, 'request']);
Route::get('/withdraw/status', [WithdrawController::class, 'status']);

Route::middleware(['admin.access', 'admin.key'])->prefix('admin')->group(function () {
    Route::get('/withdraws', [AdminWithdrawController::class, 'index']);
    Route::post('/withdraws/{id}/approve', [AdminWithdrawController::class, 'approve']);
    Route::post('/withdraws/{id}/reject', [AdminWithdrawController::class, 'reject']);
});
