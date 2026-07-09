<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\GiftCodeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GiftCodeController extends Controller
{
    public function __construct(private readonly GiftCodeService $gifts) {}

    public function redeem(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:32'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->gifts->redeem($user->id, $data['code']);
        } catch (\RuntimeException $e) {
            $map = [
                'INVALID_CODE' => 404,
                'EXPIRED' => 410,
                'MAX_USES' => 409,
                'ALREADY_REDEEMED' => 409,
            ];

            return response()->json(
                ['error' => $e->getMessage()],
                $map[$e->getMessage()] ?? 400,
            );
        }

        return response()->json([
            'points' => $result['points'],
            'balance' => $result['balance'],
            'message' => "Gift code redeemed! +{$result['points']} points.",
        ]);
    }
}
