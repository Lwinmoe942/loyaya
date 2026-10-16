<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Address;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PasswordResetOtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly string $userName,
        public readonly string $otp,
    ) {}

    public function envelope(): Envelope
    {
        $from = (string) config('mail.from.address');
        $username = (string) config('mail.mailers.smtp.username');
        if ($username !== '' && str_contains($username, '@')) {
            $from = $username;
        }

        return new Envelope(
            subject: 'Lotaya Shwe Oh password reset code',
            from: $from !== '' ? new Address(
                $from,
                (string) config('mail.from.name', 'Lotaya Shwe Oh'),
            ) : null,
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.password-reset-otp',
        );
    }
}
