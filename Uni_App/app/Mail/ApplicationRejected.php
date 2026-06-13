<?php

namespace App\Mail;

use App\Models\StudentApplication;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ApplicationRejected extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public StudentApplication $application,
        public string $reason
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'تحديث بخصوص طلب التسجيل الخاص بك',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.applications.rejected',
        );
    }
}
