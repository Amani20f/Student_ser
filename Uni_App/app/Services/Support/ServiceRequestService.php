<?php

namespace App\Services\Support;

use App\Enums\RequestStatusEnum;
use App\Models\Request;
use App\Mail\RequestStatusUpdated;
use App\Repositories\Contracts\RequestRepositoryInterface;
use Illuminate\Support\Facades\Mail;
use Exception;
use Illuminate\Http\UploadedFile;

class ServiceRequestService
{
    public function __construct(
        private RequestRepositoryInterface $requestRepository,
        private \App\Services\NotificationService $notificationService
    ) {}

    /**
     * Submit a new service request.
     */
    public function submitRequest(int $studentId, array $data, ?UploadedFile $file): Request
    {
        if ($file) {
            $path = $file->store('requests', 'public');
            $data['attachment'] = $path;
        }

        $data['student_id'] = $studentId;
        $data['status'] = RequestStatusEnum::PENDING;

        return $this->requestRepository->create($data);
    }

    /**
     * Submit a new absence excuse request.
     */
    public function submitAbsenceExcuse(int $studentId, array $data, ?UploadedFile $file, array $items): Request
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($studentId, $data, $file, $items) {
            // 1. Create the base Request
            $request = $this->submitRequest($studentId, $data, $file);

            // 2. Create the AbsenceExcuse parent record
            $absenceExcuse = $request->absenceExcuse()->create([
                'academic_year' => $data['academic_year'],
                'semester' => $data['semester'],
                'reason' => $data['reason'],
            ]);

            // 3. Create AbsenceExcuseItems
            foreach ($items as $item) {
                $absenceExcuse->items()->create([
                    'course_name' => $item['course_name'],
                    'absence_date' => $item['absence_date'],
                    // prev_excused_count and prev_unexcused_count are nullable and filled by admin later
                ]);
            }

            return $request->load('absenceExcuse.items');
        });
    }

    /**
     * Ratify an absence excuse request (Staff).
     */
    public function ratifyAbsenceExcuse(int $requestId, array $itemsData, int $processedBy, ?string $responseMessage = null): bool
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($requestId, $itemsData, $processedBy, $responseMessage) {
            $request = $this->requestRepository->findById($requestId);
            if (!$request || !$request->absenceExcuse) {
                throw new Exception('Absence excuse request not found');
            }

            // Update items
            foreach ($itemsData as $itemData) {
                $item = $request->absenceExcuse->items()->find($itemData['id']);
                if ($item) {
                    $item->update([
                        'prev_excused_count' => $itemData['prev_excused_count'] ?? 0,
                        'prev_unexcused_count' => $itemData['prev_unexcused_count'] ?? 0,
                    ]);
                }
            }

            // Update status
            return $this->updateStatus($requestId, RequestStatusEnum::APPROVED, $processedBy, $responseMessage);
        });
    }

    /**
     * Update request status (Staff).
     */
    public function updateStatus(int $id, RequestStatusEnum $status, int $processedBy, ?string $responseMessage = null): bool
    {
        $request = $this->requestRepository->findById($id);
        if (!$request) {
            throw new Exception('Service request not found');
        }

        $data = [
            'status' => $status,
            'processed_by' => $processedBy,
        ];
        
        if ($responseMessage) {
            $data['response_message'] = $responseMessage;
        }

        $updated = $this->requestRepository->update($id, $data);

        if ($updated) {
            $request = $this->requestRepository->findById($id);
            
            $statusArabic = $status->value === 'approved' ? 'الموافقة على' : 'رفض';
            $title = 'تحديث حالة الطلب';
            $message = $responseMessage ?? "تم {$statusArabic} طلبك " . ($status->value === 'approved' ? '✅' : '❌');
            
            $this->notificationService->notifyStudent(
                $request->student,
                $title,
                $message,
                $request
            );

            // Keep email notification? Yes.
            // Mail::to($request->student->user->email)->send(new RequestStatusUpdated($request));
        }

        return $updated;
    }

    /**
     * Get requests for a student.
     */
    public function getStudentRequests(int $studentId)
    {
        return $this->requestRepository->getStudentRequests($studentId);
    }

    /**
     * Get all pending requests for staff review.
     */
    public function getPendingRequests()
    {
        return $this->requestRepository->getPendingRequests();
    }
}
