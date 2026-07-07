<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WithdrawRequest;
use App\Services\PointService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminWithdrawController extends Controller
{
    public function __construct(private readonly PointService $points) {}

    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status', 'pending');

        $requests = WithdrawRequest::query()
            ->with('user:id,public_id,name,tier')
            ->where('status', $status)
            ->orderBy('id')
            ->limit(100)
            ->get()
            ->map(function (WithdrawRequest $row) {
                return [
                    'id' => $row->id,
                    'user_id' => $row->user_id,
                    'points' => $row->points,
                    'mmk_amount' => $row->mmk_amount,
                    'rate' => $row->rate,
                    'payment_method' => $row->payment_method,
                    'payment_phone' => $row->payment_phone,
                    'email' => $row->email,
                    'status' => $row->status,
                    'created_at' => $row->created_at,
                    'updated_at' => $row->updated_at,
                    'public_id' => $row->user?->public_id,
                    'user_name' => $row->user?->name,
                    'tier' => $row->user?->tier,
                ];
            });

        return response()->json(['requests' => $requests]);
    }

    public function approve(int $id): JsonResponse
    {
        $row = WithdrawRequest::query()->find($id);
        if (! $row) {
            return response()->json(['error' => 'NOT_FOUND'], 404);
        }

        if ($row->status !== 'pending') {
            return response()->json(['error' => 'ALREADY_PROCESSED'], 409);
        }

        $row->update(['status' => 'approved']);

        return response()->json(['ok' => true, 'status' => 'approved']);
    }

    public function reject(int $id): JsonResponse
    {
        $row = WithdrawRequest::query()->find($id);
        if (! $row) {
            return response()->json(['error' => 'NOT_FOUND'], 404);
        }

        if ($row->status !== 'pending') {
            return response()->json(['error' => 'ALREADY_PROCESSED'], 409);
        }

        $this->points->refundWithdrawPoints($row->user_id, $row->points, $row->id);
        $row->update(['status' => 'rejected']);

        return response()->json(['ok' => true, 'status' => 'rejected']);
    }
}
