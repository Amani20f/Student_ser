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
                
                // 1. Grade Appeals -> Move to VERIFIED (Grade Control)
                if ($payment->appeal_id && $payment->appeal) {
                    $payment->appeal->update([
                        'status' => AppealStatusEnum::VERIFIED,
                        'accountant_id' => auth()->id(),
                        'paid_at' => now(),
                    ]);

                    // Notify Grade Control
                    $this->notificationService->notifyRole(
                        'grade_control',
                        'تظلم جديد بانتظار المراجعة',
                        "تم تأكيد الدفع لتظلم الطالب {$payment->student->user->name}. يرجى المراجعة.",
                        $payment->appeal
                    );
                }

                // 2. Service Requests -> Move to RATIFIED (Student Affairs)
                if ($payment->request_id && $payment->request) {
                    $req = $payment->request;
                    if ($req->requestType && ($req->requestType->slug === 'suspension_of_enrollment' || $req->requestType->slug === 'tagyl-dras')) {
                        app(\App\Services\Request\SuspensionRequestService::class)->ratifySuspension(
                            $req,
                            auth()->user() ?: \App\Models\User::role('accountant')->first() ?: $payment->student->user,
                            true,
                            'تم التحقق من الدفع.'
                        );
                    } else {
                        $req->update([
                            'status' => RequestStatusEnum::RATIFIED,
                        ]);
                    }
                }

                // Notification
                $this->notificationService->notifyStudent(
                    $payment->student,
                    'تم تأكيد الدفع',
                    "تم تأكيد عملية الدفع الخاصة بك: {$payment->purpose}.",
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
                'تم رفض الدفعة',
                "تم رفض الدفعة الخاصة بك. السبب: {$reason}",
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
