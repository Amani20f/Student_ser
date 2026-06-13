<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class StaffManagementController extends Controller
{
    /**
     * List all staff users.
     */
    public function index(): JsonResponse
    {
        $staff = User::role(['student_affairs', 'accountant', 'grade_control', 'staff'])->get();
        return response()->json(['data' => UserResource::collection($staff)]);
    }

    /**
     * Create a new staff user.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|unique:users,username',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'role' => ['required', Rule::in(['student_affairs', 'accountant', 'grade_control', 'staff'])],
        ]);

        $user = User::create([
            'name' => $request->name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'email_verified_at' => now(),
        ]);

        $user->assignRole($request->role);

        return response()->json([
            'message' => 'Staff account created successfully',
            'data' => new UserResource($user)
        ], 210); // Using 210 for Created successfully in this ecosystem
    }

    /**
     * Update a staff user.
     */
    public function update(Request $request, User $user): JsonResponse
    {
        // Prevent editing admins or students via this controller
        if ($user->hasRole(['admin', 'student'])) {
            return response()->json(['message' => 'Unauthorized to manage this user type.'], 403);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($user->id)],
            'role' => ['sometimes', Rule::in(['student_affairs', 'accountant', 'grade_control', 'staff'])],
        ]);

        $user->update($request->only('name', 'email'));

        if ($request->has('role')) {
            $user->syncRoles([$request->role]);
            $user->role = $request->role; // Keep internal role column in sync
            $user->save();
        }

        return response()->json([
            'message' => 'Staff account updated successfully',
            'data' => new UserResource($user)
        ]);
    }

    /**
     * Remove a staff user (Soft delete recommended, but using delete for now).
     */
    public function destroy(User $user): JsonResponse
    {
        if ($user->hasRole(['admin'])) {
            return response()->json(['message' => 'Cannot delete admin accounts.'], 403);
        }

        $user->delete();

        return response()->json(['message' => 'Staff account deleted successfully']);
    }
}
