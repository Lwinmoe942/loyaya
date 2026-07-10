<?php

namespace App\Services;

use App\Models\PointTransaction;

class GameService
{
    private const GAME_COOLDOWN_MINUTES = 5;

    public function __construct(private readonly PointService $points) {}

    /** @return array{points: int, balance: int, duplicate: bool} */
    public function playScratch(int $userId): array
    {
        if ($this->scratchCooldownSeconds($userId) > 0) {
            throw new \RuntimeException('SCRATCH_COOLDOWN');
        }

        $key = 'scratch_'.$userId.'_'.now()->timestamp;

        $prizes = [2, 2, 2, 3, 3, 5];
        $points = $prizes[array_rand($prizes)];

        $result = $this->points->addTransaction(
            $userId,
            $points,
            'earn_scratch',
            'scratch',
            $key,
        );

        return [
            'points' => $points,
            'balance' => $result['balance'],
            'duplicate' => $result['duplicate'],
        ];
    }

    /** @return array{points: int, balance: int, duplicate: bool, segment: string} */
    public function playSpin(int $userId): array
    {
        $key = 'spin_wheel_'.$userId.'_'.now()->toDateString();

        if ($this->hasIdempotentKey($key)) {
            throw new \RuntimeException('ALREADY_PLAYED_TODAY');
        }

        $segments = [
            ['label' => '1 pt', 'points' => 1],
            ['label' => '2 pts', 'points' => 2],
            ['label' => '2 pts', 'points' => 2],
            ['label' => '3 pts', 'points' => 3],
            ['label' => '3 pts', 'points' => 3],
            ['label' => '5 pts', 'points' => 5],
        ];
        $pick = $segments[array_rand($segments)];
        $points = (int) $pick['points'];

        $result = $this->points->addTransaction(
            $userId,
            $points,
            'earn_spin_wheel',
            'spin_wheel',
            $key,
        );

        return [
            'points' => $points,
            'segment' => $pick['label'],
            'balance' => $result['balance'],
            'duplicate' => $result['duplicate'],
        ];
    }

    /** @return array{points: int, balance: int, duplicate: bool} */
    public function ticTacToeWin(int $userId, string $matchId): array
    {
        $matchId = $this->normalizeMatchId($matchId);
        $key = 'ttt_win_'.$userId.'_'.$matchId;

        if ($this->ticTacToeCooldownSeconds($userId) > 0) {
            throw new \RuntimeException('TIC_TAC_TOE_COOLDOWN');
        }

        $result = $this->points->addTransaction(
            $userId,
            1,
            'earn_tic_tac_toe',
            $matchId,
            $key,
        );

        if ($result['duplicate']) {
            throw new \RuntimeException('ALREADY_CLAIMED');
        }

        return [
            'points' => 1,
            'balance' => $result['balance'],
            'duplicate' => false,
        ];
    }

    /** @return array{points: int, balance: int, duplicate: bool} */
    public function ticTacToeBonus(int $userId, string $matchId): array
    {
        $matchId = $this->normalizeMatchId($matchId);
        $key = 'ttt_bonus_'.$userId.'_'.$matchId;

        $result = $this->points->addTransaction(
            $userId,
            1,
            'earn_tic_tac_toe_bonus',
            $matchId,
            $key,
        );

        if ($result['duplicate']) {
            throw new \RuntimeException('ALREADY_CLAIMED');
        }

        return [
            'points' => 1,
            'balance' => $result['balance'],
            'duplicate' => false,
        ];
    }

    public function scratchCooldownSeconds(int $userId): int
    {
        return $this->cooldownSeconds($userId, 'earn_scratch');
    }

    public function ticTacToeCooldownSeconds(int $userId): int
    {
        return $this->cooldownSeconds($userId, 'earn_tic_tac_toe');
    }

    public function spinPlayedToday(int $userId): bool
    {
        return $this->hasIdempotentKey('spin_wheel_'.$userId.'_'.now()->toDateString());
    }

    private function cooldownSeconds(int $userId, string $type): int
    {
        $last = PointTransaction::query()
            ->where('user_id', $userId)
            ->where('type', $type)
            ->orderByDesc('created_at')
            ->value('created_at');

        if ($last === null) {
            return 0;
        }

        $availableAt = \Carbon\Carbon::parse($last)->addMinutes(self::GAME_COOLDOWN_MINUTES);
        if (now()->gte($availableAt)) {
            return 0;
        }

        return (int) now()->diffInSeconds($availableAt);
    }

    private function hasIdempotentKey(string $key): bool
    {
        return PointTransaction::query()
            ->where('idempotent_key', $key)
            ->exists();
    }

    private function normalizeMatchId(string $matchId): string
    {
        $matchId = preg_replace('/[^a-zA-Z0-9_-]/', '', $matchId) ?? '';

        if ($matchId === '' || strlen($matchId) > 80) {
            throw new \RuntimeException('INVALID_MATCH');
        }

        return $matchId;
    }
}
