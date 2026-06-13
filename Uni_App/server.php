<?php

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)
);

$publicPath = __DIR__.'/public'.$uri;

if ($uri !== '/' && file_exists($publicPath)) {
    // For static files served by artisan serve, we manually read the file 
    // to attach CORS headers, rather than returning false.
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization, X-Requested-With');
    
    $extension = pathinfo($publicPath, PATHINFO_EXTENSION);
    $mimeTypes = [
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'pdf' => 'application/pdf',
        'svg' => 'image/svg+xml',
        'css' => 'text/css',
        'js' => 'application/javascript',
    ];
    
    if (array_key_exists(strtolower($extension), $mimeTypes)) {
        header('Content-Type: ' . $mimeTypes[strtolower($extension)]);
    } else {
        header('Content-Type: ' . mime_content_type($publicPath));
    }
    
    readfile($publicPath);
    return true;
}

require_once __DIR__.'/public/index.php';
