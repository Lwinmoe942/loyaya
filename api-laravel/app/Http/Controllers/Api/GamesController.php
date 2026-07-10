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
            'tic_tac_toe_loss_cooldown_seconds' => $this->games->ticTacToeLossCooldownSeconds($user->id),
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
            'difficulty' => ['required', 'string', 'in:easy,hard,super_hard'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->games->ticTacToeWin(
                $user->id,
                $data['match_id'],
                $data['difficulty'],
            );
        } catch (\RuntimeException $e) {
            $code = match ($e->getMessage()) {
                'TIC_TAC_TOE_LOSS_COOLDOWN' => 429,
                'ALREADY_CLAIMED' => 409,
                default => 400,
            };

            return response()->json(['error' => $e->getMessage()], $code);
        }

        return response()->json([
            'points' => $result['points'],
            'balance' => $result['balance'],
            'message' => "You won +{$result['points']} points!",
        ]);
    }

    public function ticTacToeLoss(Request $request): JsonResponse
    {
        $data = $request->validate([
            'match_id' => ['required', 'string', 'max:80'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->games->recordTicTacToeLoss($user->id, $data['match_id']);
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }

        return response()->json($result);
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
