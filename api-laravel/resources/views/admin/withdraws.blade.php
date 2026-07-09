@extends('layouts.admin')

@section('title', 'Admin Withdraws — Lotaya Shwe Oh')

@section('content')
<div class="card">
    <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;">
        <div>
            <h1>Withdraw Requests</h1>
            <p class="lead">Pending တွေကို approve လုပ်ပြီး KBZ/Wave လွှဲပေးပါ။</p>
        </div>
        <form method="post" action="{{ route('admin.logout') }}">
            @csrf
            <button class="btn btn-secondary" type="submit">Logout</button>
        </form>
    </div>

    <div class="nav">
        <a href="{{ route('admin.withdraws', ['status' => 'pending']) }}">Pending</a>
        <a href="{{ route('admin.withdraws', ['status' => 'approved']) }}">Approved</a>
        <a href="{{ route('admin.withdraws', ['status' => 'rejected']) }}">Rejected</a>
    </div>

    @if ($requests->isEmpty())
        <p style="color:var(--muted);">ဒီ status အတွက် တောင်းဆိုမှု မရှိပါ။</p>
    @else
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
                        <td>{{ $row->points }}</td>
                        <td>{{ number_format($row->mmk_amount) }}</td>
                        <td>{{ strtoupper($row->payment_method) }}<br><small>{{ $row->payment_phone }}</small></td>
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
