@extends('layouts.app')

@section('title', 'Admin Login — Lotaya Shwe Oh')

@section('content')
<div class="card" style="max-width:420px;margin:0 auto;">
    <h1>Admin Login</h1>
    <p class="lead">Render dashboard ထဲက `ADMIN_API_KEY` ကို ထည့်ပါ။</p>
    <form method="post" action="{{ route('admin.login.submit') }}">
        @csrf
        <label for="admin_key">Admin API Key</label>
        <input id="admin_key" name="admin_key" type="password" required>
        <button class="btn" type="submit">ဝင်မည်</button>
    </form>
</div>
@endsection
