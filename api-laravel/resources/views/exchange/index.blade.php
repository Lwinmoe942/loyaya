@extends('layouts.app')

@section('title', 'Lotaya Shwe Oh Withdraw — Official Point Exchange Website')
@section('meta_description', 'Lotaya Shwe Oh withdraw official website. Exchange Lotaya Shwe Oh points to KBZ Pay, Wave Pay or True Money. Check withdraw status online.')
@section('meta_keywords', 'Lotaya Shwe Oh withdraw, Lotaya Shwe Oh, Lotaya Shwe Oh website, Lotaya Shwe Oh exchange, Lotaya Shwe Oh point withdraw')
@section('canonical', url('/exchange'))
@section('og_title', 'Lotaya Shwe Oh Withdraw — Official Website')
@section('og_description', 'Official Lotaya Shwe Oh withdraw and point exchange website. Submit withdraw requests and track status.')

@section('content')
@php
    $selectedPay = old('payment_method', 'kbz');
    $tierNames = [
        'bronze' => 'Bronze',
        'silver' => 'Silver',
        'gold' => 'Gold',
        'fire' => 'Fire',
        'diamond' => 'Diamond',
    ];
    $payLabels = [
        'kbz' => 'KBZ Pay',
        'wave' => 'Wave Pay',
        'true_money' => 'True Money',
    ];
@endphp

<script type="application/ld+json">
{
  "@@context": "https://schema.org",
  "@@type": "WebPage",
  "name": "Lotaya Shwe Oh Withdraw",
  "alternateName": ["Lotaya Shwe Oh Point Exchange", "Lotaya Shwe Oh website"],
  "description": "Official Lotaya Shwe Oh withdraw website for exchanging app points to KBZ Pay, Wave Pay or True Money.",
  "url": "{{ url('/exchange') }}",
  "isPartOf": {
    "@@type": "WebSite",
    "name": "Lotaya Shwe Oh",
    "url": "{{ url('/') }}"
  },
  "potentialAction": {
    "@@type": "SearchAction",
    "target": "{{ url('/exchange/status') }}",
    "query-input": "required name=email"
  }
}
</script>

