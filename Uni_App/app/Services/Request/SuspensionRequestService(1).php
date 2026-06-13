<?php

namespace App\Services\Request;

use App\Enums\DegreeTypeEnum;
use App\Enums\RequestStatusEnum;
use App\Models\Request;
use App\Models\Semester;
use App\Models\Student;
use App\Models\SuspensionRatification;
use App\Models\User;
use Carbon\Carbon;
use Exception;

class SuspensionRequestService
{
    /**
     * Validate the 14-day deadline rule (Rule A).
     * 
     * @param int $semesterId
     * @throws Exception if deadline is not met
     */
    public function validateDeadline(int $semesterId): void
    {
        $semester = Semester::findOrFail($semesterId);

        if (!$semester->exams_start_date) {
            throw new Exception('Exam start date is not set for this semester.');
        }

        $today = Carbon::today();
        $examsStartDate = Carbon::parse($semester->exams_start_date);
        $daysDifference = $today->diffInDays($examsStartDate, false);

        if ($daysDifference < 14) {
            throw new Exception('يجب تقديم الطلب قبل أسبوعين من الامتحانات.');
        }
    }

    /**
     * Validate Level 1 restriction (Rule C).
     * 
     * @param Student $student
     * @return RequestStatusEnum
     */
    public function validateLevel1Restriction(Student $student): RequestStatusEnum
    {
        return RequestStatusEnum::PENDING;
    }

    /**
     * Validate suspension limit (Rule F).
     * 
     * @param Student $student
     * @throws Exception if suspension limit is exceeded
     */
    public function validateSuspensionLimit(Student $student): void
    {
        $acceptedSuspensions = $student->getAcceptedSuspensionCount();
        $program = $student->program;

        if (!$program) {
            throw new Exception('Student program not found.');
        }

        $limit = match ($program->degree_type) {
            DegreeTypeEnum::BACHELOR => 4,
            DegreeTypeEnum::DIPLOMA => 2,
            default => 4, // Default to bachelor limit for other degree types
        };

        if ($acceptedSuspensions >= $limit) {
            $degreeTypeName = $program->degree_type->value;
            throw new Exception("تم تجاوز الحد الأقصى لعدد فصول الإيقاف ({$limit} فصول لبرنامج {$degreeTypeName}).");
        }
    }

    /**
     * Create a suspension request with all validations.
     * 
     * @param array $data
     * @param Student $student
     * @return Request
     * @throws Exception
     */
    public function createSuspensionRequest(array $data, Student $student): Request
    {
        // Validate deadline (Rule A)
        if (isset($data['form_data']['semester'])) {
            $this->validateDeadline($data['form_data']['semester']);
        }

        // Validate suspension limit (Rule F)
        $this->validateSuspensionLimit($student);

        // Check Level 1 restriction (Rule C)
        $status = $this->validateLevel1Restriction($student);

        // Create the request
        $request = Request::create([
            'student_id' => $student->id,
            'request_type_id' => $data['request_type_id'],
            'form_data' => $data['form_data'],
            'description' => $data['description'] ?? null,
            'attachment' => $data['attachment'] ?? null,
            'status' => $status,
        ]);

        return $request;
    }

    /**
     * Ratify a suspension request (Financial Integration - Rule I).
     * 
     * @param Request $request
     * @param User $accountant
     * @param bool $oldDebtsCleared
     * @param string|null $notes
     * @return SuspensionRatification
     */
    public function ratifySuspension(
        Request $request,
        User $accountant,
        bool $oldDebtsCleared,
        ?string $notes = null
    ): SuspensionRatification {
        $ratification = SuspensionRatification::create([
            'request_id' => $request->id,
            'old_debts_cleared' => $oldDebtsCleared,
            'verified_by' => $accountant->id,
            'verified_at' => now(),
            'notes' => $notes,
        ]);

        // Automatic status update (Rule I - Automation)
        // If debts are cleared, update student status to SUSPENDED
        if ($oldDebtsCleared) {
            $student = $request->student;
            $student->status = \App\Enums\StudentStatusEnum::SUSPENDED;
            $student->save();

            // Also accept the request
            $request->accept('تم تصديق الإيقاف ولا توجد ديون سابقة.');
        }

        return $ratification;
    }

    /**
     * Get suspension details from form_data.
     * 
     * @param Request $request
     * @return array
     */
    public function getSuspensionDetails(Request $request): array
    {
        $formData = $request->form_data ?? [];

        return [
            'academic_year' => $formData['academic_year'] ?? null,
            'semester' => $formData['semester'] ?? null,
            'reason' => $formData['reason'] ?? null,
        ];
    }
}
