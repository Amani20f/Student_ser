<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StudentApplication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class StudentApplicationController extends Controller
{
    /**
     * POST /api/apply
     * Accepts new student registration application.
     * Public — no auth required.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'full_name'              => 'required|string|max:255',
            'national_id_number'     => 'required|string|max:50|unique:student_applications,national_id_number',
            'date_of_birth'          => 'required|date|before:today',
            'gender'                 => 'required|in:male,female',
            'nationality'            => 'required|string|max:100',
            'phone_number'           => 'required|string|max:20',
            'email_address'          => 'required|email|max:255|unique:student_applications,email_address',
            'address'                => 'nullable|string|max:500',
            'desired_program_id'     => 'required|exists:programs,id',
            'desired_academic_level' => 'nullable|integer|between:1,8',
            // Document uploads
            'identity_document'      => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'qualification_document' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'personal_photo'         => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
        ]);

        try {
            $data = $request->only([
                'full_name', 'national_id_number', 'date_of_birth',
                'gender', 'nationality', 'phone_number', 'email_address',
                'address', 'desired_program_id', 'desired_academic_level',
            ]);

            // Upload documents
            if ($request->hasFile('identity_document')) {
                $data['identity_document_path'] = $request->file('identity_document')
                    ->store('applications/identity', 'public');
            }
            if ($request->hasFile('qualification_document')) {
                $data['qualification_document_path'] = $request->file('qualification_document')
                    ->store('applications/qualifications', 'public');
            }
            if ($request->hasFile('personal_photo')) {
                $data['personal_photo_path'] = $request->file('personal_photo')
                    ->store('applications/photos', 'public');
            }

            $data['application_number'] = StudentApplication::generateApplicationNumber();
            $data['application_status'] = 'pending';
            $data['submitted_at']        = now();

            $application = StudentApplication::create($data);

            Log::info('New student application received', [
                'application_number' => $application->application_number,
                'name'               => $application->full_name,
                'program_id'         => $application->desired_program_id,
            ]);

            return response()->json([
                'success'            => true,
                'message'            => 'تم إرسال طلب التسجيل بنجاح. سيتم التواصل معك قريباً.',
                'application_number' => $application->application_number,
            ], 201);

        } catch (\Exception $e) {
            Log::error('Student application failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إرسال الطلب',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * GET /api/apply/{application_number}/status
     * Check application status publicly (no auth).
     */
    public function checkStatus(string $applicationNumber): JsonResponse
    {
        $application = StudentApplication::where('application_number', $applicationNumber)
            ->with('desiredProgram.department.college')
            ->first();

        if (!$application) {
            return response()->json([
                'success' => false,
                'message' => 'رقم الطلب غير صحيح',
            ], 404);
        }

        $statusLabels = [
            'pending'   => 'قيد المراجعة',
            'submitted' => 'تم استلامه',
            'completed' => 'مكتمل — تم القبول',
        ];

        return response()->json([
            'success' => true,
            'data'    => [
                'application_number' => $application->application_number,
                'full_name'          => $application->full_name,
                'status'             => $application->application_status,
                'status_label'       => $statusLabels[$application->application_status] ?? $application->application_status,
                'desired_program'    => $application->desiredProgram?->name,
                'college'            => $application->desiredProgram?->department?->college?->name,
                'submitted_at'       => $application->submitted_at?->toDateString(),
            ],
        ]);
    }
}
