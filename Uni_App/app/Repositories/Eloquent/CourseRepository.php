<?php

namespace App\Repositories\Eloquent;

use App\Models\Course;
use App\Repositories\Contracts\CourseRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class CourseRepository implements CourseRepositoryInterface
{
    public function findById(int $id): ?Course
    {
        return Course::with('department')->find($id);
    }

    public function findByCourseCode(string $courseCode): ?Course
    {
        return Course::where('course_code', $courseCode)->first();
    }

    public function create(array $data): Course
    {
        return Course::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Course::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Course::destroy($id) > 0;
    }

    public function getBySemesterLevel(int $semesterLevel): Collection
    {
        return Course::where('semester_level', $semesterLevel)
            ->with('department')
            ->get();
    }

    public function getByDepartment(int $departmentId): Collection
    {
        return Course::where('department_id', $departmentId)
            ->orderBy('semester_level')
            ->get();
    }
}
