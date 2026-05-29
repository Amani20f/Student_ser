<x-mail::message>
# Payment Verified ✅

Hello {{ $payment->student->user->name }},

We are pleased to inform you that your payment for **{{ $payment->description ?? 'University Fees' }}** has been successfully verified.

**Details:**
- **Amount:** ${{ number_format($payment->amount, 2) }}
- **Status:** Verified
- **Date:** {{ $payment->updated_at->format('M d, Y') }}

Your student balance has been updated accordingly.

Thanks,<br>
{{ config('app.name') }} Finance Team
</x-mail::message>
