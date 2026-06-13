<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleAndPermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            'view-grades',
            'update-grades',
            'import-grades',
            'verify-payments',
            'reject-payments',
            'process-requests',
            'manage-students',
            'manage-staff',
            'manage-courses',
            'manage-semesters',
            'view-audit-logs',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles and assign permissions

        // Admin role - full access
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $adminRole->syncPermissions(Permission::all());

        // Student Affairs - Requests only
        $studentAffairs = Role::firstOrCreate(['name' => 'student_affairs']);
        $studentAffairs->syncPermissions([
            'process-requests',
            'manage-students',
        ]);

        // Accountant - Financial only
        $accountant = Role::firstOrCreate(['name' => 'accountant']);
        $accountant->syncPermissions([
            'verify-payments',
            'reject-payments',
        ]);

        // Grade Control - Academic only
        $gradeControl = Role::firstOrCreate(['name' => 'grade_control']);
        $gradeControl->syncPermissions([
            'view-grades',
            'update-grades',
            'import-grades',
        ]);

        // General Staff - basic read access
        $staffRole = Role::firstOrCreate(['name' => 'staff']);
        $staffRole->syncPermissions([
            'view-grades',
        ]);

        // Student role - read-only own data (Policies handle this)
        Role::firstOrCreate(['name' => 'student']);
        // Students don't need explicit permissions, policies handle their access
    }
}
