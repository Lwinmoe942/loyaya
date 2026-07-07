<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\WithdrawRequest;
use App\Services\PointService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WithdrawController extends Controller
{
    public function __construct(private readonly PointService $points) {}

    public function request(Request $request): JsonResponse
    {
        $data = $request->validate([
            'public_id' => ['required', 'string', 'max:20'],
            'name' => ['nullable', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190'],
            'points' => ['required', 'integer'],
            'payment_method' => ['required', 'string', 'max:30'],
            'payment_phone' => ['required', 'string', 'max:30'],
        ]);

        try {
            $this->points->validateWithdrawAmount((int) $data['points']);
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }

        $user = User::query()->where('public_id', $data['public_id'])->first();
        if (! $user) {
            return response()->json(['error' => 'USER_NOT_FOUND'], 404);
        }

        $points = (int) $data['points'];
        $balance = $this->points->getBalance($user->id);
        if ($balance < $points) {
            return response()->json(['error' => 'INSUFFICIENT_POINTS'], 400);
        }

        $tier = $this->points->syncUserTier($user->id);
        $rate = $this->points->getRateForTier($tier);
        $mmkAmount = $points * $rate;

        $withdraw = WithdrawRequest::query()->create([
            'user_id' => $user->id,
            'points' => $points,
            'mmk_amount' => $mmkAmount,
            'rate' => $rate,
            'payment_method' => $data['payment_method'],
            'payment_phone' => $data['payment_phone'],
            'email' => strtolower($data['email']),
            'status' => 'pending',
        ]);

        $this->points->lockWithdrawPoints($user->id, $points, $withdraw->id);

        return response()->json([
            'request_id' => $withdraw->id,
            'status' => 'pending',
            'points' => $points,
            'mmk_amount' => $mmkAmount,
            'rate' => $rate,
            'message' => 'Withdraw request submitted. Points locked.',
        ], 201);
    }

    public function status(Request $request): JsonResponse
    {
        $email = strtolower(trim((string) $request->query('email', '')));
        if ($email === '') {
            return response()->json(['error' => 'VALIDATION_ERROR'], 400);
        }

        $requests = WithdrawRequest::query()
            ->where('email', $email)
            ->orderByDesc('id')
            ->limit(20)
            ->get([
                'id',
                'points',
                'mmk_amount',
                'rate',
                'payment_method',
                'status',
                'created_at',
                'updated_at',
            ]);

        return response()->json(['requests' => $requests]);
    }
}
