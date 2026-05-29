<?php

namespace App\Repositories\Eloquent;

use App\Enums\GradeStatusEnum;
use App\Models\Grade;
use App\Repositories\Contracts\GradeRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class GradeRepository implements GradeRepositoryInterface
{
    public function findById(int $id): ?Grade
    {
        return Grade::with(['student', 'course', 'semester'])->find($id);
    }

    public function create(array $data): Grade
    {
        return Grade::create($data);
    }

    public function update(int $id, array $data): bool
    {
        $grade = Grade::find($id);
        if ($grade) {
            return $grade->update($data);
        }
        return false;
    }

    public function delete(int $id): bool
    {
        return Grade::destroy($id) > 0;
    }

    public function getHistoricalGrades(int $studentId): Collection
    {
        return Grade::where('student_id', $studentId)
            ->with(['course', 'semester'])
            ->orderBy('semester_id', 'desc')
            ->get();
    }

    public function getStudentGrades(int $studentId, ?int $semesterId = null): Collection
    {
        $query = Grade::where('student_id', $studentId)
            ->with(['course', 'semester']);

        if ($semesterId) {
            $query->where('semester_id', $semesterId);
        }

        return $query->get();
    }

    public function getStudentGradesBySemester(int $studentId, int $semesterId): Collection
    {
        return Grade::where('student_id', $studentId)
            ->where('semester_id', $semesterId)
            ->with('course')
            ->get();
    }

    public function getCourseGrades(int $courseId, int $semesterId): Collection
    {
        return Grade::where('course_id', $courseId)
            ->where('semester_id', $semesterId)
            ->with('student.user')
            ->get();
    }

    public function calculateStudentGPA(int $studentId): float
    {
        $grades = Grade::where('student_id', $studentId)
            ->where('status', GradeStatusEnum::PASSED)
            ->with('course')
            ->get();

        if ($grades->isEmpty()) {
            return 0.00;
        }

        $totalPoints = 0;
        $totalCreditHours = 0;

        foreach ($grades as $grade) {
            // Convert 0-100 scale to 4.0 scale
            $gradePoint = $this->convertTo4PointScale($grade->total);
            $creditHours = $grade->course->credit_hours;

            $totalPoints += $gradePoint * $creditHours;
            $totalCreditHours += $creditHours;
        }

        return $totalCreditHours > 0 
            ? round($totalPoints / $totalCreditHours, 2) 
            : 0.00;
    }

    public function findByStudentCourseSemester(int $studentId, int $courseId, int $semesterId): ?Grade
    {
        return Grade::where('student_id', $studentId)
            ->where('course_id', $courseId)
            ->where('semester_id', $semesterId)
            ->first();
    }

    public function getProgramGrades(int $programId): Collection
    {
        return Grade::whereHas('course', function($q) use ($programId) {
            $q->where('program_id', $programId);
        })
        ->with(['student.user', 'course', 'semester'])
        ->get();
    }

    /**
     * Convert 0-100 grade to 4.0 scale
     */
    private function convertTo4PointScale(float $grade): float
    {
        if ($grade >= 90) return 4.00;
        if ($grade >= 85) return 3.70;
        if ($grade >= 80) return 3.30;
        if ($grade >= 75) return 3.00;
        if ($grade >= 70) return 2.70;
        if ($grade >= 65) return 2.30;
        if ($grade >= 60) return 2.00;
        if ($grade >= 55) return 1.70;
        if ($grade >= 50) return 1.00;
        return 0.00;
    }
}
