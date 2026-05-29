<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Grade;
use App\Services\Academic\GradeManagementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Filters\GradeFilter;

class GradeManagementController extends Controller
{
    public function __construct(
        private GradeManagementService $gradeManagementService
    ) {}

    /**
     * Search grades with optional filters.
     * Returns empty array if no filter params are provided.
     */
    public function indexBySemester(Request $request): JsonResponse
    {
        $grades = Grade::with(['student.user', 'course', 'semester'])
            ->filter(new GradeFilter($request))
            ->get();

        return response()->json([
            'data' => \App\Http\Resources\GradeResource::collection($grades),
        ]);
    }

    /**
     * Update a grade.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        if (auth()->user()->hasRole('admin')) {
            return response()->json(['message' => 'Admin is read-only'], 403);
        }

        $request->validate([
            'first' => 'nullable|numeric|min:0|max:100',
            'second' => 'nullable|numeric|min:0|max:100',
            'midterm' => 'nullable|numeric|min:0|max:100',
            'final' => 'nullable|numeric|min:0|max:100',
        ]);

        try {
            $result = $this->gradeManagementService->updateGrade($id, $request->only([
                'first', 'second', 'midterm', 'final'
            ]));

            return response()->json([
                'message' => 'Grade updated successfully',
                'data' => new \App\Http\Resources\GradeResource($result['data']),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get all grades for a specific program.
     */
    public function indexByProgram(Request $request, int $programId): JsonResponse
    {
        $request->merge(['program_id' => $programId]);
        
        $grades = Grade::with(['student.user', 'course', 'semester'])
            ->filter(new GradeFilter($request))
            ->get();

        return response()->json([
            'data' => \App\Http\Resources\GradeResource::collection($grades)
        ]);
    }
}
