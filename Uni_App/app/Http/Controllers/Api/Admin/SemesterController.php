<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Semester;
use App\Models\Grade;
use App\Models\Payment;
use App\Models\Appeal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SemesterController extends Controller
{
    /**
     * Display a listing of semesters.
     */
    public function index(): JsonResponse
    {
        $semesters = Semester::orderBy('start_date', 'desc')->get();
        return response()->json([
            'success' => true,
            'data' => $semesters,
        ]);
    }

    /**
     * Store a newly created semester in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'start_year' => 'required|integer|min:2020|max:2100',
            'end_year' => 'required|integer|min:2020|max:2100|gte:start_year',
            'term' => 'required|string|in:first,second',
            'is_active' => 'boolean',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'exams_start_date' => 'required|date|after:start_date|before:end_date',
        ]);

        $academicYear = $validated['start_year'] . '/' . $validated['end_year'];
        $isActive = $validated['is_active'] ?? false;

        DB::beginTransaction();
        try {
            if ($isActive) {
                Semester::query()->update(['is_active' => false]);
            }

            $semester = Semester::create([
                'academic_year' => $academicYear,
                'term' => $validated['term'],
                'is_active' => $isActive,
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'exams_start_date' => $validated['exams_start_date'],
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء الفصل الدراسي بنجاح.',
                'data' => $semester,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إنشاء الفصل الدراسي.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified semester in storage.
     */
    public function update(Request $request, Semester $semester): JsonResponse
    {
        $validated = $request->validate([
            'start_year' => 'required|integer|min:2020|max:2100',
            'end_year' => 'required|integer|min:2020|max:2100|gte:start_year',
            'term' => 'required|string|in:first,second',
            'is_active' => 'boolean',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'exams_start_date' => 'required|date|after:start_date|before:end_date',
        ]);

        $academicYear = $validated['start_year'] . '/' . $validated['end_year'];
        $isActive = $validated['is_active'] ?? false;

        DB::beginTransaction();
        try {
            if ($isActive && !$semester->is_active) {
                Semester::where('id', '!=', $semester->id)->update(['is_active' => false]);
            }

            $semester->update([
                'academic_year' => $academicYear,
                'term' => $validated['term'],
                'is_active' => $isActive,
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'exams_start_date' => $validated['exams_start_date'],
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث الفصل الدراسي بنجاح.',
                'data' => $semester,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تحديث الفصل الدراسي.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified semester from storage.
     */
    public function destroy(Semester $semester): JsonResponse
    {
        // Check for dependencies
        $hasGrades = Grade::where('semester_id', $semester->id)->exists();
        $hasPayments = Payment::where('semester_id', $semester->id)->exists();
        // Assuming Appeals have semester_id or are linked via grade
        $hasAppeals = Appeal::whereHas('items.grade', function($q) use ($semester) {
            $q->where('semester_id', $semester->id);
        })->exists();

        if ($hasGrades || $hasPayments || $hasAppeals) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن حذف هذا الفصل لارتباطه بسجلات درجات أو مدفوعات أو طلبات سابقة. يرجى تعطيله بدلاً من حذفه.',
            ], 400);
        }

        try {
            $semester->delete();
            return response()->json([
                'success' => true,
                'message' => 'تم حذف الفصل الدراسي بنجاح.',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء حذف الفصل الدراسي.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
