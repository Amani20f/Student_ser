<?php

namespace App\Repositories\Contracts;

use App\Models\Semester;

interface SemesterRepositoryInterface
{
    public function findById(int $id): ?Semester;
    
    public function create(array $data): Semester;
    
    public function update(int $id, array $data): bool;
    
    public function getActive(): ?Semester;
    
    public function setActive(int $id): bool;
    
    public function deactivateAll(): bool;
}
