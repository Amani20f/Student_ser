<?php

namespace App\Services\Financial;

use App\Enums\PaymentStatusEnum;
use App\Models\Payment;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use Exception;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class PaymentService
{
    public function __construct(
        private PaymentRepositoryInterface $paymentRepository
    ) {}

    /**
     * Submit a new payment receipt.
     */
    public function submitPayment(int $studentId, array $data, ?UploadedFile $file): Payment
    {
        if ($file) {
            $path = $file->store('receipts', 'public');
            $data['receipt_image'] = $path;
        }

        $data['student_id'] = $studentId;
        $data['status'] = PaymentStatusEnum::PENDING;

        return $this->paymentRepository->create($data);
    }

    /**
     * Get payments for a student.
     */
    public function getStudentPayments(int $studentId)
    {
        return $this->paymentRepository->getStudentPayments($studentId);
    }
}
