<?php

namespace App\Services\Academic;

use App\Enums\AppealStatusEnum;
use App\Enums\PaymentStatusEnum;
use App\Models\Appeal;
use App\Repositories\Contracts\AppealRepositoryInterface;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use App\Repositories\Contracts\GradeRepositoryInterface;
use App\Models\Student;
use Exception;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;

class AppealService
{
    public function __construct(
        private AppealRepositoryInterface $appealRepository,
        private PaymentRepositoryInterface $paymentRepository,
        private GradeRepositoryInterface $gradeRepository,
        private GradeManagementService $gradeManagementService
    ) {}

    /**
     * Create a new grade appeal.
     */
    public function createAppeal(Student $student, array $data): Appeal
    {
        return DB::transaction(function () use ($student, $data) {
            $appealData = [
                'student_id' => $student->id,
                'semester_id' => $data['semester_id'],
                'academic_year' => $data['academic_year'],
                'term' => $data['term'],
                'status' => AppealStatusEnum::PENDING_PAYMENT,
                'student_note' => $data['student_note'] ?? null,
            ];

            $appeal = $this->appealRepository->create($appealData);

            foreach ($data['items'] as $item) {
                // Snapshot current grades if they exist
                $currentGrade = $this->gradeRepository->findByStudentCourseSemester(
                    $student->id,
                    $item['course_id'],
                    $data['semester_id']
                );

                $this->appealRepository->createItem([
                    'appeal_id' => $appeal->id,
                    'course_id' => $item['course_id'],
                    'coursework_before' => $currentGrade ? ($currentGrade->first + $currentGrade->second + $currentGrade->midterm) : null,
                    'final_before' => $currentGrade ? $currentGrade->final : null,
                    'total_before' => $currentGrade ? $currentGrade->total : null,
                ]);
            }

            return $appeal;
        });
    }

    /**
     * Submit payment for an appeal.
     */
    public function submitAppealPayment(Student $student, array $data, UploadedFile $file)
    {
        return DB::transaction(function () use ($student, $data, $file) {
            $appeal = $this->appealRepository->findById($data['appeal_id']);
            
            if (!$appeal || $appeal->student_id !== $student->id) {
                throw new Exception("Appeal not found or not owned by student.");
            }

            if ($appeal->status !== AppealStatusEnum::PENDING_PAYMENT) {
                throw new Exception("This appeal is not pending payment.");
            }

            // Create payment
            $receiptPath = $file->store('receipts', 'public');
            
            $payment = $this->paymentRepository->create([
                'student_id' => $student->id,
                'semester_id' => $data['semester_id'],
                'amount' => $data['amount'],
                'purpose' => "Grade Appeal Fee - Appeal #{$appeal->id}",
                'receipt_image' => $receiptPath,
                'status' => PaymentStatusEnum::PENDING,
                'appeal_id' => $appeal->id,
            ]);

            // Update appeal status to PAID
            $this->appealRepository->update($appeal->id, [
                'status' => AppealStatusEnum::PAID
            ]);

            return $payment;
        });
    }

    /**
     * Get appeals pending payment verification (status = PAID).
     */
    public function getPaidAppeals()
    {
        return $this->appealRepository->getAppealsByStatus(AppealStatusEnum::PAID->value);
    }

    /**
     * Verify appeal payment.
     */
    public function verifyPayment(int $appealId, int $userId, string $decision, ?string $reason = null)
    {
        return DB::transaction(function () use ($appealId, $userId, $decision, $reason) {
            $appeal = $this->appealRepository->findById($appealId);
            
            if (!$appeal || $appeal->status !== AppealStatusEnum::PAID) {
                throw new Exception("Appeal not found or not in PAID status.");
            }

            if ($decision === 'approved') {
                $this->appealRepository->update($appealId, [
                    'status' => AppealStatusEnum::UNDER_REVIEW,
                    'accountant_id' => $userId,
                    'paid_at' => now(),
                ]);
                
                // Also verify the linked payment
                $payment = $appeal->payments()->where('status', PaymentStatusEnum::PENDING)->first();
                if ($payment) {
                    $this->paymentRepository->update($payment->id, ['status' => PaymentStatusEnum::VERIFIED]);
                }
            } else {
                $this->appealRepository->update($appealId, [
                    'status' => AppealStatusEnum::REJECTED,
                    'accountant_id' => $userId,
                ]);

                $payment = $appeal->payments()->where('status', PaymentStatusEnum::PENDING)->first();
                if ($payment) {
                    $this->paymentRepository->update($payment->id, [
                        'status' => PaymentStatusEnum::REJECTED,
                        'rejection_reason' => $reason
                    ]);
                }
            }

            return $appeal->fresh();
        });
    }

