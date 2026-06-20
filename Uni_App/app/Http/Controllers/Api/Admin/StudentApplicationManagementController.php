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
        $query = StudentApplication::with([
            'desiredProgram.department.college',
            'firstChoiceProgram.department.college',
            'secondChoiceProgram.department.college',
            'thirdChoiceProgram.department.college',
            'approvedProgram.department.college'
        ])->orderBy('created_at', 'desc');

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
                'first_choice_program' => $app->firstChoiceProgram?->name,
                'second_choice_program' => $app->secondChoiceProgram?->name,
                'third_choice_program' => $app->thirdChoiceProgram?->name,
                'approved_program'    => $app->approvedProgram?->name,
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
        $app = StudentApplication::with([
            'desiredProgram.department.college',
            'firstChoiceProgram.department.college',
            'secondChoiceProgram.department.college',
            'thirdChoiceProgram.department.college',
            'approvedProgram.department.college'
        ])->findOrFail($id);

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
                'first_choice_program'      => [
                    'id'         => $app->firstChoiceProgram?->id,
                    'name'       => $app->firstChoiceProgram?->name,
                    'department' => $app->firstChoiceProgram?->department?->name,
                    'college'    => $app->firstChoiceProgram?->department?->college?->name,
                ],
                'second_choice_program'     => [
                    'id'         => $app->secondChoiceProgram?->id,
                    'name'       => $app->secondChoiceProgram?->name,
                    'department' => $app->secondChoiceProgram?->department?->name,
                    'college'    => $app->secondChoiceProgram?->department?->college?->name,
                ],
                'third_choice_program'      => [
                    'id'         => $app->thirdChoiceProgram?->id,
                    'name'       => $app->thirdChoiceProgram?->name,
                    'department' => $app->thirdChoiceProgram?->department?->name,
                    'college'    => $app->thirdChoiceProgram?->department?->college?->name,
                ],
                'approved_program'          => [
                    'id'         => $app->approvedProgram?->id,
                    'name'       => $app->approvedProgram?->name,
                    'department' => $app->approvedProgram?->department?->name,
                    'college'    => $app->approvedProgram?->department?->college?->name,
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
    public function approve(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'approved_program_id' => 'required|exists:programs,id',
        ]);

        $approvedProgramId = $request->input('approved_program_id');

        DB::beginTransaction();
        try {
            // Lock the application row for update inside the transaction
            $app = StudentApplication::where('id', $id)->lockForUpdate()->first();

            if (!$app) {
                DB::rollBack();
                return response()->json(['success' => false, 'message' => 'لم يتم العثور على طلب التسجيل'], 404);
            }

            if ($app->application_status === 'completed') {
                DB::rollBack();
                return response()->json(['success' => false, 'message' => 'هذا الطلب تم قبوله مسبقاً'], 422);
            }

            if ($app->application_status !== 'payment_verified') {
                DB::rollBack();
                return response()->json(['success' => false, 'message' => 'لا يمكن قبول الطلب قبل التحقق من الدفع من المحاسب.'], 422);
            }

            // Check that approved_program_id is one of the student's choices
            if (!in_array((int)$approvedProgramId, [
                (int)$app->first_choice_program_id,
                (int)$app->second_choice_program_id,
                (int)$app->third_choice_program_id
            ])) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'التخصص المعتمد يجب أن يكون أحد الرغبات الثلاث للطالب.'
                ], 422);
            }

            // Generate a unique student number
            $num = Student::count() + 1;
            do {
                $studentNumber = 'STU-' . now()->year . '-' . str_pad($num, 4, '0', STR_PAD_LEFT);
                $num++;
            } while (Student::where('student_number', $studentNumber)->exists());

            // Create user account
            $user = User::create([
                'name'     => $app->full_name,
                'username' => $app->email_address,
                'email'    => $app->email_address,
                'password' => Hash::make($app->national_id_number),
                'role'     => 'student',
            ]);

            $user->assignRole('student');

            // Create student record
            $student = Student::create([
                'user_id'       => $user->id,
                'program_id'    => $approvedProgramId,
                'student_number'=> $studentNumber,
                'phone'         => $app->phone_number,
                'current_level' => $app->desired_academic_level ?? 1,
                'status'        => 'active',
                'national_id'   => $app->national_id_number,
                'gender'        => $app->gender,
                'nationality'   => $app->nationality,
                'date_of_birth' => $app->date_of_birth,
            ]);

            // Update application status
            $app->update([
                'application_status' => 'completed',
                'approved_program_id' => $approvedProgramId,
            ]);

            DB::commit();

            Log::info('Student application approved', [
                'application_number' => $app->application_number,
                'student_number'     => $studentNumber,
                'user_id'            => $user->id,
                'approved_program_id'=> $approvedProgramId,
            ]);

            return response()->json([
                'success'        => true,
                'message'        => 'تم قبول الطالب وإنشاء حسابه بنجاح',
                'student_number' => $studentNumber,
                'email'          => $app->email_address,
                'temp_password'  => $app->national_id_number,
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

    /**
     * PUT /api/admin/applications/{id}/verify-payment
     * Verify payment for application (Accountant only)
     */
    public function verifyPayment(Request $request, int $id): JsonResponse
    {
        $app = StudentApplication::findOrFail($id);
        
        if ($app->application_status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن التحقق من الدفع لأن حالة الطلب ليست قيد الانتظار.',
            ], 400);
        }

        $app->update([
            'application_status' => 'payment_verified',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم التحقق من الدفع بنجاح.',
        ]);
    }
}
