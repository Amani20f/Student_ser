<?php

namespace App\Services\Financial;

use App\Enums\PaymentStatusEnum;
use App\Models\Payment;
use App\Mail\PaymentVerified;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use App\Enums\AppealStatusEnum;
use App\Enums\RequestStatusEnum;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Exception;

class PaymentVerificationService
{
    public function __construct(
        private PaymentRepositoryInterface $paymentRepository,
        private \App\Services\NotificationService $notificationService
    ) {}

    /**
     * Verify a payment.
     */
    public function verifyPayment(int $paymentId): bool
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($paymentId) {
            $payment = $this->paymentRepository->findById($paymentId);
            
            if (!$payment) {
                throw new Exception('Payment not found');
            }
            
            if ($payment->status !== PaymentStatusEnum::PENDING) {
                throw new Exception('Only pending payments can be verified');
            }
            
            $updated = $this->paymentRepository->update($paymentId, [
                'status' => PaymentStatusEnum::VERIFIED
            ]);

            if ($updated) {
                // Refresh payment to ensure relationships are accessible
                $payment->refresh();

                // workflow Integration: Move associated entities to their respective roles
                
                // 1. Grade Appeals -> Move to UNDER_REVIEW (Grade Control)
                if ($payment->appeal_id && $payment->appeal) {
                    $payment->appeal->update([
                        'status' => AppealStatusEnum::UNDER_REVIEW,
                        'accountant_id' => auth()->id(),
                        'paid_at' => now(),
                    ]);
                }

                // 2. Service Requests -> Move to PENDING (Student Affairs)
                if ($payment->request_id && $payment->request) {
                    $payment->request->update([
                        'status' => RequestStatusEnum::PENDING,
                    ]);
                }

                // Notification
                $this->notificationService->notifyStudent(
                    $payment->student,
                    'Payment Verified',
                    "Your payment for \"{$payment->purpose}\" has been successfully verified.",
                    $payment
                );

                if ($payment->student->user && $payment->student->user->email) {
                    Mail::to($payment->student->user->email)->send(new PaymentVerified($payment));
                }
            }

            return $updated;
        });
    }

    /**
     * Reject a payment.
     */
    public function rejectPayment(int $paymentId, string $reason): bool
    {
        $payment = $this->paymentRepository->findById($paymentId);
        
        if (!$payment) {
            throw new Exception('Payment not found');
        }
        
        if ($payment->status !== PaymentStatusEnum::PENDING) {
            throw new Exception('Only pending payments can be rejected');
        }
        
        $updated = $this->paymentRepository->update($paymentId, [
            'status' => PaymentStatusEnum::REJECTED,
            'rejection_reason' => $reason
        ]);

        if ($updated) {
            $payment = $this->paymentRepository->findById($paymentId);

            // Notification
            $this->notificationService->notifyStudent(
                $payment->student,
                'Payment Rejected',
                $reason,
                $payment
            );
        }

        return $updated;
    }

    /**
     * Get all pending payments for staff review.
     */
    public function getPendingPayments()
    {
        return $this->paymentRepository->getPendingPayments();
    }

    /**
     * Get all payments with filters.
     */
    public function getAllPaymentsFiltered(array $filters = [])
    {
        return $this->paymentRepository->getAllPayments($filters);
    }
}
