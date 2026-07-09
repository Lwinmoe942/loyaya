@extends('layouts.admin')

@section('title', 'Admin Login — Lotaya Shwe Oh')

@section('content')
<div class="card" style="max-width:420px;margin:0 auto;">
    <h1>Private Admin</h1>
    <p class="lead">Owner access only. Enter your personal admin password.</p>
    <form method="post" action="{{ route('admin.login.submit') }}">
        @csrf
        <label for="admin_password">Admin Password</label>
        <input id="admin_password" name="admin_password" type="password" required autocomplete="current-password">
        <button class="btn" type="submit">Sign In</button>
    </form>
</div>
@endsection
