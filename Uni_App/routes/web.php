<?php

use Illuminate\Support\Facades\Route;


Route::get('/', function () {
    return view('welcome');
});

Route::get('/reset-password/{token}', function ($token) {
    return response()->json([
        'message' => 'Password reset link placeholder',
        'token' => $token
    ]);
})->name('password.reset');
