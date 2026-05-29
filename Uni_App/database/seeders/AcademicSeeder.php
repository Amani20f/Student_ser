<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use App\Models\Program;
use App\Models\Course;
use App\Models\Grade;
use App\Models\Payment;
use App\Models\Notification;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AcademicSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Semesters
        $first2024 = Semester::firstOrCreate(
            ['academic_year' => '2024/2025', 'term' => 'first'],
            [
                'start_date' => '2024-09-01',
                'end_date' => '2025-01-31',
                'exams_start_date' => '2025-01-15',
                'is_active' => false
            ]
        );

        $second2024 = Semester::firstOrCreate(
            ['academic_year' => '2024/2025', 'term' => 'second'],
            [
                'start_date' => '2025-02-01',
                'end_date' => '2025-06-30',
                'exams_start_date' => '2025-06-15',
                'is_active' => false
            ]
        );

        $first2025 = Semester::firstOrCreate(
            ['academic_year' => '2025/2026', 'term' => 'first'],
            [
                'start_date' => '2025-09-01',
                'end_date' => '2026-01-31',
                'exams_start_date' => '2026-01-15',
                'is_active' => true // Current active semester
            ]
        );

        // 2. Create Students
        $programs = Program::all();
        $faker = \Faker\Factory::create('ar_SA');

        // Create 10 Students
        for ($i = 0; $i < 10; $i++) {
            $user = User::firstOrCreate(
                ['email' => "student{$i}@university.edu"],
                [
                    'name' => $faker->name,
                    'username' => 'student_' . $i . '_' . Str::random(3),
                    'password' => Hash::make('password'),
                    'role' => 'student',
                    'email_verified_at' => now(),
                ]
            );

            // Assign Role (Spatie)
            if (!$user->hasRole('student')) {
                $user->assignRole('student');
            }

            $program = $programs->random();

            $student = Student::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'student_number' => 'S' . date('Y') . str_pad($i, 5, '0', STR_PAD_LEFT),
                    'phone' => $faker->phoneNumber,
                    'program_id' => $program->id,
                    'current_level' => 2, // Assume 2nd year
                    'status' => 'active',
                ]
            );

            // 3. Create Grades (Historic — First 2024/2025 semester)
            $level1Courses = Course::where('program_id', $program->id)
                                   ->where('semester_level', 1)
                                   ->get();

             foreach($level1Courses as $course) {
                 $first = rand(10, 20);
                 $second = rand(10, 20);
                 $midterm = rand(15, 20);
                 $final = rand(25, 40);
                 $total = $first + $second + $midterm + $final;

                 Grade::firstOrCreate(
                     [
                         'student_id' => $student->id,
                         'course_id' => $course->id,
                         'semester_id' => $first2024->id,
                     ],
                     [
                         'first' => $first,
                         'second' => $second,
                         'midterm' => $midterm,
                         'final' => $final,
                         'total' => $total,
                         'gpa' => round(($total / 100) * 4.0, 2),
                         'status' => $total >= 60 ? 'passed' : 'failed',
                     ]
                 );
             }

             // Recalculate GPA & Credits to populate cumulative_gpa & completed_credit_hours in DB
             $student->recalculateGPAAndCredits();

             // 4. Create Payments (verified for First 2024/2025)
             Payment::firstOrCreate(
                 [
                     'student_id' => $student->id,
                     'semester_id' => $first2024->id,
                 ],
                 [
                     'amount' => 5000.00,
                     'receipt_image' => 'receipts/sample_receipt.jpg',
                     'status' => 'verified',
                     'purpose' => 'الرسوم الدراسية - الفصل الدراسي الأول 2024/2025',
                 ]
             );
        }

        // 5. Seed Notifications
        $notification = Notification::firstOrCreate(
            ['title' => 'مرحباً بكم في البوابة الجامعية'],
            [
                'message' => 'يرجى إكمال ملفكم الشخصي والتحقق من الخطة الدراسية لمستواكم.',
                'target_type' => 'all',
            ]
        );

        $users = User::whereHas('student')->take(5)->get();
        foreach ($users as $user) {
            if (!$user->notifications()->where('notification_id', $notification->id)->exists()) {
                $user->notifications()->attach($notification->id, ['is_read' => false]);
            }
        }
    }
}
