<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$routes = collect(Route::getRoutes())->map(function ($route) {
    return $route->uri;
})->filter(function ($uri) {
    return str_contains($uri, 'announcement');
})->values()->all();

print_r($routes);
