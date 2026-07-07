@extends('layouts.app')

@section('title', 'Lotaya Shwe Oh — Point Exchange')

@section('content')
<div class="card">
    <h1>Lotaya Shwe Oh Point Exchange</h1>
    <p class="lead">App ထဲက User ID နဲ့ point ထုတ်ယူပါ။ အနည်းဆုံး {{ $minPoints }} points၊ {{ $step }} ဖြင့် စားပြတ်ရပါမယ်။</p>

    <div class="rates">
        @foreach ($rates as $tier => $rate)
            <div class="rate-box">
                <strong>{{ ucfirst($tier) }}</strong><br>
                1 pt = {{ $rate }} MMK
            </div>
        @endforeach
    </div>

    <form method="post" action="{{ route('exchange.submit') }}">
        @csrf
        <label for="public_id">User ID (App ထဲက Public ID)</label>
        <input id="public_id" name="public_id" value="{{ old('public_id') }}" placeholder="LSO-XXXX-XXXX" required>

        <label for="name">အမည် (optional)</label>
        <input id="name" name="name" value="{{ old('name') }}">

        <label for="email">Email</label>
        <input id="email" name="email" type="email" value="{{ old('email') }}" required>

        <label for="points">Point ပမာဏ</label>
        <input id="points" name="points" type="number" min="{{ $minPoints }}" step="{{ $step }}" value="{{ old('points', $minPoints) }}" required>

        <label for="payment_method">ငွေလက်ခံနည်း</label>
        <select id="payment_method" name="payment_method" required>
            <option value="kbz" @selected(old('payment_method') === 'kbz')>KBZ Pay</option>
            <option value="wave" @selected(old('payment_method') === 'wave')>Wave Pay</option>
            <option value="true_money" @selected(old('payment_method') === 'true_money')>True Money</option>
        </select>

        <label for="payment_phone">ငွေလက်ခံ ဖုန်းနံပါတ်</label>
        <input id="payment_phone" name="payment_phone" value="{{ old('payment_phone') }}" required>

        <button class="btn" type="submit">တောင်းဆိုမှု ပို့မည်</button>
        <a class="btn btn-secondary" href="{{ route('exchange.status.form') }}">Status စစ်မည်</a>
    </form>
</div>
@endsection
