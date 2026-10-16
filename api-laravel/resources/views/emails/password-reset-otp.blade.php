<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Password reset</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.5; color: #212121;">
    <p>Hello {{ $userName }},</p>
    <p>Your Lotaya Shwe Oh password reset code is:</p>
    <p style="font-size: 28px; letter-spacing: 6px; font-weight: bold;">{{ $otp }}</p>
    <p>This code expires in 10 minutes. If you did not request it, you can ignore this email.</p>
    <p>— Lotaya Shwe Oh</p>
</body>
</html>
