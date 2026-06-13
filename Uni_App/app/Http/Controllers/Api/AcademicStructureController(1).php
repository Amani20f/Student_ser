<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\College;
use App\Models\Department;
use App\Models\Program;
use Illuminate\Http\JsonResponse;

class AcademicStructureController extends Controller
{
    /**
     * GET /api/colleges
     * Returns all colleges with their departments and programs.
     * Public — no auth required.
     */
    public function colleges(): JsonResponse
    {
        $colleges = College::with(['departments.programs'])->get();

        return response()->json([
            'success' => true,
            'data'    => $colleges->map(fn ($college) => [
                'id'   => $college->id,
                'name' => $college->name,
                'code' => $college->code,
                'departments' => $college->departments->map(fn ($dept) => [
                    'id'       => $dept->id,
                    'name'     => $dept->name,
                    'code'     => $dept->code,
                    'programs' => $dept->programs->map(fn ($prog) => [
                        'id'             => $prog->id,
                        'name'           => $prog->name,
                        'code'           => $prog->code,
                        'duration_years' => $prog->duration_years,
                        'fees'           => $prog->fees,
                        'degree_type'    => $prog->degree_type instanceof \BackedEnum
                            ? $prog->degree_type->value
                            : $prog->degree_type,
                    ]),
                ]),
            ]),
        ]);
    }

    /**
     * GET /api/programs
     * Returns a flat list of all programs (with college & department name).
     * Public — no auth required.
     */
    public function programs(): JsonResponse
    {
        $programs = Program::with(['department.college'])->get();

        return response()->json([
            'success' => true,
            'data'    => $programs->map(fn ($prog) => [
                'id'             => $prog->id,
                'name'           => $prog->name,
                'code'           => $prog->code,
                'degree_type'    => $prog->degree_type instanceof \BackedEnum
                    ? $prog->degree_type->value
                    : $prog->degree_type,
                'department'     => $prog->department?->name,
                'college'        => $prog->department?->college?->name,
                'department_id'  => $prog->department_id,
                'college_id'     => $prog->department?->college?->id,
            ]),
        ]);
    }

    /**
     * GET /api/semesters
     * Returns all semesters.
     */
    public function semesters(): JsonResponse
    {
        $semesters = \App\Models\Semester::orderBy('start_date', 'desc')->get();

        return response()->json([
            'success' => true,
            'data'    => $semesters->map(fn ($sem) => [
                'id'         => $sem->id,
                'name'       => (($sem->term->value ?? $sem->term) === 'first' ? 'الفصل الدراسي الأول ' : 'الفصل الدراسي الثاني ') . $sem->academic_year,
                'year'       => $sem->academic_year,
                'is_current' => $sem->is_active,
            ]),
        ]);
    }
    /**
     * GET /api/courses
     * Returns courses, optionally filtered by program_id.
     */
    public function courses(\Illuminate\Http\Request $request): JsonResponse
    {
        $query = \App\Models\Course::query();
        
        if ($request->has('program_id')) {
            $query->where('program_id', $request->input('program_id'));
        }

        $courses = $query->get();

        return response()->json([
            'success' => true,
            'data'    => $courses->map(fn ($course) => [
                'id'          => $course->id,
                'name'        => $course->course_name,
                'code'        => $course->course_code,
                'program_id'  => $course->program_id,
            ]),
        ]);
    }
}
