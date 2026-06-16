<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\College;
use App\Models\Department;
use App\Models\Program;
use Illuminate\Support\Facades\DB;

try {
    DB::beginTransaction();

    // 1. Update/Create COE (Engineering & IT)
    $coe = College::updateOrCreate(
        ['code' => 'COE'],
        ['name' => 'كلية الهندسة وتقنية المعلومات']
    );

    // 2. Update/Create COB (Business Administration)
    $cob = College::updateOrCreate(
        ['code' => 'COB'],
        ['name' => 'كلية العلوم الإدارية']
    );

    // 3. Create COM (Medical Sciences)
    $com = College::updateOrCreate(
        ['code' => 'COM'],
        ['name' => 'كلية الطب والعلوم الصحية']
    );

    // Departments
    $csDept = Department::updateOrCreate(
        ['code' => 'CS'],
        ['name' => 'قسم علوم الحاسوب وتقنية المعلومات', 'college_id' => $coe->id]
    );

    $eeDept = Department::updateOrCreate(
        ['code' => 'EE'],
        ['name' => 'قسم الهندسة الكهربائية والمدنية والمعمارية', 'college_id' => $coe->id]
    );

    $baDept = Department::updateOrCreate(
        ['code' => 'BA'],
        ['name' => 'قسم العلوم الإدارية والمحاسبة', 'college_id' => $cob->id]
    );

    $medDept = Department::updateOrCreate(
        ['code' => 'MED'],
        ['name' => 'قسم العلوم الطبية والصحية', 'college_id' => $com->id]
    );

    // Set existing programs (like BSCS, BSEE) to is_available = false
    Program::whereIn('code', ['BSCS', 'BSEE'])->update([
        'is_available' => false,
    ]);

    // Seed Active Programs
    $activePrograms = [
        // IT
        [
            'code' => 'IT',
            'name' => 'تقنية المعلومات',
            'department_id' => $csDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 70.00,
            'is_available' => true,
        ],
        // AI
        [
            'code' => 'AI',
            'name' => 'الذكاء الاصطناعي',
            'department_id' => $csDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 70.00,
            'is_available' => true,
        ],
        // Cyber
        [
            'code' => 'CYBER',
            'name' => 'الأمن السيبراني',
            'department_id' => $csDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 70.00,
            'is_available' => true,
        ],
        // Interior Design
        [
            'code' => 'ID',
            'name' => 'التصميم الداخلي',
            'department_id' => $eeDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 75.00,
            'is_available' => true,
        ],
        // Civil
        [
            'code' => 'CIVIL',
            'name' => 'الهندسة المدنية',
            'department_id' => $eeDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 75.00,
            'is_available' => true,
        ],
        // Architecture
        [
            'code' => 'ARCH',
            'name' => 'الهندسة المعمارية',
            'department_id' => $eeDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 75.00,
            'is_available' => true,
        ],
        // Power
        [
            'code' => 'POWER',
            'name' => 'هندسة القوى الكهربائية والطاقة المتجددة',
            'department_id' => $eeDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 75.00,
            'is_available' => true,
        ],
        // Accounting
        [
            'code' => 'ACC',
            'name' => 'المحاسبة',
            'department_id' => $baDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'both',
            'minimum_percentage' => 60.00,
            'is_available' => true,
        ],
    ];

    foreach ($activePrograms as $ap) {
        Program::updateOrCreate(
            ['code' => $ap['code']],
            $ap
        );
    }

    // Update existing BSBA (إدارة الأعمال) to have proper eligibility
    Program::updateOrCreate(
        ['code' => 'BSBA'],
        [
            'name' => 'إدارة الأعمال',
            'department_id' => $baDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'both',
            'minimum_percentage' => 60.00,
            'is_available' => true,
        ]
    );

    // Medical Programs (is_available = false)
    $medicalPrograms = [
        [
            'code' => 'MED_GP',
            'name' => 'الطب العام والجراحة',
            'department_id' => $medDept->id,
            'duration_years' => 6,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 85.00,
            'is_available' => false,
        ],
        [
            'code' => 'MED_DENT',
            'name' => 'طب الأسنان',
            'department_id' => $medDept->id,
            'duration_years' => 5,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 80.00,
            'is_available' => false,
        ],
        [
            'code' => 'MED_PHARM',
            'name' => 'الصيدلة',
            'department_id' => $medDept->id,
            'duration_years' => 5,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 75.00,
            'is_available' => false,
        ],
        [
            'code' => 'MED_LAB',
            'name' => 'المختبرات الطبية',
            'department_id' => $medDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 70.00,
            'is_available' => false,
        ],
        [
            'code' => 'MED_HEAR',
            'name' => 'علوم واضطرابات السمع والنطق',
            'department_id' => $medDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 70.00,
            'is_available' => false,
        ],
        [
            'code' => 'MED_PHYS',
            'name' => 'العلاج الطبيعي',
            'department_id' => $medDept->id,
            'duration_years' => 4,
            'degree_type' => 'bachelor',
            'certificate_type' => 'scientific',
            'minimum_percentage' => 70.00,
            'is_available' => false,
        ],
    ];

    foreach ($medicalPrograms as $mp) {
        Program::updateOrCreate(
            ['code' => $mp['code']],
            $mp
        );
    }

    DB::commit();
    echo "SUCCESS: Seeded all active and medical programs with eligibility rules.\n";
} catch (\Exception $e) {
    DB::rollBack();
    echo "ERROR: " . $e->getMessage() . "\n";
}
