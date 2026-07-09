<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\LeaderboardService;
use Illuminate\Http\JsonResponse;

class LeaderboardController extends Controller
{
    public function __construct(private readonly LeaderboardService $leaderboard) {}

    public function index(): JsonResponse
    {
        return response()->json([
            'rows' => $this->leaderboard->topByLifetimePoints(50),
        ]);
    }
}
