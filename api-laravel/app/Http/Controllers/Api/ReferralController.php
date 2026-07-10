<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReferralService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReferralController extends Controller
{
    public function __construct(private readonly ReferralService $referrals) {}

    public function status(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        return response()->json($this->referrals->status($user));
    }

    public function apply(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:12'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $this->referrals->applyCode($user, $data['code']);
        } catch (\RuntimeException $e) {
            $code = match ($e->getMessage()) {
                'ALREADY_APPLIED' => 409,
                'SELF_REFERRAL' => 422,
                default => 400,
            };

            return response()->json(['error' => $e->getMessage()], $code);
        }

        return response()->json([
            'message' => 'Invite code applied successfully!',
            'status' => $this->referrals->status($user->fresh()),
        ]);
    }
}
