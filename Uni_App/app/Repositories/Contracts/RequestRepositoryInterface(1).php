<?php

namespace App\Repositories\Contracts;

use App\Models\Request;
use Illuminate\Database\Eloquent\Collection;

interface RequestRepositoryInterface
{
    public function findById(int $id): ?Request;
    
    public function create(array $data): Request;
    
    public function update(int $id, array $data): bool;
    
    public function getStudentRequests(int $studentId): Collection;
    
    public function getPendingRequests(): Collection;
    
    public function getAllRequests(): Collection;
}
