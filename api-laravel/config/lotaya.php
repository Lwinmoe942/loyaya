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

    // Flat bonus to referrer when a friend successfully links a referral code.
    'referral_signup_bonus' => (int) env('REFERRAL_SIGNUP_BONUS', 10),
    // Percent of each referred friend's earn_* points paid to the referrer (min 1 when earn > 0).
    'referral_earn_percent' => (float) env('REFERRAL_EARN_PERCENT', 10),

    'exchange_url' => env('EXCHANGE_URL', 'http://localhost:8000/exchange'),
    'app_url' => env('APP_URL', 'http://localhost:8000'),
    'course_contact_email' => env('COURSE_CONTACT_EMAIL', 'moegyi707299@gmail.com'),

    // Adsterra (exchange website only — paste publisher scripts from dashboard).
    'adsterra' => [
        'enabled' => filter_var(env('ADSTERRA_ENABLED', false), FILTER_VALIDATE_BOOL),
        'banner_top' => env('ADSTERRA_BANNER_TOP', ''),
        'banner_bottom' => env('ADSTERRA_BANNER_BOTTOM', ''),
        'social_bar' => env('ADSTERRA_SOCIAL_BAR', ''),
    ],

    'cpx' => [
        'app_id' => env('CPX_APP_ID', ''),
        'secure_hash' => env('CPX_SECURE_HASH', ''),
        'points_per_survey' => (int) env('CPX_POINTS_PER_SURVEY', 2),
        'allowed_ips' => array_values(array_filter(array_map(
            static fn (string $ip): string => trim($ip),
            explode(',', (string) env('CPX_ALLOWED_IPS', '')),
        ))),
    ],

    // Force-update gate. When a new Play release is live, set
    // APP_MIN_VERSION_CODE (Railway) to that release's versionCode.
    // Apps below it see a non-dismissible update screen.
    'app_update' => [
        'min_version_code' => (int) env('APP_MIN_VERSION_CODE', 7),
        'latest_version_code' => (int) env('APP_LATEST_VERSION_CODE', 7),
        'force' => filter_var(env('APP_FORCE_UPDATE', true), FILTER_VALIDATE_BOOL),
        'play_url' => env(
            'APP_PLAY_URL',
            'https://play.google.com/store/apps/details?id=com.loyaya.loyaya',
        ),
        'message' => env(
            'APP_UPDATE_MESSAGE',
            'A new version is required. Please update Lotaya Shwe Oh from Google Play to continue.',
        ),
    ],

    'region_block' => [
        'enabled' => filter_var(env('REGION_BLOCK_ENABLED', true), FILTER_VALIDATE_BOOL),
        'block_unknown' => filter_var(env('REGION_BLOCK_BLOCK_UNKNOWN', true), FILTER_VALIDATE_BOOL),
        'blocked_countries' => array_values(array_filter(array_map(
            static fn (string $code): string => strtoupper(trim($code)),
            explode(',', (string) env('REGION_BLOCK_COUNTRIES', 'MM')),
        ))),
        'message' => env(
            'REGION_BLOCK_MESSAGE',
            'Lotaya Shwe Oh is not available from Myanmar network locations. Please connect a VPN and try again.',
        ),
    ],
];
