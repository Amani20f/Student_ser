<?php

namespace App\Repositories\Contracts;

use App\Models\Student;
use Illuminate\Database\Eloquent\Collection;

interface StudentRepositoryInterface
{
    public function findById(int $id): ?Student;
    
    public function findByStudentNumber(string $studentNumber): ?Student;
    
    public function findByUserId(int $userId): ?Student;
    
    public function create(array $data): Student;
    
    public function update(int $id, array $data): bool;
    
    public function delete(int $id): bool;
    
    public function getByProgram(int $programId): Collection;
    
    public function getByLevel(int $level): Collection;
    
    public function updateGPA(int $studentId, float $gpa): bool;
}
