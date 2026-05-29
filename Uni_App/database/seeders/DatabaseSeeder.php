<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Setup Roles and Permissions
        $this->call(RoleAndPermissionSeeder::class);

        // 2. Create Admin User
        $admin = User::firstOrCreate(
            ['email' => 'admin@university.edu'],
            [
                'name' => 'مدير النظام',
                'username' => 'admin',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'email_verified_at' => now(),
            ]
        );
        $admin->assignRole('admin');
        Auth::login($admin);

        // 3. Create Student Affairs User
        $affairs = User::firstOrCreate(
            ['email' => 'affairs@university.edu'],
            [
                'name' => 'سارة الشؤون',
                'username' => 'sara_affairs',
                'password' => Hash::make('password'),
                'role' => 'student_affairs',
                'email_verified_at' => now(),
            ]
        );
        $affairs->assignRole('student_affairs');

        // 4. Create Accountant User
        $accountant = User::firstOrCreate(
            ['email' => 'accountant@university.edu'],
            [
                'name' => 'أحمد المحاسب',
                'username' => 'alex_accountant',
                'password' => Hash::make('password'),
                'role' => 'accountant',
                'email_verified_at' => now(),
            ]
        );
        $accountant->assignRole('accountant');

        // 5. Create Grade Control User
        $gradeControl = User::firstOrCreate(
            ['email' => 'grades@university.edu'],
            [
                'name' => 'خالد الكنترول',
                'username' => 'gary_grades',
                'password' => Hash::make('password'),
                'role' => 'grade_control',
                'email_verified_at' => now(),
            ]
        );
        $gradeControl->assignRole('grade_control');

        // 6. Seed Request Types
        $this->call(RequestTypeSeeder::class);

        // 7. Seed University Structure
        $this->call(UniversitySeeder::class);

        // 8. Seed Academic Data
        $this->call(AcademicSeeder::class);

        // 9. Seed Sample Dashboard Data (requests, payments, grades, logs)
        $this->call(SampleDataSeeder::class);

        // 10. Seed Appeal Test Data
        $this->call(AppealTestDataSeeder::class);
    }
}
