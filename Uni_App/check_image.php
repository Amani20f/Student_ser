<?php
$file = 'd:/modify_student_services-main/Uni_App/storage/app/public/study_schedules/DQVKJAJ4dUwMO3Yh0wUaBcPe6vETgMmDBLZMt6WF.png';
if (file_exists($file)) {
    echo "File exists.\n";
    echo "Size: " . filesize($file) . " bytes\n";
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    echo "Mime Type: " . finfo_file($finfo, $file) . "\n";
    finfo_close($finfo);
} else {
    echo "File not found.\n";
}
