<?php

namespace App\Services\Request;

use App\Enums\RequestStatusEnum;
use App\Enums\StudentStatusEnum;
use App\Models\Request;
use App\Models\ReEnrollmentDetail;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Exception;
use Illuminate\Support\Facades\DB;

class ReEnrollmentService
{
    /**
     * Submit a re-enrollment request with two file uploads.
     * 
     * @param array $data
     * @param Student $student
     * @param UploadedFile $suspensionForm
     * @param UploadedFile $universityId
     * @return Request
     * @throws Exception
     */
    public function submitReEnrollment(
        array $data,
        Student $student,
        UploadedFile $suspensionForm,
        UploadedFile $universityId
    ): Request {
        // Validate student is suspended
        if ($student->status !== StudentStatusEnum::SUSPENDED) {
            throw new Exception('لا يمكن تقديم طلب إعادة قيد إلا للطلاب الموقوفين.');
        }

        return DB::transaction(function () use ($data, $student, $suspensionForm, $universityId) {
            // Store suspension form as main attachment
            $suspensionFormPath = $suspensionForm->store('requests/re-enrollment', 'public');

            // Store university ID
            $universityIdPath = $universityId->store('requests/re-enrollment', 'public');

            // Create the request
            $request = Request::create([
                'student_id' => $student->id,
                'request_type_id' => $data['request_type_id'],
                'description' => $data['description'] ?? 'طلب إعادة قيد',
                'attachment' => $suspensionFormPath,
                'status' => RequestStatusEnum::PENDING,
            ]);

            // Create re-enrollment details
            ReEnrollmentDetail::create([
                'request_id' => $request->id,
                'student_id' => $student->id,
                'university_id_path' => $universityIdPath,
            ]);

            return $request->load('reEnrollmentDetail');
        });
    }

    /**
     * Ratify request by Student Affairs - add academic data.
     * 
     * @param Request $request
     * @param array $data
     * @param User $officer
     * @return Request
     */
    public function ratifyByStudentAffairs(Request $request, array $data, User $officer): Request
    {
        $detail = $request->reEnrollmentDetail;

        if (!$detail) {
            throw new Exception('تفاصيل إعادة القيد غير موجودة لهذا الطلب.');
        }

        $dataset = [];
        if (isset($data['major'])) $dataset['major'] = $data['major'];
        if (isset($data['level'])) $dataset['academic_level'] = $data['level'];
        if (isset($data['batch'])) $dataset['batch'] = $data['batch'];
        if (isset($data['academic_year'])) $dataset['academic_year'] = $data['academic_year'];

        if (!empty($dataset)) {
            $detail->update($dataset);
        }

        return $request->load('reEnrollmentDetail');
    }

    /**
     * Ratify request by Accountant - add fee data.
     * 
     * @param Request $request
     * @param array $feeData
     * @param User $accountant
     * @return Request
     */
    public function ratifyByAccountant(Request $request, array $feeData, User $accountant): Request
    {
        $detail = $request->reEnrollmentDetail;

        if (!$detail) {
            throw new Exception('تفاصيل إعادة القيد غير موجودة لهذا الطلب.');
        }

        $dataset = [];
        if (isset($feeData['university_fees'])) $dataset['university_fees'] = $feeData['university_fees'];
        if (isset($feeData['other_fees'])) $dataset['other_fees'] = $feeData['other_fees'];

        if (!empty($dataset)) {
            $detail->update($dataset);
        }

        return $request->load('reEnrollmentDetail');
    }

    /**
     * Approve re-enrollment request - triggers automatic status restoration.
     * 
     * @param Request $request
     * @param User $approver
     * @return Request
     */
    public function approveReEnrollment(Request $request, User $approver): Request
    {
        // Accept the request
        $request->accept('تمت الموافقة على طلب إعادة القيد.', false);
        $request->processed_by = $approver->id;
        $request->save();

        // Status restoration will be handled automatically by RequestObserver
        
        return $request;
    }

    /**
     * Get re-enrollment details from relational table.
     * 
     * @param Request $request
     * @return array
     */
    public function getReEnrollmentDetails(Request $request): array
    {
        $detail = $request->reEnrollmentDetail;
        
        if (!$detail) {
            return [];
        }

        return [
            'university_id_path' => $detail->university_id_path,
            'major' => $detail->major,
            'level' => $detail->academic_level,
            'batch' => $detail->batch,
            'academic_year' => $detail->academic_year,
            'university_fees' => $detail->university_fees,
            'other_fees' => $detail->other_fees,
        ];
    }
}
