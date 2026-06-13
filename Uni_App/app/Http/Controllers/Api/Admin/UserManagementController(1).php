<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Admin\CreateUserRequest;
use App\Http\Requests\Api\Admin\UpdatePasswordRequest;
use App\Http\Requests\Api\Admin\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Models\ActivityLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use App\Filters\UserFilter;

class UserManagementController extends Controller
{
    /**
     * List all users (excluding the authenticated admin themselves).
     */
    public function index(\Illuminate\Http\Request $request): JsonResponse
    {
        $users = User::with(['roles', 'student'])
            ->where('id', '!=', auth()->id())
            ->filter(new UserFilter($request))
            ->latest()
            ->get();

        return response()->json([
            'data' => UserResource::collection($users),
        ]);
    }

    /**
     * Create a new user (staff or admin).
     */
    public function store(CreateUserRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::create([
            'name'              => $validated['name'],
            'username'          => $validated['username'],
            'email'             => $validated['email'],
            'password'          => Hash::make($validated['password']),
            'role'              => $validated['role'],
            'email_verified_at' => now(),
        ]);

        $user->assignRole($validated['role']);

        // Log account creation
        ActivityLog::create([
            'causer_id'   => auth()->id(),
            'action'      => 'user_created',
            'model_type'  => User::class,
            'subject_id'  => $user->id,
            'old_values'  => null,
            'new_values'  => ['name' => $user->name, 'email' => $user->email, 'role' => $validated['role']],
        ]);

        return response()->json([
            'message' => 'User created successfully',
            'data'    => new UserResource($user),
        ], 201);
    }

    /**
     * Update user info (name, email, role).
     */
    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $validated = $request->validated();

        $user->update(array_filter([
            'name'  => $validated['name']  ?? null,
            'email' => $validated['email'] ?? null,
        ], fn($v) => !is_null($v)));

        if (!empty($validated['role'])) {
            $user->syncRoles([$validated['role']]);
            $user->role = $validated['role'];
            $user->saveQuietly();
        }

        return response()->json([
            'message' => 'User updated successfully',
            'data'    => new UserResource($user->fresh()),
        ]);
    }

    /**
     * Delete a user — admin cannot delete themselves.
     */
    public function destroy(User $user): JsonResponse
    {
        if ($user->id === auth()->id()) {
            return response()->json(['message' => 'You cannot delete your own account.'], 403);
        }

        $user->syncRoles([]);
        $user->delete();

        // Log account deletion
        ActivityLog::create([
            'causer_id'  => auth()->id(),
            'action'     => 'user_deleted',
            'model_type' => User::class,
            'subject_id' => $user->id,
            'old_values' => ['name' => $user->name, 'email' => $user->email],
            'new_values' => null,
        ]);

        return response()->json(['message' => 'User deleted successfully']);
    }

    /**
     * Update a user's password.
     */
    public function updatePassword(UpdatePasswordRequest $request, User $user): JsonResponse
    {
        $user->update([
            'password' => Hash::make($request->validated()['password']),
        ]);

        return response()->json(['message' => 'Password updated successfully']);
    }
}
