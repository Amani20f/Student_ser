<?php
$rt = \App\Models\RequestType::where('slug', 'grade_grievance')->first();
if($rt) {
    $rt->update(['name' => 'تظلم درجات']);
    echo 'Updated: ' . $rt->name . PHP_EOL;
} else {
    echo 'Not found' . PHP_EOL;
}
