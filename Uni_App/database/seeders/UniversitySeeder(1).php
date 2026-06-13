<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\College;
use App\Models\Department;
use App\Models\Program;
use App\Models\Course;

class UniversitySeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Colleges
        $coe = College::firstOrCreate(
            ['code' => 'COE'],
            ['name' => 'كلية الهندسة']
        );

        $cob = College::firstOrCreate(
            ['code' => 'COB'],
            ['name' => 'كلية إدارة الأعمال']
        );

        // 2. Create Departments for COE
        $csDept = Department::firstOrCreate(
            ['code' => 'CS'],
            ['name' => 'قسم علوم الحاسوب', 'college_id' => $coe->id]
        );

        $eeDept = Department::firstOrCreate(
            ['code' => 'EE'],
            ['name' => 'قسم الهندسة الكهربائية', 'college_id' => $coe->id]
        );

        // 3. Create Departments for COB
        $baDept = Department::firstOrCreate(
            ['code' => 'BA'],
            ['name' => 'قسم إدارة الأعمال', 'college_id' => $cob->id]
        );

        // 4. Create Programs
        $bscs = Program::firstOrCreate(
            ['code' => 'BSCS'],
            [
                'name' => 'بكالوريوس علوم الحاسوب',
                'department_id' => $csDept->id,
                'duration_years' => 4,
                'degree_type' => 'bachelor'
            ]
        );

        $bsee = Program::firstOrCreate(
            ['code' => 'BSEE'],
            [
                'name' => 'بكالوريوس الهندسة الكهربائية',
                'department_id' => $eeDept->id,
                'duration_years' => 4,
                'degree_type' => 'bachelor'
            ]
        );

        $bsba = Program::firstOrCreate(
            ['code' => 'BSBA'],
            [
                'name' => 'بكالوريوس إدارة الأعمال',
                'department_id' => $baDept->id,
                'duration_years' => 4,
                'degree_type' => 'bachelor'
            ]
        );

        // 5. Create Courses
        $courses = [
            [
                'program_id' => $bscs->id,
                'course_code' => 'CS101',
                'course_name' => 'مقدمة في الحوسبة',
                'credit_hours' => 3,
                'semester_level' => 1,
                'description' => 'أساسيات الحوسبة ومنطق البرمجة.'
            ],
            [
                'program_id' => $bscs->id,
                'course_code' => 'CS102',
                'course_name' => 'برمجة الحاسوب 1',
                'credit_hours' => 4,
                'semester_level' => 1,
                'description' => 'مقدمة في البرمجة باستخدام لغة C++.'
            ],
            [
                'program_id' => $bscs->id,
                'course_code' => 'MATH101',
                'course_name' => 'حساب التفاضل والتكامل 1',
                'credit_hours' => 3,
                'semester_level' => 1,
                'description' => 'حساب التفاضل.'
            ],
            [
                'program_id' => $bscs->id,
                'course_code' => 'CS103',
                'course_name' => 'برمجة الحاسوب 2',
                'credit_hours' => 4,
                'semester_level' => 2,
                'description' => 'البرمجة كائنية التوجه (OOP).'
            ],
            [
                'program_id' => $bscs->id,
                'course_code' => 'CS104',
                'course_name' => 'التراكيب المتقطعة',
                'credit_hours' => 3,
                'semester_level' => 2,
                'description' => 'الرياضيات المتقطعة لعلوم الحاسوب.'
            ],
            [
                'program_id' => $bsee->id,
                'course_code' => 'EE101',
                'course_name' => 'الرسم الهندسي',
                'credit_hours' => 2,
                'semester_level' => 1,
                'description' => 'أساسيات الرسم الهندسي.'
            ],
            [
                'program_id' => $bsee->id,
                'course_code' => 'EE102',
                'course_name' => 'الدوائر الكهربائية 1',
                'credit_hours' => 4,
                'semester_level' => 2,
                'description' => 'مقدمة في الدوائر الكهربائية.'
            ],
            [
                'program_id' => $bsba->id,
                'course_code' => 'MGT101',
                'course_name' => 'مبادئ الإدارة',
                'credit_hours' => 3,
                'semester_level' => 1,
                'description' => 'مبادئ الإدارة الأساسية.'
            ],
            [
                'program_id' => $bsba->id,
                'course_code' => 'MKT101',
                'course_name' => 'مبادئ التسويق',
                'credit_hours' => 3,
                'semester_level' => 2,
                'description' => 'مقدمة في مفاهيم التسويق.'
            ],
        ];

        foreach ($courses as $courseData) {
            Course::firstOrCreate(
                ['course_code' => $courseData['course_code']],
                $courseData
            );
        }
    }
}
