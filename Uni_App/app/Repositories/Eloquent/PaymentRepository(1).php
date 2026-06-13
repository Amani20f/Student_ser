<?php

namespace App\Repositories\Eloquent;

use App\Enums\PaymentStatusEnum;
use App\Models\Payment;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class PaymentRepository implements PaymentRepositoryInterface
{
    public function findById(int $id): ?Payment
    {
        return Payment::with(['student.user', 'semester'])->find($id);
    }

    public function create(array $data): Payment
    {
        return Payment::create($data);
    }

    public function update(int $id, array $data): bool
    {
        $payment = Payment::find($id);
        if ($payment) {
            return $payment->update($data);
        }
        return false;
    }

    public function getStudentPayments(int $studentId): Collection
    {
        return Payment::where('student_id', $studentId)
            ->with(['semester'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getAllPayments(array $filters = []): Collection
    {
        $query = Payment::with(['student.user', 'semester']);

        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (!empty($filters['student_id'])) {
            $studentId = $filters['student_id'];
            $query->whereHas('student', function ($q) use ($studentId) {
                $q->where('student_number', 'like', '%' . $studentId . '%');
            });
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    public function getPendingPayments(): Collection
    {
        return Payment::where('status', PaymentStatusEnum::PENDING)
            ->with(['student.user', 'semester'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function findPendingByStudent(int $studentId, int $semesterId): ?Payment
    {
        return Payment::where('student_id', $studentId)
            ->where('semester_id', $semesterId)
            ->where('status', PaymentStatusEnum::PENDING)
            ->first();
    }
}
