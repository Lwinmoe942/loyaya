@extends('layouts.app')

@section('title', 'Withdraw Status — Lotaya Shwe Oh')

@section('content')
<div class="card">
    <h1>တောင်းဆိုမှု Status</h1>
    <p class="lead">တောင်းဆိုခဲ့တဲ့ email နဲ့ စစ်ဆေးပါ။</p>

    <form method="post" action="{{ route('exchange.status.check') }}">
        @csrf
        <label for="email">Email</label>
        <input id="email" name="email" type="email" value="{{ $email ?? old('email') }}" required>
        <button class="btn" type="submit">စစ်ဆေးမည်</button>
        <a class="btn btn-secondary" href="{{ route('exchange.index') }}">Exchange သို့</a>
    </form>

    @isset($requests)
        @if ($requests->isEmpty())
            <p style="margin-top:18px;color:var(--muted);">ဒီ email နဲ့ တောင်းဆိုမှု မရှိသေးပါ။</p>
        @else
            <table>
                <thead>
                    <tr>
                        <th>#</th>
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
                            <td>{{ $row->id }}</td>
                            <td>{{ $row->points }}</td>
                            <td>{{ number_format($row->mmk_amount) }}</td>
                            <td>{{ strtoupper($row->payment_method) }}</td>
                            <td>
                                <span class="badge badge-{{ $row->status }}">{{ $row->status }}</span>
                            </td>
                            <td>{{ $row->created_at?->format('Y-m-d H:i') }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    @endisset
</div>
@endsection
