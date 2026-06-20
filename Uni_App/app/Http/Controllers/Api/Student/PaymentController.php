<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Models\Semester;
use App\Services\Financial\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(
        private PaymentService $paymentService
    ) {}

    /**
     * Submit a payment receipt.
     * semester_id is optional — defaults to the latest active semester.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'amount'           => 'required|numeric|min:0',
            'purpose'          => 'required|string|max:255|regex:/^[^<>\/]+$/',
            'receipt_image'    => 'required|file|mimes:jpeg,png,jpg,pdf|max:5120',
            'semester_id'      => 'nullable|exists:semesters,id',
            'ref_number'       => 'nullable|string|max:100',
            'payment_category' => 'nullable|string|in:grievance,appeal,stop_enrollment,re_enrollment,tuition_fee,student_card',
        ]);

        try {
            $paymentCategory = $request->input('payment_category');
            $isRefRequired = false;
            if ($paymentCategory) {
                $isRefRequired = in_array($paymentCategory, ['grievance', 'appeal', 'stop_enrollment', 're_enrollment']);
            } else {
                $purpose = strtolower($request->input('purpose', ''));
                if (
                    str_contains($purpose, 'تظلم') || str_contains($purpose, 'appeal') || str_contains($purpose, 'grievance') ||
                    str_contains($purpose, 'إيقاف') || str_contains($purpose, 'stop') || str_contains($purpose, 'suspend') ||
                    str_contains($purpose, 'إعادة') || str_contains($purpose, 're_enroll') || str_contains($purpose, 're-enroll')
                ) {
                    $isRefRequired = true;
                }
            }

            if ($isRefRequired && !$request->filled('ref_number')) {
                return response()->json(['error' => 'الرقم المرجعي مطلوب لهذا النوع من المدفوعات.'], 422);
            }

            // Auto-resolve semester_id to the latest semester if not provided
            $semesterId = $request->input('semester_id');
            if (!$semesterId) {
                $latestSemester = Semester::orderBy('created_at', 'desc')->first();
                if (!$latestSemester) {
                    return response()->json(['error' => 'لا يوجد فصل دراسي نشط في النظام.'], 422);
                }
                $semesterId = $latestSemester->id;
            }

            $data = $request->only(['amount', 'purpose']);
            $data['semester_id'] = $semesterId;

            // Enforce reference number validation
            if ($request->filled('ref_number')) {
                $refNumber = trim($request->input('ref_number'));
                $requestId = null;

                if (preg_match('/^([a-zA-Z]+)-(\d+)$/', $refNumber, $matches)) {
                    $requestId = (int) $matches[2];
                } elseif (preg_match('/^APP-\d{4}-[A-Z0-9]{6}$/i', $refNumber)) {
                    $app = \App\Models\StudentApplication::where('application_number', $refNumber)->first();
                    if (!$app) {
                        return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                    }
                    
                    $student = auth()->user()->student;
                    if ($app->national_id_number !== $student->national_id_number && $app->email_address !== auth()->user()->email) {
                        return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                    }
                    
                    if ($app->application_status === 'rejected') {
                        return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                    }
                } elseif (is_numeric($refNumber)) {
                    $requestId = (int) $refNumber;
                } else {
                    return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                }

                if ($requestId !== null) {
                    // Check if it matches an Appeal first
                    $appeal = \App\Models\Appeal::where('id', $requestId)
                        ->where('student_id', auth()->user()->student->id)
                        ->first();

                    if ($appeal) {
                        $appealStatus = $appeal->status instanceof \App\Enums\AppealStatusEnum
                            ? $appeal->status->value
                            : (string) $appeal->status;
                        if ($appealStatus === 'rejected') {
                            return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                        }
                        $data['appeal_id'] = $appeal->id;
                    } else {
                        // Check if it's a Service Request
                        $serviceRequest = \App\Models\Request::find($requestId);
                        if (!$serviceRequest) {
                            return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                        }
                        
                        if ($serviceRequest->student_id !== auth()->user()->student->id) {
                            return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                        }
                        
                        $statusRaw = $serviceRequest->status instanceof \App\Enums\RequestStatusEnum 
                            ? $serviceRequest->status->value 
                            : (string) $serviceRequest->status;
                        if ($statusRaw === 'rejected') {
                            return response()->json(['error' => 'الرقم المرجعي المدخل غير موجود أو غير صالح.'], 422);
                        }
                        
                        $data['request_id'] = $serviceRequest->id;
                    }
                }
            }

            // Include optional ref_number in purpose if provided
            if ($request->filled('ref_number')) {
                $data['purpose'] .= ' (مرجع: ' . $request->input('ref_number') . ')';
            }

            $payment = $this->paymentService->submitPayment(
                auth()->user()->student->id,
                $data,
                $request->file('receipt_image')
            );

            // Notify accountant
            app(\App\Services\NotificationService::class)->notifyRole(
                'accountant',
                'دفعة مالية جديدة',
                'تم تقديم إيصال دفع جديد من قبل طالب.',
                $payment
            );

            return response()->json([
                'message' => 'تم إرسال إيصال الدفع بنجاح',
                'data'    => new PaymentResource($payment),
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Get student's payment history.
     */
    public function index(): JsonResponse
    {
        $payments = $this->paymentService->getStudentPayments(auth()->user()->student->id);
        return response()->json([
            'data' => PaymentResource::collection($payments),
        ]);
    }
}
