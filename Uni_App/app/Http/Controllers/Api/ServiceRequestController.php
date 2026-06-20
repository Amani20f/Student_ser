<?php

namespace App\Http\Controllers\Api;

use App\Enums\RequestStatusEnum;
use App\Http\Controllers\Controller;
use App\Http\Requests\Request\UpdateRequestStatusRequest;
use App\Models\Request;
use App\Models\RequestType;
use App\Models\Semester;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request as HttpRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class ServiceRequestController extends Controller
{
    /**
     * Store a new service request — supports all form types and multiple file attachments.
     * Accepts multipart/form-data OR JSON.
     */
    public function store(HttpRequest $request): JsonResponse
    {
        $requestTypeId = $request->input('request_type_id') ?? $request->input('type_id');
        
        $request->merge([
            'request_type_id' => $requestTypeId,
            'type_id' => $requestTypeId,
            'student_id' => $request->input('student_id') ?? auth()->user()?->student?->id
        ]);

        $request->validate([
            'request_type_id' => ['required', 'integer', 'exists:request_types,id'],
            'student_id' => ['required', 'integer', 'exists:students,id'],
        ]);

        $requestType = RequestType::find($requestTypeId);

        $student = auth()->user()?->student ?? \App\Models\Student::find($request->input('student_id'));
        if ($student && $student->status === \App\Enums\StudentStatusEnum::SUSPENDED) {
            if (!$requestType || $requestType->slug !== 're_enrollment') {
                return response()->json([
                    'success' => false,
                    'message' => 'عذراً، لا يمكنك تقديم هذا الطلب لأن حسابك موقوف أكاديمياً.'
                ], 403);
            }
        }

        if ($requestType && !$requestType->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'This service is currently unavailable.'
            ], 403);
        }

        if ($requestType) {
            $formRequest = null;
            if ($requestType->slug === 'absence_excuse' || $requestType->slug === 'aathr-ghyab') {
                $formRequest = new \App\Http\Requests\Request\StoreAbsenceExcuseRequest();
            } elseif ($requestType->slug === 're_enrollment') {
                $formRequest = new \App\Http\Requests\Request\StoreReEnrollmentRequest();
            } elseif ($requestType->slug === 'suspension_of_enrollment' || $requestType->slug === 'tagyl-dras') {
                $formRequest = new \App\Http\Requests\Request\StoreSuspensionRequest();
            }

            if ($formRequest) {
                // Support both flat fields and nested form_data (e.g., from Flutter JSON requests)
                $validationData = $request->all();
                if ($request->has('form_data') && is_array($request->input('form_data'))) {
                    $validationData = array_merge($validationData, $request->input('form_data'));
                }

                $validator = \Illuminate\Support\Facades\Validator::make(
                    $validationData,
                    $formRequest->rules(),
                    $formRequest->messages()
                );

                if (method_exists($formRequest, 'withValidator')) {
                    $formRequest->withValidator($validator);
                }

                $validator->validate();
            }
        }

        try {
            $student = auth()->user()?->student ?? \App\Models\Student::find($request->input('student_id'));

            // ── Collect all form_data fields ─────────────────────────
            // Support both nested JSON key "form_data" and flat multipart fields
            $formData = [];
            if ($request->has('form_data') && is_array($request->input('form_data'))) {
                $formData = $request->input('form_data');
            } else {
                // Flat fields — collect everything except reserved keys and files
                $reserved = ['request_type_id', 'description', '_method', '_token'];
                foreach ($request->except($reserved) as $key => $value) {
                    if (!$request->hasFile($key)) {
                        $formData[$key] = $value;
                    }
                }
            }

            // ── Handle multiple file attachments ──────────────────────
            $attachments = [];
            foreach ($request->allFiles() as $fieldName => $file) {
                if (is_array($file)) {
                    foreach ($file as $index => $singleFile) {
                        $path = $singleFile->store('requests', 'public');
                        $attachments["{$fieldName}_{$index}"] = $path;
                    }
                } else {
                    $path = $file->store('requests', 'public');
                    $attachments[$fieldName] = $path;
                }
            }

            // ── Build description ─────────────────────────────────────
            $requestType = RequestType::find($request->input('request_type_id'));
            $description = $request->input('description')
                ?? ($formData['reason'] ?? ($formData['absence_reason'] ?? ($requestType->name ?? 'طلب خدمة')));

            // ── Create the base Request record ────────────────────────
            if ($requestType && ($requestType->slug === 'suspension_of_enrollment' || $requestType->slug === 'tagyl-dras')) {
                $suspensionService = app(\App\Services\Request\SuspensionRequestService::class);
                $serviceRequest = $suspensionService->createSuspensionRequest(
                    array_merge([
                        'request_type_id' => $request->input('request_type_id'),
                        'description' => $description,
                        'attachment' => !empty($attachments) ? $attachments : null,
                    ], $formData),
                    $student
                );
            } elseif ($requestType && $requestType->slug === 're_enrollment') {
                $reEnrollmentService = app(\App\Services\Request\ReEnrollmentService::class);
                $serviceRequest = $reEnrollmentService->submitReEnrollment(
                    array_merge([
                        'request_type_id' => $request->input('request_type_id'),
                        'description' => $description,
                        'attachment' => !empty($attachments) ? $attachments : null,
                        'form_data' => $formData ?: null,
                    ], $formData),
                    $student
                );
            } else {
                $serviceRequest = Request::create([
                    'student_id'      => $student->id,
                    'request_type_id' => $request->input('request_type_id'),
                    'description'     => $description,
                    'status'          => RequestStatusEnum::PENDING,
                    'form_data'       => $formData ?: null,
                    'attachment'      => !empty($attachments) ? $attachments : null,
                ]);
            }

            // ── Handle Absence Excuse detail tables ───────────────────
            if ($requestType && ($requestType->slug === 'absence_excuse' || $requestType->slug === 'aathr-ghyab')) {
                $courses = $formData['courses'] ?? [];
                if (!empty($courses)) {
                    $absenceExcuse = $serviceRequest->absenceExcuse()->create([
                        'academic_year' => $formData['academic_year'] ?? '',
                        'semester'      => $formData['semester'] ?? '',
                        'reason'        => $formData['absence_reason'] ?? $formData['reason'] ?? '',
                    ]);

                    $updatedCourses = [];
                    foreach ($courses as $course) {
                        $courseId = $course['course_id'] ?? null;
                        $courseName = '';
                        if ($courseId) {
                            $dbCourse = \App\Models\Course::find($courseId);
                            if ($dbCourse) {
                                $courseName = $dbCourse->course_name;
                            }
                        }

                        $absenceExcuse->items()->create([
                            'course_id'    => $courseId,
                            'course_name'  => $courseName,
                            'absence_date' => $course['absence_date'] ?? now()->toDateString(),
                            'day'          => $course['day'] ?? null,
                        ]);

                        // Update the course array for the JSON form_data
                        $course['course_name'] = $courseName;
                        $updatedCourses[] = $course;
                    }

                    // Update form_data JSON in database to contain the resolved course names
                    $formData['courses'] = $updatedCourses;
                    $serviceRequest->update(['form_data' => $formData]);

                    $serviceRequest->load('absenceExcuse.items');
                }
            }

            $serviceRequest->load(['student', 'requestType']);

            Log::info('New service request created', [
                'request_id'   => $serviceRequest->id,
                'student_id'   => $serviceRequest->student_id,
                'request_type' => $requestType?->name,
                'status'       => 'pending',
                'timestamp'    => now()->toDateTimeString(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال الطلب بنجاح',
                'data'    => [
                    'id'           => $serviceRequest->id,
                    'request_type' => [
                        'id'   => $requestType?->id,
                        'name' => $requestType?->name,
                        'slug' => $requestType?->slug,
                    ],
                    'status'       => 'pending',
                    'form_data'    => $serviceRequest->form_data,
                    'attachment'   => $serviceRequest->attachment,
                    'submitted_at' => $serviceRequest->created_at->toDateTimeString(),
                ],
            ], 201);

        } catch (\Exception $e) {
            Log::error('Failed to create service request', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء معالجة طلبك',
                'errors'  => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }

    /**
     * Update the status of a service request (Staff).
     */
    public function updateStatus(UpdateRequestStatusRequest $request, int $id): JsonResponse
    {
        try {
            $serviceRequest = Request::with(['student', 'requestType'])->findOrFail($id);

            if (Auth::check()) {
                $serviceRequest->processed_by = Auth::id();
            }

            $status     = $request->validated('status');
            $adminNotes = $request->input('admin_notes');

            if ($status === 'approved') {
                $serviceRequest->accept($adminNotes);
            } elseif ($status === 'rejected') {
                $serviceRequest->reject((string) $adminNotes);
            } else {
                $serviceRequest->status     = RequestStatusEnum::PENDING;
                $serviceRequest->admin_notes = $adminNotes;
                $serviceRequest->save();
            }

            $serviceRequest->refresh();

            // Notify student of status change
            $statusRaw = $serviceRequest->status instanceof RequestStatusEnum 
                ? $serviceRequest->status->value 
                : (string) $serviceRequest->status;

            $statusArabic = match($statusRaw) {
                'approved' => 'مقبول',
                'rejected' => 'مرفوض',
                'pending' => 'قيد الانتظار',
                default => $statusRaw,
            };

            app(\App\Services\NotificationService::class)->notifyStudent(
                $serviceRequest->student,
                'تحديث حالة الطلب',
                "تم تحديث حالة طلبك ({$serviceRequest->requestType->name}) إلى: {$statusArabic}",
                $serviceRequest
            );

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث حالة الطلب',
                'data'    => [
                    'id'         => $serviceRequest->id,
                    'status'     => $serviceRequest->status instanceof RequestStatusEnum
                        ? $serviceRequest->status->value
                        : (string) $serviceRequest->status,
                    'admin_notes' => $serviceRequest->admin_notes,
                    'updated_at'  => $serviceRequest->updated_at->toDateTimeString(),
                ],
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['success' => false, 'message' => 'الطلب غير موجود'], 404);
        } catch (\Exception $e) {
            Log::error('Failed to update service request status', ['request_id' => $id, 'error' => $e->getMessage()]);
            return response()->json(['success' => false, 'message' => 'فشل تحديث الحالة'], 500);
        }
    }

    /**
     * Get a specific service request.
     */
    public function show(int $id): JsonResponse
    {
        try {
            $serviceRequest = Request::with(['student', 'requestType', 'processedBy', 'absenceExcuse.items'])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data'    => [
                    'id'           => $serviceRequest->id,
                    'request_type' => [
                        'id'   => $serviceRequest->requestType->id,
                        'name' => $serviceRequest->requestType->name,
                        'slug' => $serviceRequest->requestType->slug,
                    ],
                    'status'       => $serviceRequest->status instanceof RequestStatusEnum
                        ? $serviceRequest->status->value
                        : (string) $serviceRequest->status,
                    'form_data'    => $serviceRequest->form_data,
                    'attachment'   => $serviceRequest->attachment,
                    'admin_notes'  => $serviceRequest->admin_notes,
                    'submitted_at' => $serviceRequest->created_at->toDateTimeString(),
                    'updated_at'   => $serviceRequest->updated_at->toDateTimeString(),
                ],
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['success' => false, 'message' => 'الطلب غير موجود'], 404);
        }
    }

    /**
     * Get all service requests for the authenticated student.
     */
    public function studentRequests(): JsonResponse
    {
        $student  = auth()->user()->student;

        // 1. Fetch Service Requests with their linked payment
        $requests = Request::with(['requestType', 'payment'])
            ->where('student_id', $student->id)
            ->get();

        // 2. Fetch Grade Appeals with their linked payments
        $appeals = \App\Models\Appeal::with(['semester', 'payments'])
            ->where('student_id', $student->id)
            ->get();

        // 3. Map Service Requests
        $mappedRequests = $requests->map(function ($req) {
            $payment = $req->payment;
            $paymentStatus = 'unpaid';
            if ($payment) {
                $statusVal = $payment->status instanceof \App\Enums\PaymentStatusEnum 
                    ? $payment->status->value 
                    : (string) $payment->status;
                    
                $paymentStatus = match($statusVal) {
                    'verified' => 'paid',
                    'pending' => 'pending_verification',
                    'rejected' => 'rejected',
                    default => 'unpaid',
                };
            }

            $statusRaw = $req->status instanceof RequestStatusEnum
                ? $req->status->value
                : (string) $req->status;

            // Resolve attachments safely
            $attachments = [];
            if ($req->attachment) {
                if (is_array($req->attachment)) {
                    $attachments = $req->attachment;
                } elseif (is_string($req->attachment)) {
                    $decoded = json_decode($req->attachment, true);
                    $attachments = is_array($decoded) ? $decoded : [$req->attachment];
                }
            }

            return [
                'id'               => $req->id,
                'is_appeal'        => false,
                'ref_number'       => 'REF-' . $req->id,
                'request_type'     => [
                    'id'   => $req->requestType->id,
                    'name' => $req->requestType->name,
                    'slug' => $req->requestType->slug,
                    'fee'  => $req->requestType->price,
                ],
                'status'           => $statusRaw,
                'payment_status'   => $paymentStatus,
                'staff_response'   => $req->admin_notes,
                'rejection_reason' => ($statusRaw === 'rejected') ? $req->admin_notes : null,
                'description'      => $req->description,
                'attachments'      => array_map(function ($path) {
                    if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
                        return $path;
                    }
                    return asset('storage/' . $path);
                }, array_values($attachments)),
                'submitted_at'     => $req->created_at->toDateTimeString(),
                'updated_at'       => $req->updated_at->toDateTimeString(),
            ];
        });

        // 4. Map Grade Appeals
        $mappedAppeals = $appeals->map(function ($appeal) {
            $latestPayment = $appeal->payments()->latest()->first();
            $paymentStatus = 'unpaid';
            
            $appealStatusVal = $appeal->status instanceof \App\Enums\AppealStatusEnum
                ? $appeal->status->value
                : (string) $appeal->status;

            if (in_array($appealStatusVal, ['paid', 'under_review', 'verified', 'approved'])) {
                $paymentStatus = 'paid';
            } elseif ($latestPayment) {
                $statusVal = $latestPayment->status instanceof \App\Enums\PaymentStatusEnum 
                    ? $latestPayment->status->value 
                    : (string) $latestPayment->status;
                    
                $paymentStatus = match($statusVal) {
                    'verified' => 'paid',
                    'pending' => 'pending_verification',
                    'rejected' => 'rejected',
                    default => 'unpaid',
                };
            }

            // Resolve attachments safely
            $attachments = [];
            if ($appeal->attachment) {
                if (is_array($appeal->attachment)) {
                    $attachments = $appeal->attachment;
                } elseif (is_string($appeal->attachment)) {
                    $decoded = json_decode($appeal->attachment, true);
                    $attachments = is_array($decoded) ? $decoded : [$appeal->attachment];
                }
            }

            return [
                'id'               => $appeal->id,
                'is_appeal'        => true,
                'ref_number'       => 'REF-' . $appeal->id,
                'request_type'     => [
                    'id'   => 0,
                    'name' => 'تظلم درجات',
                    'slug' => 'grade_appeal',
                    'fee'  => '10.00',
                ],
                'status'           => $appealStatusVal,
                'payment_status'   => $paymentStatus,
                'staff_response'   => $appeal->committee_report,
                'rejection_reason' => ($appealStatusVal === 'rejected') ? $appeal->committee_report : null,
                'description'      => $appeal->student_note,
                'attachments'      => array_map(function ($path) {
                    if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
                        return $path;
                    }
                    return asset('storage/' . $path);
                }, array_values($attachments)),
                'submitted_at'     => $appeal->created_at->toDateTimeString(),
                'updated_at'       => $appeal->updated_at->toDateTimeString(),
            ];
        });

        // 5. Combine and sort newest first
        $unifiedRequests = $mappedRequests->concat($mappedAppeals)
            ->sortByDesc('submitted_at')
            ->values();

        return response()->json([
            'success' => true,
            'data'    => $unifiedRequests,
        ], 200);
    }
}
