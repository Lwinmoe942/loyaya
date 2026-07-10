<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join {{ $appName }}</title>
    <style>
        body { font-family: system-ui, sans-serif; background: #f5f5f5; margin: 0; padding: 24px; }
        .card { max-width: 480px; margin: 40px auto; background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,.08); }
        h1 { color: #e53935; margin-top: 0; }
        .code { font-size: 28px; font-weight: bold; color: #e53935; letter-spacing: 2px; margin: 16px 0; }
        p { color: #555; line-height: 1.5; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Join {{ $appName }}</h1>
        <p>Download the Lotaya Shwe Oh app and sign up with this referral code:</p>
        @if($ref)
            <div class="code">{{ strtoupper($ref) }}</div>
        @endif
        <p>Earn points together — your friend gets 10% bonus when you earn in the app.</p>
    </div>
</body>
</html>
