@extends('layouts.admin')

@section('title', 'Admin Withdraws — Lotaya Shwe Oh')

@section('content')
<div class="card">
    <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;">
        <div>
            <h1>Withdraw Requests</h1>
            <p class="lead">ငွေထုတ် တောင်းဆိုမှုများ — Pending ကို approve / reject လုပ်ပါ။ (Courses မဟုတ်ပါ)</p>
        </div>
        <form method="post" action="{{ route('admin.logout') }}">
            @csrf
            <button class="btn btn-secondary" type="submit">Logout</button>
        </form>
    </div>

    @php
        $payLabels = $payLabels ?? [
            'kbz' => 'KBZ Pay',
            'wave' => 'Wave Pay',
            'true_money' => 'True Money',
        ];
    @endphp

    <div class="nav">
        <a href="{{ route('admin.withdraws', ['status' => 'all']) }}">All</a>
        <a href="{{ route('admin.withdraws', ['status' => 'pending']) }}">Pending</a>
        <a href="{{ route('admin.withdraws', ['status' => 'approved']) }}">Approved</a>
        <a href="{{ route('admin.withdraws', ['status' => 'rejected']) }}">Rejected</a>
    </div>

    @if (session('success'))
        <p style="color:#16a34a;font-weight:600;">{{ session('success') }}</p>
    @endif
    @if (session('error'))
        <p style="color:#dc2626;font-weight:600;">{{ session('error') }}</p>
    @endif

    @if ($requests->isEmpty())
        <p style="color:var(--muted);">ဒီ status အတွက် တောင်းဆိုမှု မရှိပါ။</p>
    @else
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
                                    <button class="btn" type="submit" style="margin-top:0;padding:8px 12px;">Approve</button>
                                </form>
                                <form method="post" action="{{ route('admin.withdraws.reject', $row->id) }}" style="display:inline;">
                                    @csrf
                                    <button class="btn btn-secondary" type="submit" style="margin-top:0;padding:8px 12px;">Reject</button>
                                </form>
                            @else
                            —
                            @endif
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</div>
@endsection
