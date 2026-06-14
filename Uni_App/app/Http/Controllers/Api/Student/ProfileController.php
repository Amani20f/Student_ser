<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Student\UpdateProfileRequest;
use App\Http\Requests\Student\ChangePasswordRequest;
use App\Http\Resources\UserResource;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    /**
     * Get the authenticated student's profile.
     */
    public function show()
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        
        $user->load('student.program');

        return new UserResource($user);
    }

    /**
     * Update the authenticated student's profile.
     */
    public function update(UpdateProfileRequest $request)
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        $validated = $request->validated();

        DB::transaction(function () use ($user, $validated) {
            // Update User fields
            $userData = [
                'name' => $validated['name'],
                'email' => $validated['email'],
            ];
            
            if (array_key_exists('username', $validated)) {
                $userData['username'] = $validated['username'];
            }
            
            $user->update($userData);

            // Update Student fields
            if ($user->student) {
                $studentData = [
                    'phone' => $validated['phone'] ?? $user->student->phone,
                ];
                
                if (array_key_exists('national_id', $validated)) {
                    $studentData['national_id'] = $validated['national_id'];
                }
                
                $user->student->update($studentData);
            }
        });

        // Reload the user model to return fresh data
        $user->refresh();
        $user->load('student.program');

        return new UserResource($user);
    }

    /**
     * Change the authenticated student's password.
     */
    public function changePassword(ChangePasswordRequest $request)
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();

        $user->update([
            'password' => Hash::make($request->validated('new_password')),
        ]);

        return response()->json([
            'message' => 'Password changed successfully.'
        ]);
    }
}
