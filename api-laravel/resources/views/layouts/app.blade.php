<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Lotaya Shwe Oh')</title>
    <style>
        :root {
            --gold: #c9a227;
            --gold-dark: #9a7b1a;
            --cream: #faf6ee;
            --text: #2c2416;
            --muted: #6b5f4d;
            --danger: #b42318;
            --ok: #067647;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, sans-serif;
            background: linear-gradient(180deg, #fff9eb 0%, var(--cream) 100%);
            color: var(--text);
            min-height: 100vh;
        }
        .wrap { max-width: 720px; margin: 0 auto; padding: 24px 16px 48px; }
        .card {
            background: #fff;
            border: 1px solid #eadfc8;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(44, 36, 22, 0.06);
        }
        h1 { margin: 0 0 8px; color: var(--gold-dark); font-size: 1.6rem; }
        p.lead { color: var(--muted); margin-top: 0; }
        label { display: block; font-weight: 600; margin: 14px 0 6px; }
        input, select {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d9cdb5;
            border-radius: 10px;
            font-size: 1rem;
        }
        .btn {
            display: inline-block;
            margin-top: 18px;
            background: var(--gold);
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 12px 18px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
        }
        .btn:hover { background: var(--gold-dark); }
        .btn-secondary { background: #fff; color: var(--gold-dark); border: 1px solid var(--gold); }
        .alert {
            padding: 12px 14px;
            border-radius: 10px;
            margin-bottom: 16px;
        }
        .alert-error { background: #fef3f2; color: var(--danger); border: 1px solid #fecdca; }
        .alert-success { background: #ecfdf3; color: var(--ok); border: 1px solid #abefc6; }
        .nav { margin-bottom: 16px; }
        .nav a { color: var(--gold-dark); margin-right: 14px; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 0.92rem; }
        th, td { border-bottom: 1px solid #eee4d2; padding: 10px 8px; text-align: left; }
        .badge { padding: 4px 8px; border-radius: 999px; font-size: 0.8rem; font-weight: 700; }
        .badge-pending { background: #fff7ed; color: #c2410c; }
        .badge-approved { background: #ecfdf3; color: var(--ok); }
        .badge-rejected { background: #fef3f2; color: var(--danger); }
        .rates { display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 8px; margin: 12px 0; }
        .rate-box { background: #fffaf0; border: 1px solid #eadfc8; border-radius: 10px; padding: 10px; text-align: center; }
    </style>
</head>
<body>
    <div class="wrap">
        <div class="nav">
            <a href="{{ route('exchange.index') }}">Point Exchange</a>
            <a href="{{ route('exchange.status.form') }}">Status</a>
            <a href="{{ route('admin.login') }}">Admin</a>
        </div>
        @if (session('success'))
            <div class="alert alert-success">{{ session('success') }}</div>
        @endif
        @if (session('error'))
            <div class="alert alert-error">{{ session('error') }}</div>
        @endif
        @yield('content')
    </div>
</body>
</html>
