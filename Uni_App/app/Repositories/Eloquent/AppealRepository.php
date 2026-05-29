<?php

namespace App\Repositories\Eloquent;

use App\Models\Appeal;
use App\Models\AppealItem;
use App\Repositories\Contracts\AppealRepositoryInterface;

class AppealRepository implements AppealRepositoryInterface
{
    public function create(array $data)
    {
        return Appeal::create($data);
    }

    public function findById(int $id)
    {
        return Appeal::with(['items.course', 'student.user', 'semester', 'payments'])->find($id);
    }

    public function getStudentAppeals(int $studentId)
    {
        return Appeal::where('student_id', $studentId)
            ->with(['items.course', 'semester'])
            ->latest()
            ->get();
    }

    public function getAppeals(array $filters = [])
    {
        $query = Appeal::query()
            ->with(['items.course', 'student.user', 'student.program', 'semester', 'payments'])
            ->latest();

        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        return $query->get();
    }

    public function getAppealsByStatus(string $status)
    {
        return $this->getAppeals(['status' => $status]);
    }

    public function update(int $id, array $data)
    {
        $appeal = Appeal::findOrFail($id);
        $appeal->update($data);
        return $appeal;
    }

    public function createItem(array $data)
    {
        return AppealItem::create($data);
    }
}
