<?php

namespace App\Services\Academic;

use App\Enums\GradeStatusEnum;
use App\Repositories\Contracts\GradeRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use Exception;

class GradeCalculationService
{
    public function __construct(
        private GradeRepositoryInterface $gradeRepository,
        private StudentRepositoryInterface $studentRepository
    ) {}

    /**
     * Determine grade status based on total score.
     */
    public function determineGradeStatus(float $total): GradeStatusEnum
    {
        return $total >= 60 ? GradeStatusEnum::PASSED : GradeStatusEnum::FAILED;
    }

    /**
     * Determine grade estimate based on total score.
     */
    public function determineGradeEstimate(float $total): \App\Enums\GradeEstimateEnum
    {
        if ($total >= 90) {
            return \App\Enums\GradeEstimateEnum::EXCELLENT;
        } elseif ($total >= 80) {
            return \App\Enums\GradeEstimateEnum::VERY_GOOD;
        } elseif ($total >= 70) {
            return \App\Enums\GradeEstimateEnum::GOOD;
        } elseif ($total >= 60) {
            return \App\Enums\GradeEstimateEnum::ACCEPTABLE;
        } else {
            return \App\Enums\GradeEstimateEnum::FAIL;
        }
    }

    /**
     * Validate grade component values.
     */
    public function validateScores(array $scores): void
    {
        foreach ($scores as $key => $value) {
            if ($value < 0 || $value > 100) {
                throw new Exception(ucfirst($key) . ' score must be between 0 and 100');
            }
        }
    }

    /**
     * Calculate total and GPA from components.
     */
    public function calculateTotalAndGPA(array $data): array
    {
        $total = ($data['first'] ?? 0) + ($data['second'] ?? 0) + ($data['midterm'] ?? 0) + ($data['final'] ?? 0);
        $gpa = round(($total / 100) * 4.0, 2);

        return [
            'total' => $total,
            'gpa' => $gpa,
            'status' => $this->determineGradeStatus($total),
            'grade_estimate' => $this->determineGradeEstimate($total)
        ];
    }
}
