<?php

namespace App\Repositories\Eloquent;

use App\Models\Semester;
use App\Repositories\Contracts\SemesterRepositoryInterface;

class SemesterRepository implements SemesterRepositoryInterface
{
    public function findById(int $id): ?Semester
    {
        return Semester::find($id);
    }

    public function create(array $data): Semester
    {
        return Semester::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Semester::where('id', $id)->update($data);
    }

    public function getActive(): ?Semester
    {
        return Semester::where('is_active', true)->first();
    }

    public function setActive(int $id): bool
    {
        // Deactivate all semesters first
        $this->deactivateAll();
        
        // Set the specified semester as active
        return Semester::where('id', $id)->update(['is_active' => true]);
    }

    public function deactivateAll(): bool
    {
        return Semester::query()->update(['is_active' => false]);
    }
}
