<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== بدء حذف البيانات الوهمية ===\n\n";

$fakeProgramIds = [18, 19, 20];
$fakeDeptIds    = [5, 6, 7];
$fakeCollegeIds = [4, 5, 6];

// 1. تحقق من أعمدة student_applications
$cols = DB::select("SELECT column_name FROM information_schema.columns WHERE table_name = 'student_applications'");
$colNames = array_map(fn($c) => $c->column_name, $cols);
echo "أعمدة student_applications: " . implode(', ', $colNames) . "\n\n";

// 2. حذف student_applications المرتبطة
$programColCandidates = ['desired_program_id', 'first_choice_program_id', 'program_id'];
foreach ($programColCandidates as $col) {
    if (in_array($col, $colNames)) {
        $del = DB::table('student_applications')->whereIn($col, $fakeProgramIds)->delete();
        if ($del) echo "حذفنا $del طلب وهمي من student_applications (عمود: $col)\n";
    }
}

// 3. حذف الكورسات الوهمية وما يرتبط بها
$fakeCourseIds = DB::table('courses')->whereIn('program_id', $fakeProgramIds)->pluck('id');
echo "كورسات وهمية: " . $fakeCourseIds->count() . "\n";

if ($fakeCourseIds->isNotEmpty()) {
    $del = DB::table('grades')->whereIn('course_id', $fakeCourseIds)->delete();
    if ($del) echo "حذفنا $del درجة\n";

    $del = DB::table('study_plans')->whereIn('course_id', $fakeCourseIds)->delete();
    if ($del) echo "حذفنا $del خطة دراسية\n";

    $del = DB::table('study_schedules')->whereIn('course_id', $fakeCourseIds)->delete();
    if ($del) echo "حذفنا $del جدول دراسي\n";

    $del = DB::table('courses')->whereIn('id', $fakeCourseIds)->delete();
    echo "حذفنا $del كورس وهمي\n";
}

// 4. حذف البرامج الوهمية
$deletedProgs = DB::table('programs')->whereIn('id', $fakeProgramIds)->delete();
echo "تم حذف $deletedProgs برنامج وهمي\n";

// 5. حذف الأقسام الوهمية
$deletedDepts = DB::table('departments')->whereIn('id', $fakeDeptIds)->delete();
echo "تم حذف $deletedDepts قسم وهمي\n";

// 6. حذف الكليات الوهمية
$deletedColleges = DB::table('colleges')->whereIn('id', $fakeCollegeIds)->delete();
echo "تم حذف $deletedColleges كلية وهمية\n";

echo "\n=== البيانات الحقيقية المتبقية ===\n";
echo "\nالكليات:\n";
foreach (DB::table('colleges')->orderBy('id')->get(['id','code','name']) as $c) {
    echo "  ✅ ID:{$c->id} | {$c->code} | {$c->name}\n";
}

echo "\nالأقسام:\n";
foreach (DB::table('departments')->orderBy('id')->get(['id','code','name','college_id']) as $d) {
    echo "  ✅ ID:{$d->id} | {$d->code} | {$d->name} | College:{$d->college_id}\n";
}

echo "\nالبرامج (" . DB::table('programs')->count() . " إجمالي):\n";
foreach (DB::table('programs')->orderBy('id')->get(['id','code','name','department_id']) as $p) {
    echo "  ✅ ID:{$p->id} | {$p->code} | {$p->name}\n";
}

echo "\n=== اكتمل التنظيف بنجاح ✅ ===\n";
