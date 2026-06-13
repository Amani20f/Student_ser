<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CourseController extends Controller
{
    /**
     * Display a listing of courses.
     */
    public function index(): JsonResponse
    {
        $courses = Course::with(['program', 'prerequisites'])->withTrashed()->get();
        return response()->json(['data' => $courses]);
    }

    /**
     * Store a newly created course.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'program_id'     => 'required|integer|exists:programs,id',
            'course_code'    => 'required|string|max:20|unique:courses,course_code',
            'course_name'    => 'required|string|max:255',
            'credit_hours'   => 'required|integer|min:1|max:10',
            'semester_level' => 'required|integer|min:1|max:20',
            'order_index'    => 'sometimes|integer',
            'description'    => 'nullable|string',
            'prerequisites'  => 'sometimes|array',
            'prerequisites.*'=> 'integer|exists:courses,id',
        ]);

        $course = Course::create($validated);

        if (isset($validated['prerequisites'])) {
            $course->prerequisites()->sync($validated['prerequisites']);
        }

        $course->load(['program', 'prerequisites']);

        return response()->json([
            'message' => 'Course created successfully',
            'data'    => $course,
        ], 201);
    }

    /**
     * Update the specified course.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $course = Course::withTrashed()->findOrFail($id);

        $validated = $request->validate([
            'program_id'     => 'sometimes|integer|exists:programs,id',
            'course_code'    => ['sometimes', 'string', 'max:20', Rule::unique('courses', 'course_code')->ignore($course->id)],
            'course_name'    => 'sometimes|string|max:255',
            'credit_hours'   => 'sometimes|integer|min:1|max:10',
            'semester_level' => 'sometimes|integer|min:1|max:20',
            'order_index'    => 'sometimes|integer',
            'description'    => 'nullable|string',
            'prerequisites'  => 'sometimes|array',
            'prerequisites.*'=> 'integer|exists:courses,id',
        ]);

        $course->update($validated);

        if (isset($validated['prerequisites'])) {
            $course->prerequisites()->sync($validated['prerequisites']);
        }

        $course->load(['program', 'prerequisites']);

        return response()->json([
            'message' => 'Course updated successfully',
            'data'    => $course,
        ]);
    }

    /**
     * Remove (soft delete) the specified course.
     */
    public function destroy(int $id): JsonResponse
    {
        $course = Course::findOrFail($id);
        $course->delete();

        return response()->json([
            'message' => 'Course archived successfully',
        ]);
    }

    /**
     * Restore a soft deleted course.
     */
    public function restore(int $id): JsonResponse
    {
        $course = Course::withTrashed()->findOrFail($id);
        $course->restore();

        return response()->json([
            'message' => 'Course restored successfully',
            'data'    => $course,
        ]);
    }
}
