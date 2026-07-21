@extends('layouts.app')

@section('title', 'Privacy Policy — Lotaya Shwe Oh')
@section('meta_description', 'Privacy Policy for the Lotaya Shwe Oh learning app by U5AI Digital.')
@section('meta_keywords', 'Lotaya Shwe Oh privacy policy, U5AI Digital')
@section('canonical', 'https://u5aidigital.com/privacy-policy/index.html')
@section('og_title', 'Privacy Policy — Lotaya Shwe Oh')
@section('og_description', 'How Lotaya Shwe Oh collects, uses, and protects account and device data.')

@section('content')
<div class="card">
    <h1>Privacy Policy</h1>
    <p class="lead">Effective date: July 21, 2026</p>
    <p>
        The official Privacy Policy for U5AI Digital and Lotaya Shwe Oh is published at
        <a href="https://u5aidigital.com/privacy-policy/index.html" rel="noopener">https://u5aidigital.com/privacy-policy/index.html</a>.
    </p>
    <p>
        Related documents:
        <a href="https://u5aidigital.com/terms-of-use/index.html" rel="noopener">Terms of Use</a> ·
        <a href="https://u5aidigital.com/content-policy/index.html" rel="noopener">Content Policy</a> ·
        <a href="https://u5aidigital.com/account-deletion/index.html" rel="noopener">Account Deletion Policy</a>
    </p>
    <p class="lead" style="margin-top:1rem;">Summary</p>
    <p>This page is a short mirror for app users. Lotaya Shwe Oh is a learning and engagement app operated by U5AI Digital. Points are virtual learning units — not cash. The mobile app does not provide cash withdrawal.</p>
    <ul>
        <li>Account data: name, email, hashed password, optional phone</li>
        <li>App activity: points and feature history</li>
        <li>IP-based country for region access (no GPS permission)</li>
        <li>Optional AdMob advertising identifiers</li>
        <li>Optional microphone for on-device Record to Text</li>
    </ul>
    <p>
        Delete your account in the app (Profile → Delete Account), via the
        <a href="{{ route('account-deletion') }}">web deletion form</a>,
        or read the full
        <a href="https://u5aidigital.com/account-deletion/index.html" rel="noopener">Account Deletion Policy</a>.
    </p>
    <p>
        Official website: <a href="https://u5aidigital.com" rel="noopener">https://u5aidigital.com</a><br>
        Telegram: <a href="https://t.me/lotayashweoh" rel="noopener">https://t.me/lotayashweoh</a><br>
        Address: Shibazono 1-Chome 1-26, Yume House, Room 103, Kawaguchi City, Saitama 333-0854, Japan
    </p>
</div>
@endsection
