@extends('layouts.app')

@section('title', 'Withdraw Status — Lotaya Shwe Oh')
@section('meta_description', 'Check withdraw status for your Lotaya Shwe Oh point exchange requests.')
@section('canonical', url('/exchange/status'))

@section('content')
@php
    $payLabels = [
        'kbz' => 'KBZ Pay',
        'wave' => 'Wave Pay',
        'true_money' => 'True Money',
    ];
@endphp

<div class="card">
    <h1>Withdraw Status</h1>
    <p class="lead">တောင်းဆိုထားသော withdraw များကို email ဖြင့် စစ်ဆေးပါ။</p>

    <form method="get" action="{{ route('exchange.status.form') }}">
        <div class="field">
            <label for="email">Email</label>
            <input id="email" name="email" type="email" value="{{ $email ?? old('email') }}" required>
        </div>
        <div class="btn-row">
            <button class="btn btn-green" type="submit">Check Status</button>
            <a class="btn btn-outline" href="{{ route('exchange.index') }}">Point Exchange</a>
        </div>
    </form>

    @isset($statusError)
        <div class="empty-state" style="margin-top:16px;">{{ $statusError }}</div>
    @endisset

    @isset($requests)
        @if ($requests->isEmpty())
            <div class="empty-state" style="margin-top:16px;">ဤ email ဖြင့် တောင်းဆိုမှု မတွေ့ပါ။</div>
        @else
            <div class="table-wrap" style="margin-top:16px;">
                <table>
                    <thead>
                        <tr>
                            <th>Order #</th>
                            <th>Points</th>
                            <th>MMK</th>
                            <th>Method</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($requests as $row)
                            <tr>
                                <td>#{{ $row->id }}</td>
                                <td>{{ number_format($row->points) }}</td>
                                <td>{{ number_format($row->mmk_amount) }}</td>
                                <td>{{ $payLabels[$row->payment_method] ?? $row->payment_method }}</td>
                                <td><span class="badge badge-{{ $row->status }}">{{ $row->status }}</span></td>
                                <td>{{ $row->created_at?->format('Y-m-d H:i') }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    @endisset
</div>

<div class="card">
    <h2>Status လမ်းညွှန်</h2>
    <p class="lead" style="margin-bottom:0;">
        <strong>Pending</strong> — တောင်းဆိုမှု လက်ခံပြီး စစ်ဆေးနေသည်။<br>
        <strong>Approved</strong> — ငွေလွှဲပြီးပါပြီ။<br>
        <strong>Rejected</strong> — ငြင်းပယ်ခံရပြီး points ပြန်ရရှိပါမည်။
    </p>
</div>
@endsection
