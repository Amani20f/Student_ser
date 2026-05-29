<?php

namespace App\Repositories\Contracts;

use App\Models\Payment;
use Illuminate\Database\Eloquent\Collection;

interface PaymentRepositoryInterface
{
    public function findById(int $id): ?Payment;
    
    public function create(array $data): Payment;
    
    public function update(int $id, array $data): bool;
    
    public function getStudentPayments(int $studentId): Collection;
    
    public function getAllPayments(array $filters = []): Collection;

    public function getPendingPayments(): Collection;

    public function findPendingByStudent(int $studentId, int $semesterId): ?Payment;
}
