<?php

namespace App\Repositories\Contracts;

interface AppealRepositoryInterface
{
    public function create(array $data);
    public function findById(int $id);
    public function getStudentAppeals(int $studentId);
    public function getAppealsByStatus(string $status);
    public function getAppeals(array $filters = []);
    public function update(int $id, array $data);
    public function createItem(array $data);
}
