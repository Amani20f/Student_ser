<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class StudentProfileTest extends TestCase
{
    public function test_can_get_profile()
    {
        $user = User::whereHas('roles', function($q) { $q->where('name', 'student'); })->first();
        if (!$user) {
            $this->markTestSkipped('No student user found.');
        }

        $response = $this->actingAs($user)->getJson('/api/student/profile');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data' => [
                'id', 'name', 'email', 'student' => [
                    'student_number', 'national_id'
                ]
            ]
        ]);
        echo "\n=== GET PROFILE RESPONSE ===\n";
        echo json_encode($response->json(), JSON_PRETTY_PRINT);
        echo "\n============================\n";
    }

    public function test_can_update_profile()
    {
        $user = User::whereHas('roles', function($q) { $q->where('name', 'student'); })->first();
        if (!$user) {
            $this->markTestSkipped('No student user found.');
        }

        $newName = 'Updated Name ' . rand(1, 100);
        $newNationalId = 'NAT-' . rand(1000, 9999);

        $response = $this->actingAs($user)->putJson('/api/student/profile', [
            'name' => $newName,
            'email' => $user->email,
            'phone' => '1234567890',
            'national_id' => $newNationalId,
        ]);

        $response->assertStatus(200);
        
        $user->refresh();
        $this->assertEquals($newName, $user->name);
        $this->assertEquals($newNationalId, $user->student->national_id);
        
        echo "\n=== PUT PROFILE RESPONSE ===\n";
        echo json_encode($response->json(), JSON_PRETTY_PRINT);
        echo "\n============================\n";
    }

    public function test_can_change_password()
    {
        $user = User::whereHas('roles', function($q) { $q->where('name', 'student'); })->first();
        if (!$user) {
            $this->markTestSkipped('No student user found.');
        }

        // Set known password first to avoid relying on actual password
        $user->update(['password' => Hash::make('password123')]);

        $response = $this->actingAs($user)->putJson('/api/student/change-password', [
            'current_password' => 'password123',
            'new_password' => 'newpassword123',
            'new_password_confirmation' => 'newpassword123',
        ]);

        $response->assertStatus(200);
        $this->assertTrue(Hash::check('newpassword123', $user->fresh()->password));
        
        echo "\n=== PUT PASSWORD RESPONSE ===\n";
        echo json_encode($response->json(), JSON_PRETTY_PRINT);
        echo "\n============================\n";

        // Revert password
        $user->update(['password' => Hash::make('password123')]);
    }
}
