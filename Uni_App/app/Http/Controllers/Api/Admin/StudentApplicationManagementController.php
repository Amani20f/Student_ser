<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\StudentApplication;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class StudentApplicationManagementController extends Controller
{
    /**
     * GET /api/admin/applications
     * List all student applications with filters.
     */
    public function index(Request $request): JsonResponse
    {
        $query = StudentApplication::with('desiredProgram.department.college')
            ->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('application_status', $request->input('status'));
        }

        $applications = $query->get();

        return response()->json([
            'success' => true,
            'data'    => $applications->map(fn ($app) => [
                'id'                 => $app->id,
                'application_number' => $app->application_number,
                'full_name'          => $app->full_name,
                'email_address'      => $app->email_address,
                'phone_number'       => $app->phone_number,
                'gender'             => $app->gender,
                'nationality'        => $app->nationality,
                'date_of_birth'      => $app->date_of_birth?->toDateString(),
                'status'             => $app->application_status,
                'desired_program'    => $app->desiredProgram?->name,
                'department'         => $app->desiredProgram?->department?->name,
                'college'            => $app->desiredProgram?->department?->college?->name,
                'submitted_at'       => $app->submitted_at?->toDateTimeString(),
                'has_identity_doc'   => !empty($app->identity_document_path),
                'has_qualification'  => !empty($app->qualification_document_path),
                'has_photo'          => !empty($app->personal_photo_path),
            ]),
        ]);
    }

    /**
     * GET /api/admin/applications/{id}
     * Get a single application details.
     */
    public function show(int $id): JsonResponse
    {
        $app = StudentApplication::with('desiredProgram.department.college')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => [
                'id'                        => $app->id,
                'application_number'        => $app->application_number,
                'full_name'                 => $app->full_name,
                'national_id_number'        => $app->national_id_number,
                'date_of_birth'             => $app->date_of_birth?->toDateString(),
                'gender'                    => $app->gender,
                'nationality'               => $app->nationality,
                'phone_number'              => $app->phone_number,
                'email_address'             => $app->email_address,
                'address'                   => $app->address,
                'desired_program'           => [
                    'id'         => $app->desiredProgram?->id,
                    'name'       => $app->desiredProgram?->name,
                    'department' => $app->desiredProgram?->department?->name,
                    'college'    => $app->desiredProgram?->department?->college?->name,
                ],
                'desired_academic_level'    => $app->desired_academic_level,
                'status'                    => $app->application_status,
                'identity_document_url'     => $app->identity_document_path
                    ? asset('storage/' . $app->identity_document_path) : null,
                'qualification_document_url'=> $app->qualification_document_path
                    ? asset('storage/' . $app->qualification_document_path) : null,
                'personal_photo_url'        => $app->personal_photo_path
                    ? asset('storage/' . $app->personal_photo_path) : null,
                'submitted_at'              => $app->submitted_at?->toDateTimeString(),
                'created_at'                => $app->created_at->toDateTimeString(),
            ],
        ]);
    }

    /**
     * POST /api/admin/applications/{id}/approve
     * Approve application → creates user + student accounts automatically.
     */
    public function approve(int $id): JsonResponse
    {
        $app = StudentApplication::with('desiredProgram')->findOrFail($id);

        if ($app->application_status === 'completed') {
            return response()->json(['success' => false, 'message' => 'هذا الطلب تم قبوله مسبقاً'], 422);
        }

        DB::beginTransaction();
        try {
            // Generate a student number
            $studentNumber = 'STU-' . now()->year . '-' . str_pad(
                Student::count() + 1, 4, '0', STR_PAD_LEFT
            );

            // Generate a temporary password
            $tempPassword = Str::random(8);

            // Create user account
            $user = User::create([
                'name'     => $app->full_name,
                'username' => $studentNumber,
                'email'    => $app->email_address,
                'password' => Hash::make($tempPassword),
                'role'     => 'student',
            ]);

            // Create student record
            $student = Student::create([
                'user_id'       => $user->id,
                'program_id'    => $app->desired_program_id,
                'student_number'=> $studentNumber,
                'phone'         => $app->phone_number,
                'current_level' => $app->desired_academic_level ?? 1,
                'status'        => 'active',
            ]);

            // Update application status
            $app->update(['application_status' => 'completed']);

            DB::commit();

            Log::info('Student application approved', [
                'application_number' => $app->application_number,
                'student_number'     => $studentNumber,
                'user_id'            => $user->id,
            ]);

            return response()->json([
                'success'        => true,
                'message'        => 'تم قبول الطالب وإنشاء حسابه بنجاح',
                'student_number' => $studentNumber,
                'email'          => $app->email_address,
                'temp_password'  => $tempPassword,
                'student_id'     => $student->id,
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Failed to approve student application', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'فشل إنشاء الحساب: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * POST /api/admin/applications/{id}/reject
     * Reject application.
     */
    public function reject(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:1000',
        ], [
            'rejection_reason.required' => 'يرجى كتابة سبب الرفض.',
        ]);

        $app = StudentApplication::findOrFail($id);
        $app->update([
            'application_status' => 'rejected',
            'rejection_reason'   => $request->input('rejection_reason'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم رفض طلب التسجيل بنجاح',
        ]);
    }
}
