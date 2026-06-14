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

    public function validateLevel1Restriction(Student $student): void
    {
        if ($student->current_level <= 1) {
            throw new Exception('First year students are not allowed to submit academic suspension requests.');
        }
    }

    /**
     * Validate active status.
     */
    public function validateActiveStatus(Student $student): void
    {
        if ($student->status !== \App\Enums\StudentStatusEnum::ACTIVE) {
            throw new Exception('Only active students can submit academic suspension requests.');
        }
    }

    /**
     * Validate no pending suspension requests exist.
     */
    public function validateNoPendingSuspension(Student $student): void
    {
        $hasPending = Request::where('student_id', $student->id)
            ->whereHas('requestType', function ($q) {
                $q->where('slug', 'suspension_of_enrollment');
            })
            ->where('status', RequestStatusEnum::PENDING)
            ->exists();

        if ($hasPending) {
            throw new Exception('You already have a pending suspension request.');
        }
    }

    /**
     * Calculate expected end semester.
     */
    public function calculateExpectedEndSemester(int $startSemesterId, int $durationSemesters): int
    {
        $startSemester = Semester::findOrFail($startSemesterId);

        // Get all semesters ordered by start_date starting from the selected semester
        $subsequentSemesters = Semester::where('start_date', '>=', $startSemester->start_date)
            ->orderBy('start_date', 'asc')
            ->limit($durationSemesters + 1)
            ->get();

        // If we found enough semesters, pick the one after duration. If not, fallback to the last one available
        if ($subsequentSemesters->count() > $durationSemesters) {
            return $subsequentSemesters[$durationSemesters]->id;
        }

        return $subsequentSemesters->last()->id;
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
        // 1. Status Check
        $this->validateActiveStatus($student);

        // 2. Pending Request Check
        $this->validateNoPendingSuspension($student);

        // 3. Level Check
        $this->validateLevel1Restriction($student);

        // 4. Deadline Check
        $this->validateDeadline($data['start_semester_id']);

        // 5. Suspension Limit Check
        $this->validateSuspensionLimit($student);

        // 6. Calculate expected end semester
        $expectedEndId = $this->calculateExpectedEndSemester($data['start_semester_id'], $data['duration_semesters']);

        // Format data to store in form_data JSON
        $formData = [
            'suspension_reason'        => $data['suspension_reason'],
            'start_semester_id'        => $data['start_semester_id'],
            'duration_semesters'       => $data['duration_semesters'],
            'expected_end_semester_id' => $expectedEndId,
            'notes'                    => $data['notes'] ?? null,
        ];

        // Create the request
        $request = Request::create([
            'student_id'      => $student->id,
            'request_type_id' => $data['request_type_id'],
            'form_data'       => $formData,
            'description'     => 'طلب إيقاف قيد مؤقت',
            'attachment'      => $data['attachment'] ?? null,
            'status'          => RequestStatusEnum::PENDING,
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

        // Just update status to RATIFIED, do not approve yet.
        $request->status = RequestStatusEnum::RATIFIED;
        $request->save();

        // Notify student it has been ratified (optional, but good for transparency)
        app(\App\Services\NotificationService::class)->notifyStudent(
            $request->student,
            'تحديث حالة الطلب',
            "تمت المصادقة المالية على طلب الإيقاف، وهو الآن قيد المراجعة النهائية من شؤون الطلاب.",
            $request
        );

        return $ratification;
    }

    /**
     * Approve a suspension request (Final step by Student Affairs).
     */
    public function approveSuspension(Request $request, User $officer, ?string $notes = null): Request
    {
        // Must be ratified first
        $ratification = $request->suspensionRatifications()->latest()->first();
        if (!$ratification) {
            throw new Exception('لا يمكن الموافقة النهائية قبل تصديق المحاسب.');
        }

        if (!$ratification->old_debts_cleared) {
            throw new Exception('لا يمكن الموافقة: توجد مديونيات سابقة لم يتم تسويتها.');
        }

        $student = $request->student;
        $student->status = \App\Enums\StudentStatusEnum::SUSPENDED;
        $student->save();

        $request->accept($notes ?? 'تمت الموافقة على طلب الإيقاف نهائياً.');
        $request->processed_by = $officer->id;
        $request->save();

        return $request;
    }

    public function getSuspensionDetails(Request $request): array
    {
        $formData = $request->form_data ?? [];

        return [
            'suspension_reason'        => $formData['suspension_reason'] ?? null,
            'start_semester_id'        => $formData['start_semester_id'] ?? null,
            'duration_semesters'       => $formData['duration_semesters'] ?? null,
            'expected_end_semester_id' => $formData['expected_end_semester_id'] ?? null,
            'notes'                    => $formData['notes'] ?? null,
        ];
    }
}
