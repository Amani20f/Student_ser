<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentManagementController extends Controller
{
    /**
     * List all students.
     */
    public function index(): JsonResponse
    {
        $students = User::role('student')->with('student')->get();
        return response()->json(['data' => UserResource::collection($students)]);
    }

    /**
     * Delete a student account.
     */
    public function destroy(int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        
        if (!$user->hasRole('student')) {
            return response()->json(['message' => 'User is not a student'], 400);
        }

        $user->delete();

        return response()->json(['message' => 'Student account deleted successfully']);
    }
}
