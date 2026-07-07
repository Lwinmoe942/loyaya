<?php

return [
    'admin_api_key' => env('ADMIN_API_KEY', 'change-me-in-production'),

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
    ],

    'exchange_url' => env('EXCHANGE_URL', 'http://localhost:8000/exchange'),
];
