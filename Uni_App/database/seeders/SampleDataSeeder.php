<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ActivityLog;
use App\Models\Course;
use App\Models\Grade;
use App\Models\Payment;
use App\Models\Request as ServiceRequest;
use App\Models\RequestType;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use Carbon\Carbon;

class SampleDataSeeder extends Seeder
{
    /**
     * Seed sample data for admin dashboard visibility.
     * Creates mixed-status requests, payments, grades, and activity logs.
     * Idempotent — safe to re-run without duplicates.
     */
    public function run(): void
    {
        // ── Resolve dependencies ──────────────────────────────────────
        $students = Student::with('user', 'program')->orderBy('id')->get();

        if ($students->count() < 5) {
            $this->command->warn('SampleDataSeeder: Need at least 5 students. Run AcademicSeeder first.');
            return;
        }

        $fall2025   = Semester::where('academic_year', '2025/2026')->where('term', 'first')->first();
        $spring2025 = Semester::where('academic_year', '2024/2025')->where('term', 'second')->first();

        if (!$fall2025 || !$spring2025) {
            $this->command->warn('SampleDataSeeder: Semesters not found. Run AcademicSeeder first.');
            return;
        }

        $requestTypes = RequestType::all()->keyBy('slug');
        if ($requestTypes->isEmpty()) {
            $this->command->warn('SampleDataSeeder: Request types not found. Run RequestTypeSeeder first.');
            return;
        }

        $admin = User::where('role', 'admin')->first();
        $affairs = User::where('role', 'student_affairs')->first();
        $accountant = User::where('role', 'accountant')->first();
        $gradeControl = User::where('role', 'grade_control')->first();

        // ── 1. Service Requests (6 total: 3 pending, 2 approved, 1 rejected) ──
        $this->command->info('Seeding service requests...');

        $requestsData = [
            [
                'student_id'      => $students[0]->id,
                'request_type_id' => $requestTypes['absence_excuse']->id,
                'description'     => 'لقد غبت لمدة 3 أيام بسبب حالة طبية طارئة. مرفق التقرير الطبي.',
                'status'          => 'pending',
                'created_at'      => Carbon::now()->subDays(2),
            ],
            [
                'student_id'      => $students[1]->id,
                'request_type_id' => $requestTypes['suspension_of_enrollment']->id,
                'description'     => 'أرغب في تأجيل دراستي للفصل الحالي بسبب ظروف عائلية.',
                'status'          => 'pending',
                'created_at'      => Carbon::now()->subDays(5),
            ],
            [
                'student_id'      => $students[2]->id,
                'request_type_id' => $requestTypes['re_enrollment']->id,
                'description'     => 'طلب إعادة قيد بعد انقطاع فصل دراسي واحد. جميع الوثائق مرفقة.',
                'status'          => 'pending',
                'created_at'      => Carbon::now()->subDays(1),
            ],
            [
                'student_id'      => $students[3]->id,
                'request_type_id' => $requestTypes['grade_grievance']->id,
                'description'     => 'أعتقد أن درجتي في الامتحان النهائي لمساق CS101 تم حسابها بشكل خاطئ.',
                'status'          => 'approved',
                'processed_by'    => $gradeControl?->id,
                'admin_notes'     => 'تمت مراجعة الدرجة وتصحيحها. تم تحديث إجمالي الطالب.',
                'response_message'=> 'تمت مراجعة تظلم الدرجة الخاص بك والموافقة عليه.',
                'created_at'      => Carbon::now()->subDays(10),
            ],
            [
                'student_id'      => $students[4]->id,
                'request_type_id' => $requestTypes['absence_excuse']->id,
                'description'     => 'غياب لمدة يومين بسبب جراحة مجدولة. الوثائق الطبية متوفرة.',
                'status'          => 'approved',
                'processed_by'    => $affairs?->id,
                'admin_notes'     => 'تم قبول العذر. تم التحقق من الوثائق الطبية.',
                'response_message'=> 'تم قبول عذر الغياب الخاص بك.',
                'created_at'      => Carbon::now()->subDays(15),
            ],
            [
                'student_id'      => $students[0]->id,
                'request_type_id' => $requestTypes['suspension_of_enrollment']->id,
                'description'     => 'طلب تأجيل دراسة لأسباب شخصية.',
                'status'          => 'rejected',
                'processed_by'    => $affairs?->id,
                'admin_notes'     => 'المبررات المقدمة غير كافية. يرجى إعادة التقديم مع وثائق داعمة.',
                'response_message'=> 'تم رفض طلب التأجيل الخاص بك. يرجى تقديم المزيد من الوثائق.',
                'created_at'      => Carbon::now()->subDays(20),
            ],
        ];

        foreach ($requestsData as $data) {
            ServiceRequest::firstOrCreate(
                [
                    'student_id'      => $data['student_id'],
                    'request_type_id' => $data['request_type_id'],
                    'description'     => $data['description'],
                ],
                $data
            );
        }

        // ── 2. Payments (6 total: 3 pending, 2 verified, 1 rejected) ──
        $this->command->info('Seeding payments...');

        $paymentsData = [
            // 3 Pending
            [
                'student_id'    => $students[0]->id,
                'semester_id'   => $fall2025->id,
                'amount'        => 5000.00,
                'receipt_image' => 'receipts/receipt_student0_fall2025.jpg',
                'status'        => 'pending',
                'purpose'       => 'رسوم دراسية - الفصل الدراسي الأول 2025/2026',
                'created_at'    => Carbon::now()->subDays(3),
            ],
            [
                'student_id'    => $students[1]->id,
                'semester_id'   => $fall2025->id,
                'amount'        => 4500.00,
                'receipt_image' => 'receipts/receipt_student1_fall2025.jpg',
                'status'        => 'pending',
                'purpose'       => 'رسوم دراسية جزئية - الفصل الدراسي الأول 2025/2026',
                'created_at'    => Carbon::now()->subDays(2),
            ],
            [
                'student_id'    => $students[2]->id,
                'semester_id'   => $fall2025->id,
                'amount'        => 5000.00,
                'receipt_image' => 'receipts/receipt_student2_fall2025.jpg',
                'status'        => 'pending',
                'purpose'       => 'رسوم كاملة - الفصل الدراسي الأول 2025/2026',
                'created_at'    => Carbon::now()->subDays(1),
            ],
            // 2 Verified
            [
                'student_id'    => $students[3]->id,
                'semester_id'   => $spring2025->id,
                'amount'        => 5000.00,
                'receipt_image' => 'receipts/receipt_student3_spring2025.jpg',
                'status'        => 'verified',
                'purpose'       => 'رسوم دراسية - الفصل الدراسي الثاني 2024/2025',
                'created_at'    => Carbon::now()->subDays(30),
            ],
            [
                'student_id'    => $students[4]->id,
                'semester_id'   => $spring2025->id,
                'amount'        => 4800.00,
                'receipt_image' => 'receipts/receipt_student4_spring2025.jpg',
                'status'        => 'verified',
                'purpose'       => 'رسوم دراسية - الفصل الدراسي الثاني 2024/2025',
                'created_at'    => Carbon::now()->subDays(28),
            ],
            // 1 Rejected
            [
                'student_id'       => $students[5]->id,
                'semester_id'      => $fall2025->id,
                'amount'           => 5000.00,
                'receipt_image'    => 'receipts/receipt_student5_fall2025.jpg',
                'status'           => 'rejected',
                'rejection_reason' => 'صورة الإيصال غير واضحة ولا يمكن قراءتها. يرجى إعادة إرسال نسخة واضحة.',
                'purpose'          => 'رسوم دراسية - الفصل الدراسي الأول 2025/2026',
                'created_at'       => Carbon::now()->subDays(7),
            ],
        ];

        foreach ($paymentsData as $data) {
            Payment::firstOrCreate(
                [
                    'student_id'  => $data['student_id'],
                    'semester_id' => $data['semester_id'],
                    'status'      => $data['status'],
                ],
                $data
            );
        }

        // ── 3. Grades for Spring 2025 semester (2nd-level courses) ──
        $this->command->info('Seeding Spring 2025 grades...');

        foreach ($students as $student) {
            $level2Courses = Course::where('program_id', $student->program_id)
                                   ->where('semester_level', 2)
                                   ->get();

            foreach ($level2Courses as $course) {
                $first   = rand(10, 20);
                $second  = rand(10, 20);
                $midterm = rand(15, 20);
                $final   = rand(25, 40);
                $total   = $first + $second + $midterm + $final;

                Grade::firstOrCreate(
                    [
                        'student_id'  => $student->id,
                        'course_id'   => $course->id,
                        'semester_id' => $spring2025->id,
                    ],
                    [
                        'first'   => $first,
                        'second'  => $second,
                        'midterm' => $midterm,
                        'final'   => $final,
                        'total'   => $total,
                        'gpa'     => round(($total / 100) * 4.0, 2),
                        'status'  => $total >= 60 ? 'passed' : 'failed',
                    ]
                );
            }
            
            // Trigger student GPA/Credits recalculation
            $student->recalculateGPAAndCredits();
        }

        // ── 4. Activity Logs ──
        $this->command->info('Seeding activity logs...');

        $logsData = [
            [
                'causer_id'  => $accountant?->id,
                'action'     => 'verified_payment',
                'model_type' => 'App\\Models\\Payment',
                'subject_id' => Payment::where('status', 'verified')->first()?->id ?? 1,
                'old_values' => ['status' => 'pending'],
                'new_values' => ['status' => 'verified'],
                'created_at' => Carbon::now()->subDays(28),
            ],
            [
                'causer_id'  => $affairs?->id,
                'action'     => 'approved_request',
                'model_type' => 'App\\Models\\Request',
                'subject_id' => ServiceRequest::where('status', 'approved')->first()?->id ?? 1,
                'old_values' => ['status' => 'pending'],
                'new_values' => ['status' => 'approved'],
                'created_at' => Carbon::now()->subDays(15),
            ],
            [
                'causer_id'  => $gradeControl?->id,
                'action'     => 'updated_grade',
                'model_type' => 'App\\Models\\Grade',
                'subject_id' => Grade::first()?->id ?? 1,
                'old_values' => ['total' => 70, 'gpa' => 2.80],
                'new_values' => ['total' => 78, 'gpa' => 3.12],
                'created_at' => Carbon::now()->subDays(10),
            ],
            [
                'causer_id'  => $accountant?->id,
                'action'     => 'rejected_payment',
                'model_type' => 'App\\Models\\Payment',
                'subject_id' => Payment::where('status', 'rejected')->first()?->id ?? 1,
                'old_values' => ['status' => 'pending'],
                'new_values' => ['status' => 'rejected'],
                'created_at' => Carbon::now()->subDays(7),
            ],
            [
                'causer_id'  => $admin?->id,
                'action'     => 'created_staff',
                'model_type' => 'App\\Models\\User',
                'subject_id' => $affairs?->id ?? 1,
                'old_values' => null,
                'new_values' => ['name' => 'سارة الشؤون', 'role' => 'student_affairs'],
                'created_at' => Carbon::now()->subDays(45),
            ],
        ];

        foreach ($logsData as $data) {
            ActivityLog::firstOrCreate(
                [
                    'causer_id'  => $data['causer_id'],
                    'action'     => $data['action'],
                    'subject_id' => $data['subject_id'],
                ],
                $data
            );
        }

        $this->command->info('✅ SampleDataSeeder completed successfully.');
    }
}
