<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$types = App\Models\RequestType::all();
foreach ($types as $t) {
    echo "RequestType: ID=" . $t->id . ", Name=" . $t->name . ", Slug=" . $t->slug . ", TargetRole=" . $t->target_role . "\n";
}

$requests = App\Models\Request::with('requestType')->limit(10)->get();
foreach ($requests as $r) {
    echo "Request: ID=" . $r->id . ", Type=" . ($r->requestType->slug ?? 'none') . ", Status=" . $r->status->value . "\n";
}
