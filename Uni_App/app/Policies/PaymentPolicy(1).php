<?php

namespace App\Policies;

use App\Enums\PaymentStatusEnum;
use App\Models\Payment;
use App\Models\User;

class PaymentPolicy
{
    /**
     * Determine if the user can view any payments.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['admin', 'staff', 'student']);
    }

    /**
     * Determine if the user can view the payment.
     */
    public function view(User $user, Payment $payment): bool
    {
        // Students can only view their own payments
        if ($user->hasRole('student')) {
            return $user->student && $user->student->id === $payment->student_id;
        }

        // Staff and Admin can view all payments
        return $user->hasAnyRole(['admin', 'staff']);
    }

    /**
     * Determine if the user can verify the payment.
     */
    public function verify(User $user, Payment $payment): bool
    {
        // Only staff with verify-payments permission can verify
        return $user->hasRole('staff') && 
               $user->can('verify-payments') && 
               $payment->status === PaymentStatusEnum::PENDING;
    }

    /**
     * Determine if the user can reject the payment.
     */
    public function reject(User $user, Payment $payment): bool
    {
        // Only staff with verify-payments permission can reject
        return $user->hasRole('staff') && 
               $user->can('verify-payments') && 
               $payment->status === PaymentStatusEnum::PENDING;
    }
}
