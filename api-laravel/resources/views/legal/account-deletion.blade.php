@extends('layouts.app')

@section('title', 'Delete Account — Lotaya Shwe Oh')
@section('meta_description', 'Request deletion of your Lotaya Shwe Oh account and associated data.')
@section('meta_keywords', 'Lotaya Shwe Oh delete account, account deletion')
@section('canonical', url('/account-deletion'))
@section('og_title', 'Delete Account — Lotaya Shwe Oh')
@section('og_description', 'Delete your Lotaya Shwe Oh account and associated data.')
@section('robots', 'noindex,follow')

@section('content')
<div class="card">
    <h1>Delete Account</h1>
    <p class="lead">Use this page if you no longer have the app installed, or prefer to delete your account on the web.</p>

    <p>Deleting your account permanently removes your profile, points history, and related app data. This cannot be undone.</p>

    <p>You can also delete from the app: <strong>Profile → Delete Account</strong>.</p>

    @if (session('status'))
        <div class="empty-state" style="margin-top:16px;color:var(--ok);">{{ session('status') }}</div>
    @endif

    @if ($errors->any())
        <div class="empty-state" style="margin-top:16px;color:var(--danger);">
            {{ $errors->first() }}
        </div>
    @endif

    <form method="post" action="{{ route('account-deletion.submit') }}" style="margin-top:16px;">
        @csrf
        <div class="field">
            <label for="email">Account email</label>
            <input id="email" name="email" type="email" value="{{ old('email') }}" required autocomplete="username">
        </div>
        <div class="field">
            <label for="password">Password</label>
            <input id="password" name="password" type="password" required autocomplete="current-password">
        </div>
        <div class="btn-row">
            <button class="btn btn-green" type="submit" style="background:var(--danger);border-color:var(--danger);">
                Delete my account
            </button>
            <a class="btn btn-outline" href="{{ route('privacy') }}">Privacy Policy</a>
        </div>
    </form>
</div>
@endsection
