<?php

namespace App\Repositories\Contracts;

use App\Models\Grade;
use Illuminate\Database\Eloquent\Collection;

interface GradeRepositoryInterface
{
    public function findById(int $id): ?Grade;
    
    public function create(array $data): Grade;
    
    public function update(int $id, array $data): bool;
    
    public function delete(int $id): bool;

    public function getHistoricalGrades(int $studentId): Collection;

    public function getStudentGrades(int $studentId, ?int $semesterId = null): Collection;
    
    public function getStudentGradesBySemester(int $studentId, int $semesterId): Collection;
    
    public function getCourseGrades(int $courseId, int $semesterId): Collection;
    
    public function calculateStudentGPA(int $studentId): float;
    
    public function findByStudentCourseSemester(int $studentId, int $courseId, int $semesterId): ?Grade;

    public function getProgramGrades(int $programId): Collection;
}
