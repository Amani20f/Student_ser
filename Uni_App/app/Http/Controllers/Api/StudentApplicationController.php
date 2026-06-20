<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StudentApplication;
use App\Models\Student;
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
        // Extract certificate type and grade percentage first to compute eligible count
        $certificateType = null;
        $gradePercentage = null;

        if ($request->has('certificate_type')) {
            $certificateType = $request->input('certificate_type');
        }
        if ($request->has('grade_percentage')) {
            $gradePercentage = $request->input('grade_percentage');
        }

        if ($request->has('form_responses')) {
            $formResponses = json_decode($request->input('form_responses'), true);
            if (is_array($formResponses)) {
                if (!$certificateType && isset($formResponses['previous_major'])) {
                    $certificateType = $formResponses['previous_major'];
                }
                if (!$gradePercentage && isset($formResponses['grade_percentage'])) {
                    $gradePercentage = $formResponses['grade_percentage'];
                }
            }
        }

        if ($certificateType) {
            $certificateType = strtolower($certificateType);
        }

        // Fetch all active/available programs and count how many this student is eligible for
        $allPrograms = \App\Models\Program::where('is_available', true)->get();
        $eligibleProgramsCount = 0;

        foreach ($allPrograms as $prog) {
            if ($certificateType && $gradePercentage !== null) {
                $isEligibleCertificate = false;
                if ($prog->certificate_type === 'both') {
                    $isEligibleCertificate = in_array($certificateType, ['scientific', 'literary']);
                } else {
                    $isEligibleCertificate = ($prog->certificate_type === $certificateType);
                }

                $isEligibleGrade = ($gradePercentage >= $prog->minimum_percentage);

                if ($isEligibleCertificate && $isEligibleGrade) {
                    $eligibleProgramsCount++;
                }
            } else {
                $eligibleProgramsCount = 3;
            }
        }

        // Auto-fill choices for legacy requests if not provided
        if (!$request->has('first_choice_program_id') && $request->has('desired_program_id')) {
            $desired = $request->input('desired_program_id');
            $otherPrograms = [];
            foreach ($allPrograms as $prog) {
                if ($prog->id == $desired) continue;
                if ($certificateType && $gradePercentage !== null) {
                    $isEligibleCertificate = ($prog->certificate_type === 'both' || $prog->certificate_type === $certificateType);
                    $isEligibleGrade = ($gradePercentage >= $prog->minimum_percentage);
                    if ($isEligibleCertificate && $isEligibleGrade) {
                        $otherPrograms[] = $prog->id;
                    }
                }
            }
            
            // Normalize Arabic digits in phone_number
            if ($request->has('phone_number')) {
                $phone = $request->input('phone_number');
                $arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
                $english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
                $normalized = str_replace($arabic, $english, $phone);
                $normalized = preg_replace('/[^\d+]/', '', $normalized);
                $request->merge(['phone_number' => $normalized]);
            }

            $request->merge([
                'first_choice_program_id' => $desired,
                'second_choice_program_id' => isset($otherPrograms[0]) ? $otherPrograms[0] : null,
                'third_choice_program_id' => isset($otherPrograms[1]) ? $otherPrograms[1] : null,
            ]);
        }

        $rules = [
            'full_name'              => 'required|string|max:255',
            'national_id_number'     => 'required|string|max:50|unique:student_applications,national_id_number',
            'date_of_birth'          => 'required|date|before:today',
            'gender'                 => 'required|in:male,female',
            'nationality'            => 'required|string|max:100',
            'phone_number'           => 'required|string|min:8|max:15',
            'email_address'          => 'required|email|max:255|unique:student_applications,email_address',
            'address'                => 'nullable|string|max:500',
            'desired_program_id'     => 'required|exists:programs,id',
            'first_choice_program_id'  => 'required|exists:programs,id',
            'desired_academic_level' => 'nullable|integer|between:1,8',
            // Document uploads
            'identity_document'      => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'qualification_document' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'personal_photo'         => 'required|file|mimes:jpg,jpeg,png|max:2048',
            'payment_receipt'        => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ];

        if ($eligibleProgramsCount >= 2) {
            $rules['second_choice_program_id'] = 'required|exists:programs,id';
        } else {
            $rules['second_choice_program_id'] = 'nullable|exists:programs,id';
        }

        if ($eligibleProgramsCount >= 3) {
            $rules['third_choice_program_id'] = 'required|exists:programs,id';
        } else {
            $rules['third_choice_program_id'] = 'nullable|exists:programs,id';
        }

        $request->validate($rules, [
            'national_id_number.unique' => 'رقم الهوية أو الإقامة مسجل مسبقاً في النظام.',
            'email_address.unique'      => 'البريد الإلكتروني مسجل مسبقاً في النظام.',
            'national_id_number.required' => 'رقم الهوية مطلوب.',
            'email_address.required'    => 'البريد الإلكتروني مطلوب.',
        ]);

        // Validate duplicates
        $firstChoice = $request->input('first_choice_program_id');
        $secondChoice = $request->input('second_choice_program_id');
        $thirdChoice = $request->input('third_choice_program_id');

        $providedChoices = array_filter([$firstChoice, $secondChoice, $thirdChoice]);
        if (count($providedChoices) !== count(array_unique($providedChoices))) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن اختيار نفس التخصص في أكثر من رغبة.'
            ], 422);
        }

        // Validate Program Eligibility for all provided choices
        $choices = [];
        if ($firstChoice) $choices['الرغبة الأولى'] = $firstChoice;
        if ($secondChoice) $choices['الرغبة الثانية'] = $secondChoice;
        if ($thirdChoice) $choices['الرغبة الثالثة'] = $thirdChoice;

        foreach ($choices as $label => $programId) {
            $prog = \App\Models\Program::find($programId);
            if (!$prog || !$prog->is_available) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطالب غير مؤهل لهذا التخصص حسب نوع الثانوية أو النسبة.'
                ], 422);
            }

            if ($certificateType && $gradePercentage !== null) {
                $isEligibleCertificate = false;
                if ($prog->certificate_type === 'both') {
                    $isEligibleCertificate = in_array($certificateType, ['scientific', 'literary']);
                } else {
                    $isEligibleCertificate = ($prog->certificate_type === $certificateType);
                }

                $isEligibleGrade = ($gradePercentage >= $prog->minimum_percentage);

                if (!$isEligibleCertificate || !$isEligibleGrade) {
                    return response()->json([
                        'success' => false,
                        'message' => 'الطالب غير مؤهل لهذا التخصص حسب نوع الثانوية أو النسبة.'
                    ], 422);
                }
            }
        }

        try {
            $data = $request->only([
                'full_name', 'national_id_number', 'date_of_birth',
                'gender', 'nationality', 'phone_number', 'email_address',
                'address', 'desired_program_id', 'desired_academic_level',
                'first_choice_program_id', 'second_choice_program_id', 'third_choice_program_id',
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
            if ($request->hasFile('payment_receipt')) {
                $data['payment_receipt_path'] = $request->file('payment_receipt')
                    ->store('applications/receipts', 'public');
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
            'rejected'  => 'مرفوض',
        ];

        $responseData = [
            'application_status' => $application->application_status,
            'status_label'       => $statusLabels[$application->application_status] ?? $application->application_status,
            'applicant_name'     => $application->full_name,
            'program_name'       => $application->desiredProgram?->name,
        ];

        if ($application->application_status === 'pending' || $application->application_status === 'submitted') {
            $responseData['submitted_at'] = $application->submitted_at?->toDateString();
        } elseif ($application->application_status === 'rejected') {
            $responseData['rejection_reason'] = $application->rejection_reason;
        } elseif ($application->application_status === 'completed') {
            $student = Student::where('national_id', $application->national_id_number)->first();
            if ($student) {
                $responseData['student_number'] = $student->student_number;
            }
            $responseData['email'] = $application->email_address;
            $responseData['username'] = $application->email_address;
            $responseData['temp_password'] = $application->national_id_number;
            $responseData['temp_password_message'] = 'يرجى استخدام هذه البيانات لتسجيل الدخول وتغيير كلمة المرور بعد أول دخول.';
        }

        return response()->json([
            'success' => true,
            'data'    => $responseData,
        ]);
    }

    /**
     * GET /api/apply/status/{nationalId}
     * Check application status using National ID or Passport.
     */
    public function checkStatusByNationalId(string $nationalId): JsonResponse
    {
        // Sort by id DESC to get the most recent in case of legacy duplicates
        $application = StudentApplication::where('national_id_number', $nationalId)
            ->with('desiredProgram.department.college')
            ->orderBy('id', 'desc')
            ->first();

        if (!$application) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على طلب لهذه الهوية/الجواز',
            ], 404);
        }
        
        // If there are multiple, log a warning
        if (StudentApplication::where('national_id_number', $nationalId)->count() > 1) {
            Log::warning("Multiple applications found for national ID: {$nationalId}");
        }

        $statusLabels = [
            'pending'   => 'قيد المراجعة',
            'submitted' => 'تم استلامه',
            'completed' => 'مكتمل — تم القبول',
            'rejected'  => 'مرفوض',
        ];
        
        $responseData = [
            'application_status' => $application->application_status,
            'status_label'       => $statusLabels[$application->application_status] ?? $application->application_status,
            'applicant_name'     => $application->full_name,
            'program_name'       => $application->desiredProgram?->name,
        ];
        
        if ($application->application_status === 'pending' || $application->application_status === 'submitted') {
            $responseData['submitted_at'] = $application->submitted_at?->toDateString();
        } elseif ($application->application_status === 'rejected') {
            $responseData['rejection_reason'] = $application->rejection_reason;
        } elseif ($application->application_status === 'completed') {
            $student = Student::where('national_id', $nationalId)->first();
            if ($student) {
                $responseData['student_number'] = $student->student_number;
            }
            $responseData['email'] = $application->email_address;
            $responseData['username'] = $application->email_address;
            $responseData['temp_password'] = $application->national_id_number;
            $responseData['temp_password_message'] = 'يرجى استخدام هذه البيانات لتسجيل الدخول وتغيير كلمة المرور بعد أول دخول.';
        }

        return response()->json([
            'success' => true,
            'data'    => $responseData,
        ]);
    }
}
