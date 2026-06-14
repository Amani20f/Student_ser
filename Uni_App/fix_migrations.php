<?php
foreach(glob(__DIR__.'/database/migrations/*.php') as $file) {
    $content = file_get_contents($file);
    $content = preg_replace('/DB::statement\(([\'"]ALTER TABLE .+? DROP CONSTRAINT .+?[\'"])\);/', 'if (\Illuminate\Support\Facades\DB::getDriverName() !== \'sqlite\') { \Illuminate\Support\Facades\DB::statement($1); }', $content);
    file_put_contents($file, $content);
}
echo "Done";
