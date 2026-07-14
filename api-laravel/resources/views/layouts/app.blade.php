<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Lotaya Shwe Oh Withdraw — Official Point Exchange')</title>
    <meta name="description" content="@yield('meta_description', 'Lotaya Shwe Oh withdraw official website. Exchange points to KBZ Pay, Wave Pay or True Money.')">
    <meta name="keywords" content="@yield('meta_keywords', 'Lotaya Shwe Oh withdraw, Lotaya Shwe Oh, Lotaya Shwe Oh website, Lotaya Shwe Oh exchange')">
    <meta name="robots" content="index,follow,max-snippet:-1,max-image-preview:large">
    <meta name="googlebot" content="index,follow">
    <link rel="canonical" href="@yield('canonical', url()->current())">
    <meta property="og:type" content="website">
    <meta property="og:title" content="@yield('og_title', 'Lotaya Shwe Oh Withdraw')">
    <meta property="og:description" content="@yield('og_description', 'Official Lotaya Shwe Oh withdraw and point exchange website.')">
    <meta property="og:url" content="@yield('canonical', url()->current())">
    <meta property="og:site_name" content="Lotaya Shwe Oh">
    <meta name="twitter:card" content="summary">
    <meta name="twitter:title" content="@yield('og_title', 'Lotaya Shwe Oh Withdraw')">
    <meta name="twitter:description" content="@yield('og_description', 'Official Lotaya Shwe Oh withdraw website.')">
    <style>
        :root {
            --gold: #b8860b;
            --gold-dark: #9a7209;
            --gold-light: #d4a84b;
            --cream: #faf6ee;
            --cream-dark: #f0e8d8;
            --surface: #ffffff;
            --text: #3d3428;
            --muted: #7a6f5c;
            --border: #e8dcc8;
            --danger: #b42318;
            --ok: #067647;
            --info: #1d4ed8;
            --warn: #c2410c;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, "Myanmar Text", sans-serif;
            background: var(--cream);
            color: var(--text);
            min-height: 100vh;
        }
        .wrap { max-width: 980px; margin: 0 auto; padding: 20px 16px 48px; }

        .page-nav {
            display: flex;
            gap: 20px;
            margin-bottom: 16px;
            font-size: 0.95rem;
        }
        .page-nav a {
            color: var(--gold);
            text-decoration: none;
            font-weight: 600;
            padding-bottom: 3px;
            border-bottom: 2px solid transparent;
        }
        .page-nav a.is-active { border-bottom-color: var(--gold); }
        .page-nav a:hover { color: var(--gold-dark); }

        .alert {
            padding: 12px 14px;
            border-radius: 10px;
            margin-bottom: 14px;
            font-size: 0.92rem;
        }
        .alert-error { background: #fef3f2; color: var(--danger); border: 1px solid #fecdca; }
        .alert-success { background: #ecfdf3; color: var(--ok); border: 1px solid #abefc6; }

        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 16px;
            box-shadow: 0 4px 18px rgba(61, 52, 40, 0.06);
        }
        h1 { margin: 0 0 8px; color: var(--gold); font-size: 1.35rem; }
        h2 { margin: 0 0 8px; color: var(--gold-dark); font-size: 1.05rem; }
        h3 { margin: 0 0 10px; color: var(--text); font-size: 0.95rem; }
        p.lead { color: var(--muted); margin: 0 0 14px; font-size: 0.9rem; line-height: 1.55; }

        label {
            display: block;
            font-weight: 600;
            margin: 0 0 5px;
            color: var(--text);
            font-size: 0.88rem;
        }
        .field { margin-bottom: 12px; }
        input[type="text"],
        input[type="email"],
        input[type="number"],
        input[type="tel"],
        select {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #d4c4a8;
            border-radius: 10px;
            font-size: 0.94rem;
            background: #fff;
        }
        input:focus, select:focus {
            outline: none;
            border-color: var(--gold-light);
            box-shadow: 0 0 0 2px rgba(184, 134, 11, 0.18);
        }
        .field-row {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
        }
        @media (min-width: 640px) {
            .field-row { grid-template-columns: 1fr 1fr; }
        }

        .rates {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
            gap: 8px;
            margin: 12px 0 16px;
        }
        .rate-box {
            background: var(--cream-dark);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 10px 8px;
            text-align: center;
            font-size: 0.82rem;
            color: var(--gold-dark);
        }
        .rate-box strong { display: block; font-size: 0.88rem; margin-bottom: 2px; }

        .section-label {
            font-weight: 700;
            font-size: 0.9rem;
            margin: 14px 0 8px;
            color: var(--text);
        }

        .service-card {
            border: 2px solid var(--gold);
            border-radius: 12px;
            padding: 12px 14px;
            background: var(--cream);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .service-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--gold), var(--gold-light));
            display: grid;
            place-items: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        .service-card strong { display: block; font-size: 0.92rem; }
        .service-card span { font-size: 0.78rem; color: var(--muted); }

        .pay-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 10px;
        }
        @media (max-width: 520px) { .pay-grid { grid-template-columns: 1fr; } }
        .pay-option { position: relative; }
        .pay-option input { position: absolute; opacity: 0; width: 0; height: 0; }
        .pay-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            padding: 12px 8px;
            border: 2px solid var(--border);
            border-radius: 12px;
            cursor: pointer;
            text-align: center;
            background: #fff;
            transition: border-color 0.15s, background 0.15s;
        }
        .pay-card:hover { border-color: var(--gold-light); }
        .pay-option input:checked + .pay-card {
            border-color: var(--gold);
            background: var(--cream);
        }
        .pay-logo {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: grid;
            place-items: center;
            font-weight: 800;
            font-size: 0.68rem;
            color: #fff;
        }
        .pay-logo.kbz { background: #16a34a; }
        .pay-logo.wave { background: #2563eb; }
        .pay-logo.tm { background: #ea580c; }
        .pay-card span { font-size: 0.8rem; font-weight: 600; }

        .notice {
            border-radius: 10px;
            padding: 11px 13px;
            font-size: 0.84rem;
            line-height: 1.5;
            margin-top: 10px;
        }
        .notice-info { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
        .notice-warn { background: #fff7ed; border: 1px solid #fed7aa; color: #9a3412; }
        .notice-danger { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; }

        .btn-row { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 16px; }
        .btn {
            display: inline-block;
            padding: 11px 18px;
            border-radius: 10px;
            font-size: 0.92rem;
            font-weight: 700;
            text-decoration: none;
            border: none;
            cursor: pointer;
        }
        .btn-primary { background: var(--gold); color: #fff; }
        .btn-primary:hover { background: var(--gold-dark); }
        .btn-outline {
            background: #fff;
            color: var(--gold);
            border: 1.5px solid var(--gold);
        }
        .btn-outline:hover { background: var(--cream); }
        .btn-green { background: #15803d; color: #fff; }
        .btn-green:hover { background: #166534; }
        .btn-block { width: 100%; text-align: center; }

        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 14px;
        }
        @media (min-width: 720px) { .bottom-grid { grid-template-columns: 1fr 1fr; } }

        .mini-head {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
        }
        .mini-head .icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            font-size: 1rem;
        }
        .icon-green { background: #dcfce7; }
        .icon-gold { background: var(--cream-dark); }

        /* Dashboard stats */
        .stat-section-title {
            font-weight: 700;
            font-size: 0.92rem;
            margin: 0 0 10px;
            color: var(--text);
        }
        .pay-totals {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 10px;
            margin-bottom: 16px;
        }
        @media (max-width: 600px) { .pay-totals { grid-template-columns: 1fr; } }
        .pay-total-card {
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 12px;
            background: #fff;
            text-align: center;
        }
        .pay-total-card .logo {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            margin: 0 auto 6px;
            display: grid;
            place-items: center;
            font-size: 0.65rem;
            font-weight: 800;
            color: #fff;
        }
        .pay-total-card strong {
            display: block;
            font-size: 1rem;
            margin-top: 4px;
        }
        .pay-total-card.kbz strong { color: #16a34a; }
        .pay-total-card.wave strong { color: #2563eb; }
        .pay-total-card.tm strong { color: #ea580c; }
        .pay-total-card small { color: var(--muted); font-size: 0.78rem; }

        .service-total {
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px;
            background: var(--cream);
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        .service-total strong { font-size: 1.1rem; color: var(--gold-dark); }
        .service-total span { font-size: 0.82rem; color: var(--muted); }

        .status-row {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 8px;
            margin-bottom: 12px;
        }
        @media (max-width: 700px) { .status-row { grid-template-columns: repeat(2, 1fr); } }
        .status-pill {
            border-radius: 12px;
            padding: 12px 8px;
            text-align: center;
            color: #fff;
            font-weight: 800;
            font-size: 1.1rem;
        }
        .status-pill small {
            display: block;
            font-size: 0.68rem;
            font-weight: 600;
            opacity: 0.92;
            margin-top: 2px;
        }
        .s-total { background: #2563eb; }
        .s-approved { background: #16a34a; }
        .s-pending { background: #ea580c; }
        .s-rejected { background: #dc2626; }
        .s-mmk { background: #1e293b; font-size: 0.9rem; }

        .tier-row {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 8px;
            margin-bottom: 14px;
        }
        @media (max-width: 800px) { .tier-row { grid-template-columns: repeat(2, 1fr); } }
        .tier-pill {
            border-radius: 12px;
            padding: 10px 8px;
            text-align: center;
            color: #fff;
            font-size: 0.78rem;
            font-weight: 700;
            line-height: 1.35;
        }
        .tier-pill .count { font-size: 1.05rem; display: block; margin-bottom: 2px; }
        .t-diamond { background: linear-gradient(135deg, #db2777, #ec4899); }
        .t-fire { background: linear-gradient(135deg, #ea580c, #f97316); }
        .t-gold { background: linear-gradient(135deg, #ca8a04, #eab308); color: #422006; }
        .t-silver { background: linear-gradient(135deg, #64748b, #94a3b8); }
        .t-bronze { background: linear-gradient(135deg, #b45309, #d97706); }

        .legend {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            font-size: 0.78rem;
            color: var(--muted);
            margin-bottom: 10px;
        }
        .legend span::before {
            content: '';
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 4px;
        }
        .legend .lg::before { background: #16a34a; }
        .legend .ly::before { background: #eab308; }
        .legend .lr::before { background: #dc2626; }

        .table-wrap {
            overflow-x: auto;
            border: 1px solid var(--border);
            border-radius: 10px;
        }
        table { width: 100%; border-collapse: collapse; font-size: 0.84rem; }
        th, td { border-bottom: 1px solid var(--border); padding: 9px 8px; text-align: left; }
        th { background: var(--cream); color: var(--muted); font-weight: 700; }
        tr:last-child td { border-bottom: none; }
        .badge {
            padding: 3px 9px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: capitalize;
        }
        .badge-pending { background: #fef9c3; color: #a16207; }
        .badge-approved { background: #dcfce7; color: var(--ok); }
        .badge-rejected { background: #fee2e2; color: var(--danger); }

        .pagination {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 12px;
            justify-content: center;
        }
        .pagination a, .pagination span {
            padding: 6px 11px;
            border-radius: 8px;
            border: 1px solid var(--border);
            text-decoration: none;
            font-size: 0.82rem;
            color: var(--text);
        }
        .pagination a:hover { background: var(--cream); }
        .pagination .active { background: var(--gold); color: #fff; border-color: var(--gold); }

        .empty-state {
            padding: 16px;
            text-align: center;
            color: var(--muted);
            font-size: 0.88rem;
        }
    </style>
    @stack('styles')
</head>
<body>
    <div class="wrap">
        <nav class="page-nav" aria-label="Exchange navigation">
            <a href="{{ route('exchange.index') }}" @if(request()->routeIs('exchange.index')) class="is-active" @endif>Point Exchange</a>
            <a href="{{ route('exchange.status.form') }}" @if(request()->routeIs('exchange.status*')) class="is-active" @endif>Status</a>
        </nav>

        @if (session('success'))
            <div class="alert alert-success">{{ session('success') }}</div>
        @endif
        @if (session('error'))
            <div class="alert alert-error">{{ session('error') }}</div>
        @endif
        @if ($errors->any())
            <div class="alert alert-error">
                @foreach ($errors->all() as $error)
                    <div>{{ $error }}</div>
                @endforeach
            </div>
        @endif

        @yield('content')
    </div>
    @stack('scripts')
</body>
</html>
