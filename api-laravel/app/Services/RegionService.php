<?php

namespace App\Services;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class RegionService
{
    /**
     * @return array{allowed: bool, country: ?string, ip: string, reason: ?string}
     */
    public function evaluate(Request $request): array
    {
        $ip = (string) $request->ip();

        if (! $this->enabled()) {
            return [
                'allowed' => true,
                'country' => null,
                'ip' => $ip,
                'reason' => 'disabled',
            ];
        }

        if ($this->isPrivateIp($ip)) {
            return [
                'allowed' => true,
                'country' => null,
                'ip' => $ip,
                'reason' => 'private_ip',
            ];
        }

        $country = $this->resolveCountry($request, $ip);

        if ($country === null) {
            return [
                'allowed' => ! $this->blockUnknown(),
                'country' => null,
                'ip' => $ip,
                'reason' => 'unknown_country',
            ];
        }

        $blocked = in_array($country, $this->blockedCountries(), true);

        return [
            'allowed' => ! $blocked,
            'country' => $country,
            'ip' => $ip,
            'reason' => $blocked ? 'blocked_country' : null,
        ];
    }

    public function enabled(): bool
    {
        return (bool) config('lotaya.region_block.enabled', true);
    }

    /**
     * @return list<string>
     */
    public function blockedCountries(): array
    {
        /** @var list<string> $countries */
        $countries = config('lotaya.region_block.blocked_countries', ['MM']);

        return array_values(array_filter(array_map(
            static fn ($code) => strtoupper(trim((string) $code)),
            $countries,
        )));
    }

    public function blockMessage(): string
    {
        return (string) config(
            'lotaya.region_block.message',
            'Lotaya Shwe Oh is not available from Myanmar network locations. Please connect a VPN and try again.',
        );
    }

    public function blockUnknown(): bool
    {
        return (bool) config('lotaya.region_block.block_unknown', false);
    }

    private function resolveCountry(Request $request, string $ip): ?string
    {
        $header = strtoupper(trim((string) $request->header('CF-IPCountry', '')));
        if ($header !== '' && $header !== 'XX' && preg_match('/^[A-Z]{2}$/', $header) === 1) {
            return $header;
        }

        $cacheKey = 'region.country.'.md5($ip);

        return Cache::remember($cacheKey, now()->addHours(6), function () use ($ip): ?string {
            $code = $this->lookupViaIpApi($ip) ?? $this->lookupViaIpApiCo($ip);
            if ($code === null) {
                Log::warning('Region lookup failed', ['ip' => $ip]);
            }
            return $code;
        });
    }

    private function lookupViaIpApi(string $ip): ?string
    {
        try {
            $response = Http::timeout(4)
                ->get("http://ip-api.com/json/{$ip}", [
                    'fields' => 'status,countryCode',
                ]);

            if (! $response->ok()) {
                return null;
            }

            $payload = $response->json();
            if (($payload['status'] ?? null) !== 'success') {
                return null;
            }

            $code = strtoupper(trim((string) ($payload['countryCode'] ?? '')));

            return preg_match('/^[A-Z]{2}$/', $code) === 1 ? $code : null;
        } catch (\Throwable $e) {
            Log::warning('ip-api lookup error', [
                'ip' => $ip,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    private function lookupViaIpApiCo(string $ip): ?string
    {
        try {
            $response = Http::timeout(4)
                ->get("https://ipapi.co/{$ip}/json/");

            if (! $response->ok()) {
                return null;
            }

            $payload = $response->json();
            $code = strtoupper(trim((string) ($payload['country_code'] ?? '')));

            return preg_match('/^[A-Z]{2}$/', $code) === 1 ? $code : null;
        } catch (\Throwable $e) {
            Log::warning('ipapi.co lookup error', [
                'ip' => $ip,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    private function isPrivateIp(string $ip): bool
    {
        if ($ip === '127.0.0.1' || $ip === '::1') {
            return true;
        }

        return filter_var(
            $ip,
            FILTER_VALIDATE_IP,
            FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE,
        ) === false;
    }
}
