<?php

namespace App\Repositories\Contracts;

use App\Models\Course;
use Illuminate\Database\Eloquent\Collection;

interface CourseRepositoryInterface
{
    public function findById(int $id): ?Course;
    
    public function findByCourseCode(string $courseCode): ?Course;
    
    public function create(array $data): Course;
    
    public function update(int $id, array $data): bool;
    
    public function delete(int $id): bool;
    
    public function getBySemesterLevel(int $semesterLevel): Collection;
    
    public function getByDepartment(int $departmentId): Collection;
}