{{-- Main exchange form --}}
<div class="card">
    <h1>Lotaya Shwe Oh Withdraw</h1>
    <p class="lead">
        Official <strong>Lotaya Shwe Oh withdraw</strong> website.
        App ထဲက User ID နဲ့ point ထုတ်ယူပါ။ အနည်းဆုံး {{ number_format($minPoints) }} points၊
        {{ number_format($step) }} ဖြင့် စားပြတ်ရပါမယ်။
    </p>
    <p class="lead" style="margin-top:-8px;">
        Lotaya Shwe Oh point exchange · Lotaya Shwe Oh website · KBZ Pay / Wave Pay / True Money
    </p>

    <div class="rates">
        @foreach ($rates as $tier => $rate)
            <div class="rate-box">
                <strong>{{ $tierNames[$tier] ?? ucfirst($tier) }}</strong>
                1 pt = {{ $rate }} MMK
            </div>
        @endforeach
    </div>

    <form method="post" action="{{ route('exchange.submit') }}" id="exchange-form">
        @csrf

        <div class="field">
            <label for="public_id">User ID (App ထဲက Public ID)</label>
            <input id="public_id" name="public_id" value="{{ old('public_id') }}" placeholder="LSO-XXXX-XXXX" required autocomplete="off">
        </div>

        <div class="field-row">
            <div class="field">
                <label for="name">အမည် (optional)</label>
                <input id="name" name="name" value="{{ old('name') }}" autocomplete="name">
            </div>
            <div class="field">
                <label for="email">Email</label>
                <input id="email" name="email" type="email" value="{{ old('email') }}" required autocomplete="email">
            </div>
        </div>

        <div class="field">
            <label for="points">Point ပမာဏ</label>
            <input id="points" name="points" type="number" min="{{ $minPoints }}" step="{{ $step }}" value="{{ old('points', $minPoints) }}" required>
        </div>

        <p class="section-label">Service Type</p>
        <div class="service-card">
            <div class="service-icon" aria-hidden="true">🎮</div>
            <div>
                <strong>Lotaya Shwe Oh</strong>
                <span>App ထဲက ရရှိထားသော points များ</span>
            </div>
        </div>

        <div class="notice notice-info">
            Lotaya Shwe Oh မှ ရရှိထားသော points များကို KBZ Pay၊ Wave Pay သို့မဟုတ် True Money ဖြင့် ထုတ်ယူနိုင်ပါသည်။
        </div>

        <p class="section-label">ငွေလက်ခံနည်း</p>
        <div class="pay-grid" role="radiogroup" aria-label="Payment method">
            <label class="pay-option">
                <input type="radio" name="payment_method" value="kbz" @checked($selectedPay === 'kbz') required>
                <span class="pay-card">
                    <span class="pay-logo kbz">KBZ</span>
                    <span>KBZ Pay</span>
                </span>
            </label>
            <label class="pay-option">
                <input type="radio" name="payment_method" value="wave" @checked($selectedPay === 'wave')>
                <span class="pay-card">
                    <span class="pay-logo wave">Wave</span>
                    <span>Wave Pay</span>
                </span>
            </label>
            <label class="pay-option">
                <input type="radio" name="payment_method" value="true_money" @checked($selectedPay === 'true_money')>
                <span class="pay-card">
                    <span class="pay-logo tm">TM</span>
                    <span>True Money</span>
                </span>
            </label>
        </div>

        <div class="field" style="margin-top:12px;">
            <label for="payment_phone">ငွေလက်ခံ ဖုန်းနံပါတ်</label>
            <input id="payment_phone" name="payment_phone" type="tel" value="{{ old('payment_phone') }}" placeholder="09xxxxxxxxx" required autocomplete="tel">
        </div>

        <div class="notice notice-warn">
            True Money ရွေးပါက True Money Wallet နံပါတ်ကို မှန်ကန်စွာ ထည့်ပါ။
        </div>
        <div class="notice notice-danger">
            အနည်းဆုံး <strong>{{ number_format($minPoints) }}</strong> points ထုတ်ရပါမယ်။
            {{ number_format($step) }} ဖြင့် စားပြတ်ရပါမယ်။ App Profile ထဲက User ID ကို မှန်ကန်စွာ ထည့်ပါ။
        </div>

        <div class="btn-row">
            <button class="btn btn-primary" type="submit">တောင်းဆိုမှု ပို့မည်</button>
            <a class="btn btn-outline" href="{{ route('exchange.status.form') }}">Status စစ်မည်</a>
        </div>
    </form>
</div>

{{-- Status check + Welcome --}}
<div class="bottom-grid">
    <div class="card" id="status">
        <div class="mini-head">
            <span class="icon icon-green" aria-hidden="true">🔍</span>
            <h2 style="margin:0;">တောင်းဆိုချက်အခြေအနေ စစ်ဆေးရန်</h2>
        </div>
        <form method="get" action="{{ route('exchange.status.form') }}">
            <div class="field">
                <label for="status_email">Email</label>
                <input id="status_email" name="email" type="email" placeholder="you@email.com" required>
            </div>
            <button class="btn btn-green btn-block" type="submit">Check Status</button>
        </form>
    </div>

    <div class="card">
        <div class="mini-head">
            <span class="icon icon-gold" aria-hidden="true">👋</span>
            <h2 style="margin:0;">Welcome From Points Topup System</h2>
        </div>
        <p class="lead" style="margin-bottom:0;">
            Lotaya Shwe Oh မှ point ထုတ်ယူထားသော အကောင့်များကို အောက်တွင် ကြည့်ရှုနိုင်ပါသည်။
            Tier အလိုက် exchange rate ကွဲပြားပါသည်။
        </p>
    </div>
</div>

