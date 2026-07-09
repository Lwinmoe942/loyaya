@extends('layouts.admin')

@section('title', 'Admin Dashboard — Lotaya Shwe Oh')

@section('content')
<div class="card">
    <h2>Overview</h2>
    <p class="lead">Users: <strong>{{ number_format($userCount) }}</strong> · Gift codes: <strong>{{ number_format($giftCodeCount) }}</strong></p>

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
            <small>Total MMK Paid</small>
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
    <p class="lead">Pending တွေကို approve လုပ်ပြီး KBZ/Wave/True Money လွှဲပေးပါ။</p>

    <div class="filter-nav">
        <a href="{{ route('admin.dashboard', ['status' => 'pending']) }}" @if($status === 'pending') class="is-active" @endif>Pending</a>
        <a href="{{ route('admin.dashboard', ['status' => 'approved']) }}" @if($status === 'approved') class="is-active" @endif>Approved</a>
        <a href="{{ route('admin.dashboard', ['status' => 'rejected']) }}" @if($status === 'rejected') class="is-active" @endif>Rejected</a>
    </div>

    @if ($requests->isEmpty())
        <p style="color:var(--muted);">ဒီ status အတွက် တောင်းဆိုမှု မရှိပါ။</p>
    @else
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>User</th>
                        <th>Points</th>
                        <th>MMK</th>
                        <th>Payment</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($requests as $row)
                        <tr>
                            <td>{{ $row->id }}</td>
                            <td>
                                <strong>{{ $row->user?->public_id }}</strong><br>
                                <small>{{ $row->user?->name }} ({{ $row->user?->tier }})</small>
                            </td>
                            <td>{{ number_format($row->points) }}</td>
                            <td>{{ number_format($row->mmk_amount) }}</td>
                            <td>{{ strtoupper($row->payment_method) }}<br><small>{{ $row->payment_phone }}</small></td>
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
