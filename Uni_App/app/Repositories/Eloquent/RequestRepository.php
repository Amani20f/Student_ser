<?php

namespace App\Repositories\Eloquent;

use App\Enums\RequestStatusEnum;
use App\Models\Request;
use App\Repositories\Contracts\RequestRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class RequestRepository implements RequestRepositoryInterface
{
    public function findById(int $id): ?Request
    {
        return Request::with(['student.user', 'requestType', 'processedBy'])->find($id);
    }

    public function create(array $data): Request
    {
        return Request::create($data);
    }

    public function update(int $id, array $data): bool
    {
        $request = Request::find($id);
        if ($request) {
            return $request->update($data);
        }
        return false;
    }

    public function getStudentRequests(int $studentId): Collection
    {
        return Request::where('student_id', $studentId)
            ->with(['requestType', 'processedBy'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getPendingRequests(): Collection
    {
        return Request::whereIn('status', [RequestStatusEnum::PENDING, RequestStatusEnum::RATIFIED])
            ->with(['student.user', 'requestType'])
            ->orderBy('created_at', 'asc')
            ->get();
    }

    public function getAllRequests(): Collection
    {
        return Request::with(['student.user', 'requestType', 'processedBy'])
            ->orderBy('created_at', 'desc')
            ->get();
    }
}