{{-- Payment method totals --}}
<div class="card">
    <p class="stat-section-title">Payment Method အလိုက် ထုတ်ပြီးသား Amount များ</p>
    <div class="pay-totals">
        <div class="pay-total-card kbz">
            <div class="logo kbz">KBZ</div>
            <small>KBZ Pay</small>
            <strong>{{ number_format($paymentTotals['kbz'] ?? 0) }} MMK</strong>
        </div>
        <div class="pay-total-card wave">
            <div class="logo wave">Wave</div>
            <small>Wave Pay</small>
            <strong>{{ number_format($paymentTotals['wave'] ?? 0) }} MMK</strong>
        </div>
        <div class="pay-total-card tm">
            <div class="logo tm">TM</div>
            <small>True Money</small>
            <strong>{{ number_format($paymentTotals['true_money'] ?? 0) }} MMK</strong>
        </div>
    </div>

    <p class="stat-section-title">Service Type အလိုက် ထုတ်ပြီးသား Amount များ</p>
    <div class="service-total">
        <div class="service-icon" aria-hidden="true">🎮</div>
        <div>
            <strong>{{ number_format($totalApprovedMmk) }} MMK</strong><br>
            <span>Lotaya Shwe Oh</span>
        </div>
    </div>
</div>

{{-- All transactions dashboard --}}
<div class="card">
    <h2>All Transactions</h2>
    <div class="legend">
        <span class="lg">Approved</span>
        <span class="ly">Pending</span>
        <span class="lr">Rejected</span>
    </div>

    <div class="status-row">
        <div class="status-pill s-total">
            {{ number_format($statusCounts['total']) }}
            <small>Total Requests</small>
        </div>
        <div class="status-pill s-approved">
            {{ number_format($statusCounts['approved']) }}
            <small>Approved</small>
        </div>
        <div class="status-pill s-pending">
            {{ number_format($statusCounts['pending']) }}
            <small>Pending</small>
        </div>
        <div class="status-pill s-rejected">
            {{ number_format($statusCounts['rejected']) }}
            <small>Rejected</small>
        </div>
        <div class="status-pill s-mmk">
            {{ number_format($totalApprovedMmk) }}
            <small>Total MMK</small>
        </div>
    </div>

    <div class="tier-row">
        @foreach ($tierCards as $tier)
            <div class="tier-pill t-{{ $tier['tier'] }}">
                <span class="count">{{ number_format($tier['users']) }}</span>
                {{ ucfirst($tier['tier']) }}<br>
                {{ $tier['label'] }}<br>
                1 pt = {{ $tier['rate'] }} MMK
            </div>
        @endforeach
    </div>

    @if ($transactions->isEmpty())
        <div class="empty-state">တောင်းဆိုမှု မရှိသေးပါ။</div>
    @else
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Order #</th>
                        <th>Points</th>
                        <th>MMK</th>
                        <th>Tier</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($transactions as $row)
                        <tr>
                            <td>#{{ $row->id }}</td>
                            <td>{{ number_format($row->points) }}</td>
                            <td>{{ number_format($row->mmk_amount) }}</td>
                            <td>{{ ucfirst($row->user?->tier ?? 'bronze') }}</td>
                            <td>{{ $payLabels[$row->payment_method] ?? $row->payment_method }}</td>
                            <td><span class="badge badge-{{ $row->status }}">{{ $row->status }}</span></td>
                            <td>{{ $row->created_at?->format('Y-m-d H:i') }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        @if ($transactions->hasPages())
            <div class="pagination">
                @if ($transactions->onFirstPage())
                    <span>&laquo; Prev</span>
                @else
                    <a href="{{ $transactions->previousPageUrl() }}">&laquo; Prev</a>
                @endif
                <span class="active">{{ $transactions->currentPage() }} / {{ $transactions->lastPage() }}</span>
                @if ($transactions->hasMorePages())
                    <a href="{{ $transactions->nextPageUrl() }}">Next &raquo;</a>
                @else
                    <span>Next &raquo;</span>
                @endif
            </div>
        @endif
    @endif
</div>
@endsection
