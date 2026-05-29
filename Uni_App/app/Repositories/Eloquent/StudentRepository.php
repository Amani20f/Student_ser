<?php

namespace App\Repositories\Eloquent;

use App\Models\Student;
use App\Repositories\Contracts\StudentRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class StudentRepository implements StudentRepositoryInterface
{
    public function findById(int $id): ?Student
    {
        return Student::with(['user', 'program'])->find($id);
    }

    public function findByStudentNumber(string $studentNumber): ?Student
    {
        return Student::where('student_number', $studentNumber)->first();
    }

    public function findByUserId(int $userId): ?Student
    {
        return Student::where('user_id', $userId)->first();
    }

    public function create(array $data): Student
    {
        return Student::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Student::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Student::destroy($id) > 0;
    }

    public function getByProgram(int $programId): Collection
    {
        return Student::where('program_id', $programId)
            ->with('user')
            ->get();
    }

    public function getByLevel(int $level): Collection
    {
        return Student::where('current_level', $level)
            ->with(['user', 'program'])
            ->get();
    }

    public function updateGPA(int $studentId, float $gpa): bool
    {
        return Student::where('id', $studentId)->update(['gpa' => $gpa]);
    }
}
