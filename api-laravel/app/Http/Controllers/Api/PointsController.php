<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PointTransaction;
use App\Services\PointService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PointsController extends Controller
{
    public function __construct(private readonly PointService $points) {}

    public function balance(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');
        $tier = $this->points->syncUserTier($user->id);

        return response()->json([
            'balance' => $this->points->getBalance($user->id),
            'tier' => $tier,
            'rate' => $this->points->getRateForTier($tier),
            'public_id' => $user->public_id,
        ]);
    }

    public function history(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        $history = PointTransaction::query()
            ->where('user_id', $user->id)
            ->orderByDesc('id')
            ->limit(50)
            ->get(['id', 'amount', 'type', 'reference_id', 'balance_after', 'created_at']);

        return response()->json(['history' => $history]);
    }

    public function earn(Request $request): JsonResponse
    {
        $data = $request->validate([
            'action' => ['required', 'string'],
            'idempotent_key' => ['nullable', 'string', 'max:120'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->points->earnPoints(
                $user->id,
                $data['action'],
                $data['idempotent_key'] ?? null,
            );
        } catch (\RuntimeException $e) {
            $map = [
                'INVALID_ACTION' => 400,
                'ALREADY_CLAIMED_TODAY' => 409,
            ];

            return response()->json(
                ['error' => $e->getMessage()],
                $map[$e->getMessage()] ?? 500,
            );
        }

        return response()->json([
            'balance' => $result['balance'],
            'earned' => $result['duplicate'] ? 0 : null,
            'duplicate' => $result['duplicate'],
        ]);
    }
}
