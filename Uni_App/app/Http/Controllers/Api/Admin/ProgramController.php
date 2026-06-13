<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Program;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProgramController extends Controller
{
    /**
     * Display a listing of the programs.
     */
    public function index(): JsonResponse
    {
        // Admin should see all programs including archived
        $programs = Program::with('department.college')->withTrashed()->get();
        return response()->json(['data' => $programs]);
    }

    /**
     * Store a newly created program.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'           => 'required|string|max:255',
            'code'           => 'required|string|max:20|unique:programs,code',
            'department_id'  => 'required|integer|exists:departments,id',
            'duration_years' => 'required|integer|min:1|max:7',
            'degree_type'    => ['required', Rule::in(['bachelor', 'master', 'phd'])],
            'fees'           => 'required|numeric|min:0',
        ]);

        $program = Program::create($validated);
        $program->load('department.college');

        return response()->json([
            'message' => 'Program created successfully',
            'data'    => $program,
        ], 201);
    }

    /**
     * Update the specified program.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $program = Program::withTrashed()->findOrFail($id);

        $validated = $request->validate([
            'name'           => 'sometimes|string|max:255',
            'code'           => ['sometimes', 'string', 'max:20', Rule::unique('programs', 'code')->ignore($program->id)],
            'department_id'  => 'sometimes|integer|exists:departments,id',
            'duration_years' => 'sometimes|integer|min:1|max:7',
            'degree_type'    => ['sometimes', Rule::in(['bachelor', 'master', 'phd'])],
            'fees'           => 'sometimes|numeric|min:0',
        ]);

        $program->update($validated);
        $program->load('department.college');

        return response()->json([
            'message' => 'Program updated successfully',
            'data'    => $program,
        ]);
    }

    /**
     * Remove (soft delete) the specified program.
     */
    public function destroy(int $id): JsonResponse
    {
        $program = Program::findOrFail($id);
        $program->delete();

        return response()->json([
            'message' => 'Program archived successfully',
        ]);
    }

    /**
     * Restore a soft deleted program.
     */
    public function restore(int $id): JsonResponse
    {
        $program = Program::withTrashed()->findOrFail($id);
        $program->restore();

        return response()->json([
            'message' => 'Program restored successfully',
            'data'    => $program,
        ]);
    }
}
