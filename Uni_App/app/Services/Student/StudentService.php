<?php

namespace App\Services\Student;

use App\Repositories\Contracts\GradeRepositoryInterface;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;

class StudentService
{
    public function __construct(
        private StudentRepositoryInterface $studentRepository,
        private GradeRepositoryInterface $gradeRepository,
        private PaymentRepositoryInterface $paymentRepository
    ) {}

    /**
     * Get student profile with related data.
     */
    public function getStudentProfile(int $studentId): array
    {
        $student = $this->studentRepository->findById($studentId);
        
        if (!$student) {
            throw new \Exception('Student not found');
        }
        
        return [
            'student' => $student,
            'total_credit_hours' => $this->calculateTotalCreditHours($studentId),
            'passed_courses' => $this->gradeRepository->getStudentGrades($studentId)->where('status', 'passed')->count(),
        ];
    }

    /**
     * Get student grades for a specific semester.
     */
    public function getGrades(int $studentId, ?int $semesterId = null)
    {
        return $this->gradeRepository->getStudentGrades($studentId, $semesterId);
    }

    /**
     * Get student payments.
     */
    public function getPayments(int $studentId)
    {
        return $this->paymentRepository->getStudentPayments($studentId);
    }

    /**
     * Calculate total credit hours earned.
     */
    private function calculateTotalCreditHours(int $studentId): int
    {
        $passedGrades = $this->gradeRepository->getStudentGrades($studentId)
            ->where('status', 'passed');
        
        $totalHours = 0;
        foreach ($passedGrades as $grade) {
            $totalHours += $grade->course->credit_hours;
        }
        
        return $totalHours;
    }
}
