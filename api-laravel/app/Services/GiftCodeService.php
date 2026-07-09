<?php

namespace App\Services;

use App\Models\GiftCode;
use App\Models\GiftCodeRedemption;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class GiftCodeService
{
    public function __construct(private readonly PointService $points) {}

    public function redeem(int $userId, string $rawCode): array
    {
        $code = strtoupper(trim($rawCode));

        return DB::transaction(function () use ($userId, $code) {
            $gift = GiftCode::query()
                ->where('code', $code)
                ->lockForUpdate()
                ->first();

            if (! $gift) {
                throw new \RuntimeException('INVALID_CODE');
            }

            if ($gift->expires_at && $gift->expires_at->isPast()) {
                throw new \RuntimeException('EXPIRED');
            }

            if ($gift->uses_count >= $gift->max_uses) {
                throw new \RuntimeException('MAX_USES');
            }

            $already = GiftCodeRedemption::query()
                ->where('gift_code_id', $gift->id)
                ->where('user_id', $userId)
                ->exists();

            if ($already) {
                throw new \RuntimeException('ALREADY_REDEEMED');
            }

            GiftCodeRedemption::query()->create([
                'gift_code_id' => $gift->id,
                'user_id' => $userId,
                'created_at' => now(),
            ]);

            $gift->increment('uses_count');

            $result = $this->points->addTransaction(
                $userId,
                $gift->points,
                'gift_redeem',
                $gift->code,
                "gift_redeem_{$gift->id}_{$userId}",
            );

            return [
                'points' => $gift->points,
                'balance' => $result['balance'],
                'duplicate' => $result['duplicate'],
            ];
        });
    }

    /** @return list<string> */
    public function generateBatch(int $points, int $count, int $maxUses = 1, ?\DateTimeInterface $expiresAt = null): array
    {
        $codes = [];

        for ($i = 0; $i < $count; $i++) {
            do {
                $code = 'LSO-'.strtoupper(Str::random(6));
            } while (GiftCode::query()->where('code', $code)->exists());

            GiftCode::query()->create([
                'code' => $code,
                'points' => $points,
                'max_uses' => $maxUses,
                'expires_at' => $expiresAt,
            ]);

            $codes[] = $code;
        }

        return $codes;
    }
}
