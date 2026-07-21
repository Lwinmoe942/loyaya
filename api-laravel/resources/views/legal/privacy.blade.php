@extends('layouts.app')

@section('title', 'Privacy Policy — Lotaya Shwe Oh')
@section('meta_description', 'Privacy Policy for the Lotaya Shwe Oh learning and engagement app by U5AI Digital.')
@section('meta_keywords', 'Lotaya Shwe Oh privacy policy, U5AI Digital')
@section('canonical', url('/privacy'))
@section('og_title', 'Privacy Policy — Lotaya Shwe Oh')
@section('og_description', 'How Lotaya Shwe Oh collects, uses, and protects account and device data.')

@section('content')
<div class="card">
    <h1>Privacy Policy</h1>
    <p class="lead">Effective date: July 21, 2026</p>
    <p>This Privacy Policy explains how <strong>Lotaya Shwe Oh</strong> (operator: independent developer / U5AI Digital) handles information when you use the mobile app and related websites.</p>

    <h2>1. Information we collect</h2>
    <ul>
        <li><strong>Account data:</strong> name, email, password (stored hashed), optional phone number, referral codes.</li>
        <li><strong>App activity:</strong> points balance, point history, check-ins, game results, course applications, gift-code redemptions, and AI tool request history (text content you submit).</li>
        <li><strong>Technical data:</strong> IP-based country code for region access control (not precise GPS location).</li>
        <li><strong>Advertising:</strong> Google AdMob may collect advertising identifiers and device signals to show ads and measure performance.</li>
    </ul>

    <h2>2. Microphone</h2>
    <p>The optional <em>Record to Text</em> feature uses the device microphone for on-device speech recognition. Audio is processed on your device for transcription. We do not use microphone access for advertising. Converted text you choose to submit may be sent to our servers to complete the feature and may appear in your AI history.</p>

    <h2>3. How we use information</h2>
    <ul>
        <li>Provide learning features, points, and account security</li>
        <li>Prevent fraud, abuse, and blocked-region access</li>
        <li>Show optional rewarded / interstitial ads via AdMob</li>
        <li>Respond to support requests</li>
    </ul>

    <h2>4. Sharing</h2>
    <p>We do not sell your personal information. Limited data may be processed by service providers such as hosting providers and Google AdMob according to their own policies.</p>

    <h2>5. Points are not money</h2>
    <p>In-app points are virtual units for educational progress and eligible app features. They are not cash. The mobile app does not provide cash withdrawal.</p>

    <h2>6. Retention and deletion</h2>
    <p>We keep account data while your account remains active. You may delete your account in the app (Profile → Delete Account) or on the <a href="{{ route('account-deletion') }}">account deletion page</a>. Deletion removes your account and associated app data from our systems, subject to short-term backups and legal retention where required.</p>

    <h2>7. Children</h2>
    <p>Lotaya Shwe Oh is not directed at children under 13. Do not create an account if you are under the required age in your country.</p>

    <h2>8. Contact</h2>
    <p>
        Official website: <a href="https://u5aidigital.com" rel="noopener">https://u5aidigital.com</a><br>
        Telegram: <a href="https://t.me/lotayashweoh" rel="noopener">https://t.me/lotayashweoh</a><br>
        Address: Shibazono 1-Chome 1-26, Yume House, Room 103, Kawaguchi City, Saitama 333-0854, Japan
    </p>
</div>
@endsection
