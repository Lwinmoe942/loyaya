<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\RegionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegionController extends Controller
{
    public function __construct(private readonly RegionService $regions) {}

    public function show(Request $request): JsonResponse
    {
        $result = $this->regions->evaluate($request);

        return response()->json([
            'allowed' => $result['allowed'],
            'country' => $result['country'],
            'reason' => $result['reason'],
            'ip' => $this->maskIp($result['ip']),
            'blocked_countries' => $this->regions->blockedCountries(),
            'message' => $result['allowed'] ? null : $this->regions->blockMessage(),
        ]);
    }

    private function maskIp(?string $ip): ?string
    {
        if ($ip === null || $ip === '') {
            return null;
        }

        if (str_contains($ip, ':')) {
            $parts = explode(':', $ip);

            return ($parts[0] ?? '').':***';
        }

        $parts = explode('.', $ip);
        if (count($parts) !== 4) {
            return '***';
        }

        return $parts[0].'.'.$parts[1].'.*.*';
    }
}
