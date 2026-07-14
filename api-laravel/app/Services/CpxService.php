<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Log;

class CpxService
{
    public function __construct(private readonly PointService $points) {}

    public function buildClientConfig(User $user): array
    {
        $appId = (string) config('lotaya.cpx.app_id', '');
        $secret = (string) config('lotaya.cpx.secure_hash', '');

        if ($appId === '' || $secret === '') {
            throw new \RuntimeException('CPX_NOT_CONFIGURED');
        }

        $userHash = md5($user->public_id.'-'.$secret);

        // email/username help CPX match surveys to the user profile.
        $query = http_build_query([
            'app_id' => $appId,
            'ext_user_id' => $user->public_id,
            'secure_hash' => $userHash,
            'email' => (string) ($user->email ?? ''),
            'username' => (string) ($user->name ?? ''),
        ]);

        return [
            'app_id' => $appId,
            'user_id' => $user->public_id,
            'secure_hash' => $userHash,
            'wall_url' => 'https://offers.cpx-research.com/index.php?'.$query,
            'points_per_survey' => (int) config('lotaya.cpx.points_per_survey', 2),
        ];
    }

    public function isAllowedIp(?string $ip): bool
    {
        $allowed = config('lotaya.cpx.allowed_ips', []);
        if ($allowed === []) {
            return true;
        }

        if ($ip === null || $ip === '') {
            return false;
        }

        return in_array($ip, $allowed, true);
    }

    public function verifyPostbackHash(string $transId, string $hash): bool
    {
        $secret = (string) config('lotaya.cpx.secure_hash', '');
        if ($transId === '' || $hash === '' || $secret === '') {
            return false;
        }

        $expected = md5($transId.'-'.$secret);

        return hash_equals($expected, $hash);
    }

    public function handlePostback(array $params): array
    {
        $status = (int) ($params['status'] ?? 0);
        $transId = trim((string) ($params['trans_id'] ?? ''));
        $userPublicId = trim((string) ($params['user_id'] ?? ''));
        $secureHash = trim((string) ($params['secure_hash'] ?? $params['hash'] ?? ''));

        if ($transId === '' || $userPublicId === '') {
            throw new \RuntimeException('MISSING_PARAMS');
        }

        if (! $this->verifyPostbackHash($transId, $secureHash)) {
            throw new \RuntimeException('INVALID_HASH');
        }

        $user = User::query()->where('public_id', $userPublicId)->first();
        if (! $user) {
            throw new \RuntimeException('UNKNOWN_USER');
        }

        if ($status === 2) {
            Log::info('CPX postback canceled', [
                'trans_id' => $transId,
                'user_id' => $userPublicId,
            ]);

            return ['action' => 'canceled', 'duplicate' => false];
        }

        if ($status !== 1) {
            return ['action' => 'ignored', 'duplicate' => false];
        }

        $points = (int) config('lotaya.cpx.points_per_survey', 2);
        $result = $this->points->addTransaction(
            $user->id,
            $points,
            'earn_cpx_survey',
            $transId,
            'cpx_'.$transId,
        );

        return [
            'action' => 'credited',
            'duplicate' => $result['duplicate'],
            'balance' => $result['balance'],
            'points' => $points,
        ];
    }
}
