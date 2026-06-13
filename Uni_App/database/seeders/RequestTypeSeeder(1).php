<?php

namespace Database\Seeders;

use App\Models\RequestType;
use Illuminate\Database\Seeder;

class RequestTypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            [
                'name'        => 'عذر غياب',
                'slug'        => 'absence_excuse',
                'description' => 'تقديم عذر عن غياب المحاضرات مع الوثائق الداعمة.',
                'target_role' => 'student_affairs',
                'is_active'   => true,
                'price'       => 0.00,
                'form_url'    => null,
            ],
            [
                'name'        => 'تأجيل دراسة',
                'slug'        => 'suspension_of_enrollment',
                'description' => 'طلب تأجيل مؤقت للدراسة الأكاديمية.',
                'target_role' => 'student_affairs',
                'is_active'   => true,
                'price'       => 0.00,
                'form_url'    => null,
            ],
            [
                'name'        => 'إعادة قيد',
                'slug'        => 're_enrollment',
                'description' => 'طلب إعادة القيد بعد فترة انقطاع أو تأجيل.',
                'target_role' => 'student_affairs',
                'is_active'   => true,
                'price'       => 0.00,
                'form_url'    => null,
            ],
            [
                'name'        => 'تظلم درجة',
                'slug'        => 'grade_grievance',
                'description' => 'تقديم تظلم رسمي بشأن درجة أحد المساقات.',
                'target_role' => 'grade_control',
                'is_active'   => true,
                'price'       => 50.00,
                'form_url'    => null,
            ],
        ];

        foreach ($types as $type) {
            RequestType::updateOrCreate(
                ['slug' => $type['slug']],
                $type
            );
        }
    }
}

