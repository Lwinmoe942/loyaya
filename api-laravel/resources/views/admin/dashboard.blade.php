@extends('layouts.admin')

@section('title', 'Admin Dashboard — Lotaya Shwe Oh')

@section('content')
<div class="card">
    <h2>Overview</h2>
    <p class="lead">Users: <strong>{{ number_format($userCount) }}</strong> · Gift codes: <strong>{{ number_format($giftCodeCount) }}</strong></p>

    <p class="lead" style="margin-bottom:8px;">User အားလုံး Points + ပေးရမည့် ငွေ</p>
    <div class="status-row">
        <div class="status-pill s-total">
            {{ number_format($finance['outstanding_points'] ?? 0) }}
            <small>စုစုပေါင်း Points<br>(user အားလုံး လက်ကျန်)</small>
        </div>
        <div class="status-pill s-mmk">
            {{ number_format($finance['estimated_liability_mmk'] ?? 0) }}
            <small>ပေးရမည့် ခန့်မှန်း MMK<br>(စု points × tier rate)</small>
        </div>
        <div class="status-pill s-approved">
            {{ number_format($finance['approved_mmk'] ?? $totalApprovedMmk) }}
            <small>ထုတ်ပေးပြီးသား MMK</small>
        </div>
        <div class="status-pill s-pending">
            {{ number_format($finance['pending_mmk'] ?? 0) }}
            <small>စောင့်ဆိုင်း MMK</small>
        </div>
        <div class="status-pill s-rejected">
            {{ number_format($finance['points_earned'] ?? 0) }}
            <small>ရဖူးသမျှ Points စု</small>
        </div>
    </div>
    <p style="color:var(--muted);font-size:0.85rem;margin-top:0;">
        ဥပမာ — user အားလုံး လက်ကျန် 1,500 pts ဆိုရင် rate 3 MMK နဲ့ ≈ 4,500 MMK ပေးရမယ်။
        အပေါ်က “ပေးရမည့် ခန့်မှန်း MMK” က user တိုင်းရဲ့ tier rate (3 သို့ 4) နဲ့ သီးခြားတွက်ထားတာ။
    </p>

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
            {{ number_format($finance['approved_points'] ?? 0) }}
            <small>Points Withdrawn</small>
        </div>
    </div>

    <p class="lead" style="margin-bottom:8px;">Payment Method အလိုက် ထုတ်ပြီးသား Amount</p>
    <div class="pay-totals">
        <div class="pay-card kbz">
            <small>KBZ Pay</small>
            <strong>{{ number_format($paymentTotals['kbz'] ?? 0) }} MMK</strong>
        </div>
        <div class="pay-card wave">
            <small>Wave Pay</small>
            <strong>{{ number_format($paymentTotals['wave'] ?? 0) }} MMK</strong>
        </div>
        <div class="pay-card tm">
            <small>True Money</small>
            <strong>{{ number_format($paymentTotals['true_money'] ?? 0) }} MMK</strong>
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
</div>

<div class="card">
    <h2>Withdraw Requests</h2>
    <p class="lead">ငွေထုတ် တောင်းဆိုမှုများ — Pending ကို approve / reject လုပ်ပါ။ (Courses မဟုတ်ပါ)</p>

    @if (session('success'))
        <p style="color:#16a34a;font-weight:600;">{{ session('success') }}</p>
    @endif
    @if (session('error'))
        <p style="color:#dc2626;font-weight:600;">{{ session('error') }}</p>
    @endif

    <div class="filter-nav">
        <a href="{{ route('admin.dashboard', ['status' => 'all']) }}" @if($status === 'all') class="is-active" @endif>All ({{ number_format($statusCounts['total']) }})</a>
        <a href="{{ route('admin.dashboard', ['status' => 'pending']) }}" @if($status === 'pending') class="is-active" @endif>Pending ({{ number_format($statusCounts['pending']) }})</a>
        <a href="{{ route('admin.dashboard', ['status' => 'approved']) }}" @if($status === 'approved') class="is-active" @endif>Approved ({{ number_format($statusCounts['approved']) }})</a>
        <a href="{{ route('admin.dashboard', ['status' => 'rejected']) }}" @if($status === 'rejected') class="is-active" @endif>Rejected ({{ number_format($statusCounts['rejected']) }})</a>
    </div>

    @if ($requests->isEmpty())
        <p style="color:var(--muted);">ဒီ status အတွက် တောင်းဆိုမှု မရှိပါ။ <a href="{{ route('admin.dashboard', ['status' => 'all']) }}">All</a> ကို ကြည့်ပါ။</p>
    @else
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Order #</th>
                        <th>User ID</th>
                        <th>Name</th>
                        <th>Points</th>
                        <th>MMK</th>
                        <th>Method</th>
                        <th>Phone</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($requests as $row)
                        <tr>
                            <td>#{{ $row->id }}</td>
                            <td style="white-space:nowrap;font-weight:700;">{{ $row->user?->public_id ?? '—' }}</td>
                            <td>{{ $row->user?->name ?? '—' }} <small>({{ ucfirst($row->user?->tier ?? 'bronze') }})</small></td>
                            <td>{{ number_format($row->points) }}</td>
                            <td>{{ number_format($row->mmk_amount) }}</td>
                            <td>{{ $payLabels[$row->payment_method] ?? strtoupper((string) $row->payment_method) }}</td>
                            <td>{{ $row->payment_phone }}</td>
                            <td>{{ $row->email }}</td>
                            <td><span class="badge badge-{{ $row->status }}">{{ $row->status }}</span></td>
                            <td>
                                @if ($row->status === 'pending')
                                    <form method="post" action="{{ route('admin.withdraws.approve', $row->id) }}" style="display:inline;">
                                        @csrf
                                        <button class="btn" type="submit" style="padding:6px 10px;">Approve</button>
                                    </form>
                                    <form method="post" action="{{ route('admin.withdraws.reject', $row->id) }}" style="display:inline;">
                                        @csrf
                                        <button class="btn btn-secondary" type="submit" style="padding:6px 10px;">Reject</button>
                                    </form>
                                @else
                                    —
                                @endif
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    @endif
</div>
@endsection
