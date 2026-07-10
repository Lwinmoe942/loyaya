<?php

return [
    'admin_api_key' => env('ADMIN_API_KEY', 'change-me-in-production'),
    'admin_password' => env('ADMIN_PASSWORD'),
    'admin_panel_path' => env('ADMIN_PANEL_PATH', 'admin'),
    'admin_allowed_ips' => array_values(array_filter(array_map(
        static fn (string $ip): string => trim($ip),
        explode(',', (string) env('ADMIN_ALLOWED_IPS', '')),
    ))),

    'rates' => [
        'bronze' => (int) env('RATE_BRONZE', 3),
        'silver' => (int) env('RATE_SILVER', 3),
        'gold' => (int) env('RATE_GOLD', 3),
        'fire' => (int) env('RATE_FIRE', 4),
        'diamond' => (int) env('RATE_DIAMOND', 4),
    ],

    'min_withdraw_points' => (int) env('MIN_WITHDRAW_POINTS', 500),
    'withdraw_step' => (int) env('WITHDRAW_STEP', 500),

    'tier_thresholds' => [
        ['tier' => 'diamond', 'min' => 10000],
        ['tier' => 'fire', 'min' => 6000],
        ['tier' => 'gold', 'min' => 3000],
        ['tier' => 'silver', 'min' => 1000],
        ['tier' => 'bronze', 'min' => 0],
    ],

    'earn_rules' => [
        'daily_checkin' => ['points' => 10, 'daily' => true],
        'math_quiz' => ['points' => 2, 'daily' => false],
        'survey' => ['points' => 2, 'daily' => false],
        'watch_video' => ['points' => 1, 'daily' => false],
        'watch_video_bonus' => ['points' => 1, 'daily' => false],
    ],

    'exchange_url' => env('EXCHANGE_URL', 'http://localhost:8000/exchange'),
    'app_url' => env('APP_URL', 'http://localhost:8000'),
];
