<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\GameService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GamesController extends Controller
{
    public function __construct(private readonly GameService $games) {}

    public function status(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        return response()->json([
            'scratch_cooldown_seconds' => $this->games->scratchCooldownSeconds($user->id),
            'scratch_available' => $this->games->scratchCooldownSeconds($user->id) === 0,
            'spin_played_today' => $this->games->spinPlayedToday($user->id),
        ]);
    }

    public function scratch(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->games->playScratch($user->id);
        } catch (\RuntimeException $e) {
            return response()->json(
                ['error' => $e->getMessage()],
                $e->getMessage() === 'SCRATCH_COOLDOWN' ? 429 : 400,
            );
        }

        return response()->json([
            'points' => $result['points'],
            'balance' => $result['balance'],
            'message' => "You won {$result['points']} points!",
        ]);
    }

    public function spin(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->games->playSpin($user->id);
        } catch (\RuntimeException $e) {
            return response()->json(
                ['error' => $e->getMessage()],
                $e->getMessage() === 'ALREADY_PLAYED_TODAY' ? 409 : 400,
            );
        }

        return response()->json([
            'points' => $result['points'],
            'segment' => $result['segment'],
            'balance' => $result['balance'],
            'message' => "Spin result: {$result['segment']}",
        ]);
    }

    public function ticTacToe(Request $request): JsonResponse
    {
        $data = $request->validate([
            'match_id' => ['required', 'string', 'max:80'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->games->ticTacToeWin($user->id, $data['match_id']);
        } catch (\RuntimeException $e) {
            $code = match ($e->getMessage()) {
                'DAILY_LIMIT' => 429,
                'ALREADY_CLAIMED' => 409,
                default => 400,
            };

            return response()->json(['error' => $e->getMessage()], $code);
        }

        return response()->json([
            'points' => $result['points'],
            'balance' => $result['balance'],
            'message' => 'You won +1 point!',
        ]);
    }

    public function ticTacToeBonus(Request $request): JsonResponse
    {
        $data = $request->validate([
            'match_id' => ['required', 'string', 'max:80'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->games->ticTacToeBonus($user->id, $data['match_id']);
        } catch (\RuntimeException $e) {
            return response()->json(
                ['error' => $e->getMessage()],
                $e->getMessage() === 'ALREADY_CLAIMED' ? 409 : 400,
            );
        }

        return response()->json([
            'points' => $result['points'],
            'balance' => $result['balance'],
            'message' => 'Bonus +1 point claimed!',
        ]);
    }
}
