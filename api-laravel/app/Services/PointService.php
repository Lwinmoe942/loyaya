<?php

namespace App\Services;

use App\Models\PointTransaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class PointService
{
    public function getBalance(int $userId): int
    {
        return (int) PointTransaction::query()
            ->where('user_id', $userId)
            ->sum('amount');
    }

    public function getLifetimePoints(int $userId): int
    {
        return (int) PointTransaction::query()
            ->where('user_id', $userId)
            ->where('amount', '>', 0)
            ->sum('amount');
    }

    public function getRateForTier(string $tier): int
    {
        $rates = config('lotaya.rates', []);

        return (int) ($rates[$tier] ?? $rates['bronze'] ?? 3);
    }

    public function syncUserTier(int $userId): string
    {
        $lifetime = $this->getLifetimePoints($userId);
        $tier = $this->resolveTier($lifetime);

        User::query()->whereKey($userId)->update(['tier' => $tier]);

        return $tier;
    }

    public function earnPoints(int $userId, string $action, ?string $idempotentKey = null): array
    {
        $rules = config('lotaya.earn_rules', []);
        $rule = $rules[$action] ?? null;

        if (! $rule) {
            throw new \RuntimeException('INVALID_ACTION');
        }

        $key = $idempotentKey;
        if (! empty($rule['daily'])) {
            $key = "earn_{$action}_{$userId}_".now()->toDateString();
        } elseif (! $key) {
            $key = "earn_{$action}_{$userId}_".now()->timestamp;
        }

        $result = $this->addTransaction($userId, (int) $rule['points'], "earn_{$action}", $action, $key);

        if ($result['duplicate'] && ! empty($rule['daily'])) {
            throw new \RuntimeException('ALREADY_CLAIMED_TODAY');
        }

        return $result;
    }

    public function lockWithdrawPoints(int $userId, int $points, int $withdrawId): array
    {
        return $this->addTransaction(
            $userId,
            -$points,
            'withdraw_lock',
            (string) $withdrawId,
            "withdraw_lock_{$withdrawId}",
        );
    }

    public function refundWithdrawPoints(int $userId, int $points, int $withdrawId): array
    {
        return $this->addTransaction(
            $userId,
            $points,
            'withdraw_refund',
            (string) $withdrawId,
            "withdraw_refund_{$withdrawId}",
        );
    }

    public function validateWithdrawAmount(int $points): void
    {
        $min = (int) config('lotaya.min_withdraw_points', 500);
        $step = (int) config('lotaya.withdraw_step', 500);

        if ($points < $min) {
            throw new \RuntimeException('BELOW_MINIMUM');
        }

        if ($points % $step !== 0) {
            throw new \RuntimeException('INVALID_STEP');
        }
    }

    public function addTransaction(
        int $userId,
        int $amount,
        string $type,
        ?string $referenceId = null,
        ?string $idempotentKey = null,
    ): array {
        return DB::transaction(function () use ($userId, $amount, $type, $referenceId, $idempotentKey) {
            if ($idempotentKey) {
                $existing = PointTransaction::query()
                    ->where('idempotent_key', $idempotentKey)
                    ->first();

                if ($existing) {
                    return [
                        'duplicate' => true,
                        'balance' => $this->getBalance($userId),
                    ];
                }
            }

            $balance = $this->getBalance($userId);
            $newBalance = $balance + $amount;

            if ($newBalance < 0) {
                throw new \RuntimeException('INSUFFICIENT_POINTS');
            }

            PointTransaction::query()->create([
                'user_id' => $userId,
                'amount' => $amount,
                'type' => $type,
                'reference_id' => $referenceId,
                'balance_after' => $newBalance,
                'idempotent_key' => $idempotentKey,
                'created_at' => now(),
            ]);

            $this->syncUserTier($userId);

            return [
                'duplicate' => false,
                'balance' => $newBalance,
            ];
        });
    }

    private function resolveTier(int $lifetimePoints): string
    {
        foreach (config('lotaya.tier_thresholds', []) as $item) {
            if ($lifetimePoints >= (int) $item['min']) {
                return $item['tier'];
            }
        }

        return 'bronze';
    }
}
