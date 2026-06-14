<?php
$user = App\Models\User::firstOrCreate(
    ['email' => 'admin@admin.com'],
    [
        'name' => 'System Admin',
        'username' => 'admin',
        'password' => Illuminate\Support\Facades\Hash::make('password'),
    ]
);
$user->assignRole('admin');
echo "Email: admin@admin.com | Password: password\n";
