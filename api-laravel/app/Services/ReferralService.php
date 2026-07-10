<?php

namespace App\Services;

use App\Models\PointTransaction;
use App\Models\User;
use Illuminate\Support\Str;

class ReferralService
{
    public function ensureReferralCode(User $user): string
    {
        if ($user->referral_code) {
            return $user->referral_code;
        }

        do {
            $code = strtoupper(Str::random(8));
        } while (User::query()->where('referral_code', $code)->exists());

        $user->update(['referral_code' => $code]);

        return $code;
    }

    /** @return array<string, mixed> */
    public function status(User $user): array
    {
        $code = $this->ensureReferralCode($user);
        $baseUrl = rtrim((string) config('lotaya.app_url', config('app.url')), '/');

        $referredBy = null;
        if ($user->referred_by_user_id) {
            $referrer = User::query()->find($user->referred_by_user_id);
            $referredBy = $referrer?->referral_code;
        }

        $referralCount = User::query()
            ->where('referred_by_user_id', $user->id)
            ->count();

        $bonusEarned = (int) PointTransaction::query()
            ->where('user_id', $user->id)
            ->where('type', 'referral_bonus')
            ->sum('amount');

        return [
            'referral_code' => $code,
            'referral_link' => "{$baseUrl}/join?ref={$code}",
            'invite_applied' => $user->referred_by_user_id !== null,
            'applied_code' => $referredBy,
            'referral_count' => $referralCount,
            'referral_bonus_earned' => $bonusEarned,
        ];
    }

    public function applyCode(User $user, string $code): void
    {
        if ($user->referred_by_user_id) {
            throw new \RuntimeException('ALREADY_APPLIED');
        }

        $code = strtoupper(trim($code));
        if ($code === '' || strlen($code) > 12) {
            throw new \RuntimeException('INVALID_CODE');
        }

        $referrer = User::query()->where('referral_code', $code)->first();
        if (! $referrer) {
            throw new \RuntimeException('INVALID_CODE');
        }

        if ($referrer->id === $user->id) {
            throw new \RuntimeException('SELF_REFERRAL');
        }

        $user->update(['referred_by_user_id' => $referrer->id]);
    }

    public function linkOnRegister(User $user, ?string $code): void
    {
        if ($code === null || trim($code) === '') {
            return;
        }

        try {
            $this->applyCode($user, $code);
        } catch (\RuntimeException $e) {
            if ($e->getMessage() !== 'ALREADY_APPLIED') {
                throw $e;
            }
        }
    }

    public function rewardReferrer(int $earnerUserId, int $earnedPoints, string $sourceKey): void
    {
        if ($earnedPoints <= 0) {
            return;
        }

        $earner = User::query()->find($earnerUserId);
        if (! $earner?->referred_by_user_id) {
            return;
        }

        $bonus = (int) floor($earnedPoints * 0.10);
        if ($bonus < 1) {
            return;
        }

        $referrerId = (int) $earner->referred_by_user_id;
        $key = "referral_bonus_{$referrerId}_{$sourceKey}";

        app(PointService::class)->addTransaction(
            $referrerId,
            $bonus,
            'referral_bonus',
            (string) $earnerUserId,
            $key,
        );
    }
}
