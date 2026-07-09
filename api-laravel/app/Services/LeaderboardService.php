<?php

namespace App\Services;

use App\Models\PointTransaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class LeaderboardService
{
    /** @return list<array{rank: int, name: string, email_masked: string, score: int, tier: string}> */
    public function topByLifetimePoints(int $limit = 50): array
    {
        $rows = PointTransaction::query()
            ->select('user_id', DB::raw('SUM(amount) as lifetime'))
            ->where('amount', '>', 0)
            ->groupBy('user_id')
            ->orderByDesc('lifetime')
            ->limit($limit)
            ->get();

        if ($rows->isEmpty()) {
            return [];
        }

        $users = User::query()
            ->whereIn('id', $rows->pluck('user_id'))
            ->get(['id', 'name', 'email', 'tier'])
            ->keyBy('id');

        $result = [];
        $rank = 1;

        foreach ($rows as $row) {
            $user = $users->get($row->user_id);
            if (! $user) {
                continue;
            }

            $result[] = [
                'rank' => $rank++,
                'name' => $user->name ?: 'User',
                'email_masked' => $this->maskEmail($user->email),
                'score' => (int) $row->lifetime,
                'tier' => $user->tier ?? 'bronze',
            ];
        }

        return $result;
    }

    private function maskEmail(string $email): string
    {
        $parts = explode('@', $email, 2);
        if (count($parts) !== 2) {
            return '***';
        }

        [$local, $domain] = $parts;
        $localMask = strlen($local) <= 2
            ? substr($local, 0, 1).'*'
            : substr($local, 0, 2).'**';
        $domainParts = explode('.', $domain);
        $domainMask = strlen($domainParts[0]) <= 1
            ? '*'
            : substr($domainParts[0], 0, 1).'**';

        return $localMask.'@'.$domainMask;
    }
}
