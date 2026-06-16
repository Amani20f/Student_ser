<?php
$dirs = ['app', 'admin_dashboard/lib', 'student_portal/lib', 'resources/views'];
$matches = [];
foreach($dirs as $dir) {
    if (!is_dir($dir)) continue;
    $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir));
    foreach ($iterator as $file) {
        if ($file->isFile() && in_array($file->getExtension(), ['php', 'dart'])) {
            $content = file_get_contents($file->getPathname());
            if (preg_match('/(pending|approved|rejected)/i', $content)) {
                $matches[] = $file->getPathname();
            }
        }
    }
}
echo implode("\n", $matches);
