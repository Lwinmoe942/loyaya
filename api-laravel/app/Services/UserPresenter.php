<?php

namespace App\Services;

use App\Models\User;

class UserPresenter
{
    public function __construct(private readonly PointService $points) {}

    public function format(User $user): array
    {
        $tier = $this->points->syncUserTier($user->id);
        $balance = $this->points->getBalance($user->id);

        return [
            'id' => $user->id,
            'public_id' => $user->public_id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'tier' => $tier,
            'rate' => $this->points->getRateForTier($tier),
            'balance' => $balance,
            'created_at' => $user->created_at?->toIso8601String(),
        ];
    }
}