    /**
     * Get appeals under review.
     */
    public function getUnderReviewAppeals()
    {
        return $this->appealRepository->getAppealsByStatus(AppealStatusEnum::UNDER_REVIEW->value);
    }

    /**
     * Get all appeals with filters.
     */
    public function getAppealsFiltered(array $filters = [])
    {
        return $this->appealRepository->getAppeals($filters);
    }

    /**
     * Review appeal decision.
     */
    public function reviewAppeal(int $appealId, int $userId, string $decision, array $data)
    {
        return DB::transaction(function () use ($appealId, $userId, $decision, $data) {
            $appeal = $this->appealRepository->findById($appealId);
            
            if (!$appeal) {
                throw new Exception("Appeal with ID {$appealId} not found.");
            }

            if ($appeal->status !== AppealStatusEnum::UNDER_REVIEW && $appeal->status !== AppealStatusEnum::PAID) {
                throw new Exception("Appeal #{$appealId} cannot be reviewed because its current status is '{$appeal->status->value}'. It must be 'under_review' or 'paid'.");
            }

            if ($decision === 'approved') {
                // Update marks for each item
                foreach ($data['items'] as $itemData) {
                    $item = $appeal->items()->find($itemData['appeal_item_id']);
                    if ($item) {
                        $item->update([
                            'coursework_after' => $itemData['coursework_after'] ?? null,
                            'final_after' => $itemData['final_after'] ?? null,
                            'total_after' => $itemData['total_after'] ?? null,
                            'absence_percentage' => $itemData['absence_percentage'] ?? null,
                        ]);
                    }
                }

                $this->appealRepository->update($appealId, [
                    'status' => AppealStatusEnum::APPROVED,
                    'reviewed_by' => $userId,
                    'reviewed_at' => now(),
                    'committee_report' => $data['committee_report'] ?? null,
                ]);

                // Apply changes to the main grades table
                $this->applyGradeChanges($appeal->fresh());
            } else {
                $this->appealRepository->update($appealId, [
                    'status' => AppealStatusEnum::REJECTED,
                    'reviewed_by' => $userId,
                    'reviewed_at' => now(),
                    'committee_report' => $data['committee_report'] ?? null,
                ]);
            }

            return $appeal->fresh();
        });
    }

    /**
     * Apply appeal changes to the actual grades table.
     */
    private function applyGradeChanges(Appeal $appeal)
    {
        foreach ($appeal->items as $item) {
            // Check if any change was provided
            if ($item->coursework_after === null && $item->final_after === null) {
                continue;
            }

            $grade = $this->gradeRepository->findByStudentCourseSemester(
                $appeal->student_id,
                $item->course_id,
                $appeal->semester_id
            );

            if ($grade) {
                $updateData = [];

                // Mapping coursework_after to midterm and zeroing out first/second
                // to match the requested coursework update logic.
                if ($item->coursework_after !== null) {
                    $updateData['first'] = 0;
                    $updateData['second'] = 0;
                    $updateData['midterm'] = $item->coursework_after;
                }

                if ($item->final_after !== null) {
                    $updateData['final'] = $item->final_after;
                }

                // If total_after was specified, recalculation in GradeManagementService 
                // will ensure it matches first + second + midterm + final.
                
                $this->gradeManagementService->updateGrade($grade->id, $updateData);
            }
        }
    }
}
