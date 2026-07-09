<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">
    <title>@yield('title', 'Admin — Lotaya Shwe Oh')</title>
    <style>
        :root {
            --gold: #b8860b;
            --gold-dark: #9a7209;
            --cream: #faf6ee;
            --text: #3d3428;
            --muted: #7a6f5c;
            --border: #e8dcc8;
            --danger: #b42318;
            --ok: #067647;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, sans-serif;
            background: var(--cream);
            color: var(--text);
        }
        .wrap { max-width: 1100px; margin: 0 auto; padding: 20px 16px 48px; }
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }
        .topbar h1 { margin: 0; color: var(--gold-dark); font-size: 1.4rem; }
        .nav { display: flex; gap: 10px; flex-wrap: wrap; }
        .nav a {
            color: var(--gold-dark);
            text-decoration: none;
            font-weight: 600;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: #fff;
        }
        .nav a.is-active { background: var(--gold); color: #fff; border-color: var(--gold); }
        .card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 18px;
            margin-bottom: 14px;
            box-shadow: 0 4px 16px rgba(61, 52, 40, 0.05);
        }
        h2 { margin: 0 0 10px; font-size: 1.05rem; color: var(--gold-dark); }
        p.lead { margin: 0 0 12px; color: var(--muted); font-size: 0.9rem; }
        .alert { padding: 12px 14px; border-radius: 10px; margin-bottom: 14px; font-size: 0.9rem; }
        .alert-error { background: #fef3f2; color: var(--danger); border: 1px solid #fecdca; }
        .alert-success { background: #ecfdf3; color: var(--ok); border: 1px solid #abefc6; }
        .btn {
            display: inline-block;
            padding: 10px 14px;
            border-radius: 10px;
            background: var(--gold);
            color: #fff;
            border: none;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9rem;
        }
        .btn:hover { background: var(--gold-dark); }
        .btn-secondary { background: #fff; color: var(--gold-dark); border: 1px solid var(--gold); }
        .status-row {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 8px;
            margin-bottom: 12px;
        }
        @media (max-width: 800px) { .status-row { grid-template-columns: repeat(2, 1fr); } }
        .status-pill {
            border-radius: 12px;
            padding: 12px 8px;
            text-align: center;
            color: #fff;
            font-weight: 800;
            font-size: 1.05rem;
        }
        .status-pill small { display: block; font-size: 0.68rem; font-weight: 600; margin-top: 2px; }
        .s-total { background: #2563eb; }
        .s-approved { background: #16a34a; }
        .s-pending { background: #ea580c; }
        .s-rejected { background: #dc2626; }
        .s-mmk { background: #1e293b; font-size: 0.88rem; }
        .pay-totals {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 12px;
        }
        @media (max-width: 600px) { .pay-totals { grid-template-columns: 1fr; } }
        .pay-card {
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 12px;
            text-align: center;
            background: #fff;
        }
        .pay-card strong { display: block; font-size: 1rem; margin-top: 4px; }
        .pay-card.kbz strong { color: #16a34a; }
        .pay-card.wave strong { color: #2563eb; }
        .pay-card.tm strong { color: #ea580c; }
        .tier-row {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 8px;
            margin-bottom: 12px;
        }
        @media (max-width: 800px) { .tier-row { grid-template-columns: repeat(2, 1fr); } }
        .tier-pill {
            border-radius: 12px;
            padding: 10px 8px;
            text-align: center;
            color: #fff;
            font-size: 0.75rem;
            font-weight: 700;
            line-height: 1.35;
        }
        .tier-pill .count { font-size: 1rem; display: block; }
        .t-diamond { background: linear-gradient(135deg, #db2777, #ec4899); }
        .t-fire { background: linear-gradient(135deg, #ea580c, #f97316); }
        .t-gold { background: linear-gradient(135deg, #ca8a04, #eab308); color: #422006; }
        .t-silver { background: linear-gradient(135deg, #64748b, #94a3b8); }
        .t-bronze { background: linear-gradient(135deg, #b45309, #d97706); }
        .filter-nav { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
        .filter-nav a {
            padding: 8px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.85rem;
            border: 1px solid var(--border);
            color: var(--text);
            background: #fff;
        }
        .filter-nav a.is-active { background: var(--gold); color: #fff; border-color: var(--gold); }
        table { width: 100%; border-collapse: collapse; font-size: 0.84rem; }
        th, td { border-bottom: 1px solid var(--border); padding: 9px 8px; text-align: left; }
        th { background: var(--cream); color: var(--muted); }
        .badge { padding: 3px 9px; border-radius: 999px; font-size: 0.72rem; font-weight: 700; }
        .badge-pending { background: #fef9c3; color: #a16207; }
        .badge-approved { background: #dcfce7; color: var(--ok); }
        .badge-rejected { background: #fee2e2; color: var(--danger); }
        label { display: block; font-weight: 600; margin: 8px 0 4px; font-size: 0.88rem; }
        input, select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 0.94rem;
        }
        .field-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
        @media (max-width: 700px) { .field-row { grid-template-columns: 1fr; } }
        .table-wrap { overflow-x: auto; border: 1px solid var(--border); border-radius: 10px; }
    </style>
</head>
<body>
    <div class="wrap">
        <div class="topbar">
            <h1>Lotaya Shwe Oh Admin</h1>
            <div style="display:flex;gap:8px;align-items:center;">
                <nav class="nav">
                    <a href="{{ route('admin.dashboard') }}" @if(request()->routeIs('admin.dashboard') || request()->routeIs('admin.withdraws')) class="is-active" @endif>Dashboard</a>
                    <a href="{{ route('admin.gift-codes') }}" @if(request()->routeIs('admin.gift-codes*')) class="is-active" @endif>Gift Codes</a>
                </nav>
                <form method="post" action="{{ route('admin.logout') }}">
                    @csrf
                    <button class="btn btn-secondary" type="submit">Logout</button>
                </form>
            </div>
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
