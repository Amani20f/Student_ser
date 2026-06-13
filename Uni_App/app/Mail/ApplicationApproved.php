<?php

namespace App\Mail;

use App\Models\StudentApplication;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ApplicationApproved extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public StudentApplication $application,
        public string $studentNumber,
        public string $tempPassword
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'تم قبول طلب التسجيل في الجامعة',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.applications.approved',
        );
    }
}
