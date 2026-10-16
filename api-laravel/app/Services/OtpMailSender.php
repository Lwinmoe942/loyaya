<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\View;
use RuntimeException;

class OtpMailSender
{
    public function send(string $toEmail, string $userName, string $otp): void
    {
        $html = View::make('emails.password-reset-otp', [
            'userName' => $userName,
            'otp' => $otp,
        ])->render();
        $subject = 'Lotaya Shwe Oh password reset code';
        $fromEmail = $this->fromAddress();
        $fromName = (string) config('mail.from.name', 'Lotaya Shwe Oh');

        if (filled(config('services.brevo.key'))) {
            $this->sendViaBrevo($toEmail, $userName, $fromEmail, $fromName, $subject, $html);

            return;
        }

        if (filled(config('services.resend.key'))) {
            $this->sendViaResend($toEmail, $fromEmail, $fromName, $subject, $html);

            return;
        }

        Mail::html($html, function ($message) use ($toEmail, $subject, $fromEmail, $fromName) {
            $message->to($toEmail)->subject($subject)->from($fromEmail, $fromName);
        });
    }

    public function hasHttpMailer(): bool
    {
        return filled(config('services.brevo.key')) || filled(config('services.resend.key'));
    }

    private function fromAddress(): string
    {
        $from = (string) config('mail.from.address');
        $username = (string) config('mail.mailers.smtp.username');
        if ($username !== '' && str_contains($username, '@')) {
            return $username;
        }

        return $from !== '' ? $from : 'noreply@u5aidigital.com';
    }

    private function sendViaBrevo(
        string $toEmail,
        string $userName,
        string $fromEmail,
        string $fromName,
        string $subject,
        string $html,
    ): void {
        $response = Http::timeout(20)
            ->withHeaders([
                'api-key' => (string) config('services.brevo.key'),
                'accept' => 'application/json',
                'content-type' => 'application/json',
            ])
            ->post('https://api.brevo.com/v3/smtp/email', [
                'sender' => ['name' => $fromName, 'email' => $fromEmail],
                'to' => [['email' => $toEmail, 'name' => $userName]],
                'subject' => $subject,
                'htmlContent' => $html,
            ]);

        if ($response->failed()) {
            throw new RuntimeException('BREVO_FAILED: '.$response->body());
        }
    }

    private function sendViaResend(
        string $toEmail,
        string $fromEmail,
        string $fromName,
        string $subject,
        string $html,
    ): void {
        $response = Http::timeout(20)
            ->withToken((string) config('services.resend.key'))
            ->acceptJson()
            ->post('https://api.resend.com/emails', [
                'from' => $fromName.' <'.$fromEmail.'>',
                'to' => [$toEmail],
                'subject' => $subject,
                'html' => $html,
            ]);

        if ($response->failed()) {
            throw new RuntimeException('RESEND_FAILED: '.$response->body());
        }
    }
}
