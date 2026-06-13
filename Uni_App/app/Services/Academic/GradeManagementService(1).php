<?php

namespace App\Services\Academic;

use App\Models\Grade;
use App\Mail\GradeUpdated;
use App\Repositories\Contracts\GradeRepositoryInterface;
use Illuminate\Support\Facades\Mail;
use Exception;

class GradeManagementService
{
    public function __construct(
        private GradeRepositoryInterface $gradeRepository,
        private GradeCalculationService $gradeCalculationService,
        private \App\Repositories\Contracts\ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Create a new grade record.
     */
    public function createGrade(array $data): array
    {
        // Validate components
        $this->gradeCalculationService->validateScores([
            'first' => $data['first'] ?? 0,
            'second' => $data['second'] ?? 0,
            'midterm' => $data['midterm'] ?? 0,
            'final' => $data['final'] ?? 0,
        ]);
        
        // Calculate total and GPA
        $calcData = $this->gradeCalculationService->calculateTotalAndGPA($data);
        $data = array_merge($data, $calcData);
        
        // Check if grade already exists
        if ($this->gradeRepository->exists($data['student_id'], $data['course_id'], $data['semester_id'])) {
            throw new Exception('Grade already exists for this student, course, and semester');
        }
        
        // Create grade
        $grade = $this->gradeRepository->create($data);
        
        return [
            'grade' => $grade,
        ];
    }

    /**
     * Update an existing grade record.
     */
    public function updateGrade(int $gradeId, array $data): array
    {
        $grade = $this->gradeRepository->findById($gradeId);
        
        if (!$grade) {
            throw new Exception('Grade not found');
        }
        
        // Merge with existing to recalculate total
        $mergedData = array_merge($grade->toArray(), $data);
        
        // Validate
        $this->gradeCalculationService->validateScores([
            'first' => $mergedData['first'] ?? 0,
            'second' => $mergedData['second'] ?? 0,
            'midterm' => $mergedData['midterm'] ?? 0,
            'final' => $mergedData['final'] ?? 0,
        ]);
        
        $calcData = $this->gradeCalculationService->calculateTotalAndGPA($mergedData);
        $data = array_merge($data, $calcData);
        
        // Update grade
        $this->gradeRepository->update($gradeId, $data);
        
        $updatedGrade = $this->gradeRepository->findById($gradeId);

        // Log the activity
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'action' => 'updated_grade',
            'model_type' => Grade::class,
            'subject_id' => $gradeId,
            'old_values' => [
                'first' => $grade->first,
                'second' => $grade->second,
                'midterm' => $grade->midterm,
                'final' => $grade->final,
                'total' => $grade->total,
                'gpa' => $grade->gpa,
            ],
            'new_values' => [
                'first' => $updatedGrade->first,
                'second' => $updatedGrade->second,
                'midterm' => $updatedGrade->midterm,
                'final' => $updatedGrade->final,
                'total' => $updatedGrade->total,
                'gpa' => $updatedGrade->gpa,
            ],
        ]);

        Mail::to($updatedGrade->student->user->email)->send(new GradeUpdated($updatedGrade));

        return [
            'success' => true,
            'data' => $updatedGrade
        ];
    }

    /**
     * Get student historical grades.
     */
    public function getStudentGrades(int $userId): array
    {
        $user = \App\Models\User::find($userId);
        if (!$user || !$user->student) {
            throw new Exception('Student record not found');
        }

        $grades = $this->gradeRepository->getHistoricalGrades($user->student->id);
        
        return $grades->groupBy('semester_id')->toArray();
    }

    /**
     * Get all grades for a specific program.
     */
    public function getProgramGrades(int $programId): \Illuminate\Database\Eloquent\Collection
    {
        return $this->gradeRepository->getProgramGrades($programId);
    }
}
