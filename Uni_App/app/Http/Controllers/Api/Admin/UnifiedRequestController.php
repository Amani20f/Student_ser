<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\StudentApplication;
use App\Models\Appeal;
use App\Models\Payment;
use App\Models\Request as ServiceRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UnifiedRequestController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $search = $request->input('search');
        $status = $request->input('status');

        $user = auth()->user();
        $userRoles = $user ? $user->getRoleNames()->toArray() : [];
        $isAdmin = in_array('admin', $userRoles);
        $isStudentAffairs = in_array('student_affairs', $userRoles);
        $isAccountant = in_array('accountant', $userRoles);
        $isGradeControl = in_array('grade_control', $userRoles);

        // 1. Student Applications (Admissions)
        $apps = collect();
        if ($isAdmin || $isStudentAffairs || $isAccountant) {
            $appQuery = StudentApplication::with('desiredProgram.department.college')
                ->orderBy('created_at', 'desc');

            if (!$isAdmin) {
                $appQuery->where(function ($q) use ($isAccountant, $isStudentAffairs) {
                    if ($isAccountant) {
                        $q->where('id', '<', 0);
                    }
                    if ($isStudentAffairs) {
                        $method = $isAccountant ? 'orWhere' : 'where';
                        $q->$method(function ($sub) {
                            $sub->whereIn('application_status', ['payment_verified', 'completed', 'rejected']);
                        });
                    }
                });
            }

            if ($status && $status !== '___all___') {
                $appQuery->where('application_status', $status);
            }
            if ($search) {
                $appQuery->where(function ($q) use ($search) {
                    $q->where('full_name', 'like', "%{$search}%")
                      ->orWhere('application_number', 'like', "%{$search}%");
                });
            }
            $apps = $appQuery->get()->map(fn ($item) => [
                'id' => $item->id,
                'original_type' => 'student_application',
                'request_type' => 'تقديم قبول',
                'request_type_en' => 'Student Application',
                'student_name' => $item->full_name,
                'submitted_date' => $item->created_at->toDateTimeString(),
                'status' => $item->application_status,
                'details' => [
                    'id' => $item->id,
                    'application_number' => $item->application_number,
                    'full_name' => $item->full_name,
                    'national_id_number' => $item->national_id_number,
                    'date_of_birth' => $item->date_of_birth?->toDateString(),
                    'gender' => $item->gender,
                    'nationality' => $item->nationality,
                    'phone_number' => $item->phone_number,
                    'email_address' => $item->email_address,
                    'address' => $item->address,
                    'desired_program' => $item->desiredProgram?->name,
                    'status' => $item->application_status,
                    'identity_document_url' => $item->identity_document_path ? asset('storage/' . $item->identity_document_path) : null,
                    'qualification_document_url' => $item->qualification_document_path ? asset('storage/' . $item->qualification_document_path) : null,
                    'personal_photo_url' => $item->personal_photo_path ? asset('storage/' . $item->personal_photo_path) : null,
                    'payment_receipt_url' => $item->payment_receipt_path ? asset('storage/' . $item->payment_receipt_path) : null,
                    'submitted_at' => $item->submitted_at?->toDateTimeString(),
                    'created_at' => $item->created_at->toDateTimeString(),
                    'rejection_reason' => $item->rejection_reason,
                ]
            ]);
        }

        // 2. Appeals (Grade Grievances)
        $appeals = collect();
        if ($isAdmin || $isGradeControl || $isAccountant) {
            $appealQuery = Appeal::with(['student.user', 'student.program', 'semester', 'items.course'])
                ->orderBy('created_at', 'desc');

            if (!$isAdmin) {
                $appealQuery->where(function ($q) use ($isGradeControl, $isAccountant) {
                    if ($isGradeControl) {
                        $q->whereIn('status', ['verified', 'approved', 'rejected']);
                    }
                    if ($isAccountant) {
                        $method = $isGradeControl ? 'orWhere' : 'where';
                        $q->$method('status', 'paid');
                    }
                });
            }

            if ($status && $status !== '___all___') {
                $appealQuery->where('status', $status);
            }
            if ($search) {
                $appealQuery->whereHas('student.user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%");
                });
            }
            $appeals = $appealQuery->get()->map(fn ($item) => [
                'id' => $item->id,
                'original_type' => 'appeal',
                'request_type' => 'تظلم درجات',
                'request_type_en' => 'Grade Grievance',
                'student_name' => $item->student?->user?->name ?? 'طالب غير معروف',
                'submitted_date' => $item->created_at->toDateTimeString(),
                'status' => $item->status instanceof \UnitEnum ? $item->status->value : $item->status,
                'details' => [
                    'id' => $item->id,
                    'student_name' => $item->student?->user?->name ?? 'طالب غير معروف',
                    'student_number' => $item->student?->student_number ?? '',
                    'program' => $item->student?->program?->name ?? null,
                    'semester_name' => $item->semester->name ?? '',
                    'status' => $item->status instanceof \UnitEnum ? $item->status->value : $item->status,
                    'student_note' => $item->student_note,
                    'committee_report' => $item->committee_report,
                    'created_at' => $item->created_at->toDateTimeString(),
                    'items' => $item->items->map(fn ($ii) => [
                        'id' => $ii->id,
                        'course_name' => $ii->course->name ?? '',
                        'course_code' => $ii->course->code ?? '',
                        'old_grade' => $ii->old_grade,
                        'new_grade' => $ii->new_grade,
                        'status' => $ii->status,
                    ])
                ]
            ]);
        }

        // 3. Payments
        $payments = collect();
        if ($isAdmin || $isAccountant) {
            $paymentQuery = Payment::with(['student.user', 'semester'])
                ->orderBy('created_at', 'desc');
            if ($status && $status !== '___all___') {
                $paymentQuery->where('status', $status);
            }
            if ($search) {
                $paymentQuery->whereHas('student.user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%");
                });
            }
            $payments = $paymentQuery->get()->map(fn ($item) => [
                'id' => $item->id,
                'original_type' => 'payment',
                'request_type' => 'طلب دفع',
                'request_type_en' => 'Payment Request',
                'student_name' => $item->student?->user?->name ?? 'طالب غير معروف',
                'submitted_date' => $item->created_at->toDateTimeString(),
                'status' => $item->status instanceof \UnitEnum ? $item->status->value : $item->status,
                'details' => [
                    'id' => $item->id,
                    'student_name' => $item->student?->user?->name ?? 'طالب غير معروف',
                    'amount' => $item->amount,
                    'purpose' => $item->purpose,
                    'semester_display' => $item->semester->name ?? '',
                    'status' => $item->status instanceof \UnitEnum ? $item->status->value : $item->status,
                    'receipt_image' => $item->receipt_image ? asset('storage/' . $item->receipt_image) : null,
                    'rejection_reason' => $item->rejection_reason,
                    'created_at' => $item->created_at->toDateTimeString(),
                ]
            ]);
        }

        // 4. Requests (Absence, Suspension, Re-enrollment, others)
        $requests = collect();
        if ($isAdmin || $isStudentAffairs || $isAccountant) {
            $reqQuery = ServiceRequest::with([
                'student.user',
                'student.program',
                'requestType',
                'absenceExcuse.items.course',
                'reEnrollmentDetail'
            ])
                ->orderBy('created_at', 'desc');

            if ($status && $status !== '___all___') {
                $reqQuery->where('status', $status);
            }
            if ($search) {
                $reqQuery->where(function ($q) use ($search) {
                    $q->whereHas('student.user', function ($q2) use ($search) {
                        $q2->where('name', 'like', "%{$search}%");
                    })->orWhere('description', 'like', "%{$search}%");
                });
            }

            // Role-based constraints for service requests
            if (!$isAdmin) {
                $reqQuery->where(function ($q) use ($isStudentAffairs, $isAccountant) {
                    if ($isStudentAffairs) {
                        $q->whereHas('requestType', function ($q2) {
                            $q2->where('target_role', 'student_affairs');
                        })->where(function ($q3) {
                            $q3->whereDoesntHave('requestType', function ($q4) {
                                $q4->whereIn('slug', ['suspension_of_enrollment', 'tagyl-dras', 're_enrollment']);
                            })->orWhere('status', '!=', \App\Enums\RequestStatusEnum::PENDING->value);
                        });
                    }

                    if ($isAccountant) {
                        $method = $isStudentAffairs ? 'orWhere' : 'where';
                        $q->$method(function ($q3) {
                            $q3->whereHas('requestType', function ($q4) {
                                $q4->whereIn('slug', ['suspension_of_enrollment', 'tagyl-dras', 're_enrollment']);
                            })->where('status', \App\Enums\RequestStatusEnum::PENDING->value);
                        });
                    }
                });
            }

            $requests = $reqQuery->get()->map(function ($item) {
                $typeName = $item->requestType->name ?? 'طلب عام';
                $slug = $item->requestType->slug ?? '';

                $originalType = 'request';
                if ($slug === 'absence_excuse' || $slug === 'aathr-ghyab') {
                    $originalType = 'absence_request';
                } elseif ($slug === 'suspension_of_enrollment' || $slug === 'tagyl-dras') {
                    $originalType = 'suspension_request';
                } elseif ($slug === 're_enrollment') {
                    $originalType = 're_enrollment_request';
                }

                $formData = $item->form_data;
                if (is_string($formData)) {
                    $formData = json_decode($formData, true);
                }

                $cleanedFormData = [];
                if (is_array($formData)) {
                    foreach ($formData as $key => $val) {
                        if ($key === 'request_type_id' || $key === 'type_id' || str_ends_with(strtolower($key), '_id')) {
                            // Check specific fields to resolve them to human-readable values
                            if ($key === 'start_semester_id') {
                                $sem = \App\Models\Semester::find($val);
                                if ($sem) {
                                    $termArabic = match($sem->term instanceof \UnitEnum ? $sem->term->value : (string) $sem->term) {
                                        'first' => 'الفصل الأول',
                                        'second' => 'الفصل الثاني',
                                        'summer' => 'الفصل الصيفي',
                                        default => $sem->term,
                                    };
                                    $cleanedFormData['فصل البدء'] = "{$termArabic} ({$sem->academic_year})";
                                } else {
                                    $cleanedFormData['فصل البدء'] = $val;
                                }
                            } elseif ($key === 'expected_end_semester_id') {
                                $sem = \App\Models\Semester::find($val);
                                if ($sem) {
                                    $termArabic = match($sem->term instanceof \UnitEnum ? $sem->term->value : (string) $sem->term) {
                                        'first' => 'الفصل الأول',
                                        'second' => 'الفصل الثاني',
                                        'summer' => 'الفصل الصيفي',
                                        default => $sem->term,
                                    };
                                    $cleanedFormData['فصل الانتهاء المتوقع'] = "{$termArabic} ({$sem->academic_year})";
                                } else {
                                    $cleanedFormData['فصل الانتهاء المتوقع'] = $val;
                                }
                            }
                            continue;
                        }

                        if ($key === 'suspension_reason') {
                            $cleanedFormData['سبب الإيقاف'] = $val;
                        } elseif ($key === 'duration_semesters') {
                            $cleanedFormData['مدة الإيقاف بالفصول'] = $val;
                        } elseif ($key === 'notes') {
                            $cleanedFormData['ملاحظات'] = $val;
                        } else {
                            $cleanKey = str_replace('_', ' ', $key);
                            $cleanedFormData[$cleanKey] = $val;
                        }
                    }
                }

                $attachment = $item->attachment;
                if (is_string($attachment)) {
                    $attachment = json_decode($attachment, true);
                }

                return [
                    'id' => $item->id,
                    'original_type' => $originalType,
                    'request_type' => $typeName,
                    'request_type_en' => $slug ?: 'Service Request',
                    'student_name' => $item->student?->user?->name ?? 'طالب غير معروف',
                    'submitted_date' => $item->created_at->toDateTimeString(),
                    'status' => $item->status instanceof \UnitEnum ? $item->status->value : $item->status,
                    'details' => [
                        'id' => $item->id,
                        'student_name' => $item->student?->user?->name ?? 'طالب غير معروف',
                        'request_type' => $typeName,
                        'request_type_slug' => $slug,
                        'program_name' => $item->student?->program?->name ?? null,
                        'level' => $item->student?->current_level ?? null,
                        'description' => $item->description,
                        'status' => $item->status instanceof \UnitEnum ? $item->status->value : $item->status,
                        'created_at' => $item->created_at->toDateTimeString(),
                        'form_data' => $cleanedFormData,
                        'attachment' => $attachment,
                        'absence_excuse' => $item->absenceExcuse ? [
                            'id' => $item->absenceExcuse->id,
                            'academic_year' => $item->absenceExcuse->academic_year,
                            'semester' => $item->absenceExcuse->semester,
                            'reason' => $item->absenceExcuse->reason,
                            'items' => $item->absenceExcuse->items->map(fn ($ii) => [
                                'id' => $ii->id,
                                'course_name' => $ii->course->name ?? '',
                                'course_code' => $ii->course->code ?? '',
                                'prev_excused_count' => $ii->prev_excused_count,
                                'prev_unexcused_count' => $ii->prev_unexcused_count,
                            ])
                        ] : null,
                    ]
                ];
            });
        }

        // Merge all
        $all = collect()
            ->concat($apps)
            ->concat($appeals)
            ->concat($payments)
            ->concat($requests)
            ->sortByDesc('submitted_date')
            ->values();

        return response()->json([
            'success' => true,
            'data' => $all
        ]);
    }
}
