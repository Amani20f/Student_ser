<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Student;
use App\Models\Semester;
use App\Models\Course;
use App\Models\Appeal;
use App\Models\Payment;
use App\Models\Request as ServiceRequest;
use App\Models\RequestType;
use App\Models\Grade;
use App\Enums\AppealStatusEnum;
use App\Enums\PaymentStatusEnum;
use App\Enums\RequestStatusEnum;
use Carbon\Carbon;

class AppealTestDataSeeder extends Seeder
{
    public function run(): void
    {
        // 0. Login as an admin/user to satisfy observers (activity logs)
        $admin = \App\Models\User::first();
        if ($admin) {
            auth()->login($admin);
        }

        // 1. Get foundation data
        $student = Student::first();
        if (!$student) {
            $this->command->error('No student found. Please run AcademicSeeder first.');
            return;
        }

        $semester = Semester::where('academic_year', '2025/2026')->first() ?? Semester::first();
        $courses = Course::where('program_id', $student->program_id)->limit(3)->get();
        
        if ($courses->count() < 2) {
            $this->command->error('Not enough courses for seeding.');
            return;
        }

        $requestType = RequestType::where('slug', 'absence_excuse')->first() ?? RequestType::first();

        // 2. Ensure student has some grades to appeal
        foreach ($courses as $course) {
            Grade::updateOrCreate(
                ['student_id' => $student->id, 'course_id' => $course->id, 'semester_id' => $semester->id],
                [
                    'first' => 12,
                    'second' => 13,
                    'midterm' => 15,
                    'final' => 20,
                    'total' => 60,
                    'gpa' => 2.0,
                    'status' => 'passed'
                ]
            );
        }

        // ── SCENARIO 1: PENDING PAYMENT (For Accountant to see) ──
        $this->command->info('Seeding Pending Appeal Payment...');
        $appeal1 = Appeal::create([
            'student_id' => $student->id,
            'semester_id' => $semester->id,
            'status' => AppealStatusEnum::PAID, // Already paid, waiting for accountant
            'student_note' => 'أعتقد أن درجتي في منتصف الفصل تم رصدها بشكل غير عادل في كلا المساقين.',
        ]);

        foreach ($courses->take(2) as $course) {
            $appeal1->items()->create([
                'course_id' => $course->id,
                'coursework_before' => 40,
                'final_before' => 20,
                'total_before' => 60,
            ]);
        }

        Payment::create([
            'student_id' => $student->id,
            'semester_id' => $semester->id,
            'amount' => 100.00,
            'purpose' => "رسوم تظلم درجة - تظلم رقم #{$appeal1->id}",
            'receipt_image' => 'receipts/sample_receipt.jpg',
            'status' => PaymentStatusEnum::PENDING,
            'appeal_id' => $appeal1->id,
        ]);

        // ── SCENARIO 2: UNDER REVIEW (For Grade Control to see) ──
        $this->command->info('Seeding Under Review Appeal...');
        $appeal2 = Appeal::create([
            'student_id' => $student->id,
            'semester_id' => $semester->id,
            'status' => AppealStatusEnum::UNDER_REVIEW,
            'student_note' => 'عذر طبي لأداء الامتحان النهائي.',
        ]);

        $appeal2->items()->create([
            'course_id' => $courses->last()->id,
            'coursework_before' => 35,
            'final_before' => 15,
            'total_before' => 50,
        ]);

        Payment::create([
            'student_id' => $student->id,
            'semester_id' => $semester->id,
            'amount' => 50.00,
            'purpose' => "رسوم تظلم درجة - تظلم رقم #{$appeal2->id}",
            'receipt_image' => 'receipts/sample_receipt.jpg',
            'status' => PaymentStatusEnum::VERIFIED,
            'appeal_id' => $appeal2->id,
        ]);

        // ── SCENARIO 3: Service Request Payment (For Accountant to see) ──
        $this->command->info('Seeding Service Request Payment...');
        $request = ServiceRequest::create([
            'student_id' => $student->id,
            'request_type_id' => $requestType->id,
            'description' => 'طلب كشف درجات رسمي لغرض التقديم على منحة دراسية.',
            'status' => RequestStatusEnum::PENDING,
        ]);

        Payment::create([
            'student_id' => $student->id,
            'semester_id' => $semester->id,
            'amount' => 25.00,
            'purpose' => "رسوم كشف درجات - طلب رقم #{$request->id}",
            'receipt_image' => 'receipts/sample_receipt.jpg',
            'status' => PaymentStatusEnum::PENDING,
            'request_id' => $request->id,
        ]);

        $this->command->info('✅ Appeal & Payment Test Data Seeded!');
    }
}
