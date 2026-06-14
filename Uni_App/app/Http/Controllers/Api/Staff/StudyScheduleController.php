<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\StudySchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class StudyScheduleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = StudySchedule::with(['program', 'uploader']);

        if ($request->filled('program_id')) {
            $query->where('program_id', $request->program_id);
        }
        if ($request->filled('semester_id')) {
            $query->where('semester_id', $request->semester_id);
        }
        if ($request->filled('level')) {
            $query->where('level', $request->level);
        }

        return response()->json(['data' => $query->get()->map(fn($s) => $this->format($s))]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'program_id'  => 'required|exists:programs,id',
            'semester_id' => 'required|exists:semesters,id',
            'level'       => 'required|integer|min:1|max:10',
            'file'        => 'required|file|mimes:pdf,png,jpg,jpeg|max:10240',
            'title'       => 'required|string|max:255',
        ]);

        $existing = StudySchedule::where([
            'program_id'  => $validated['program_id'],
            'semester_id' => $validated['semester_id'],
            'level'       => $validated['level'],
        ])->first();

        if ($existing) {
            Storage::disk('public')->delete($existing->file_path);
        }

        $path = $request->file('file')->store('study_schedules', 'public');

        $schedule = StudySchedule::updateOrCreate(
            [
                'program_id'  => $validated['program_id'],
                'semester_id' => $validated['semester_id'],
                'level'       => $validated['level'],
            ],
            [
                'title'       => $validated['title'],
                'file_path'   => $path,
                'uploaded_by' => $request->user()->id,
            ]
        );

        return response()->json([
            'message' => 'Study schedule uploaded successfully.',
            'data'    => $this->format($schedule->load(['program', 'uploader'])),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $schedule = StudySchedule::findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'file'  => 'sometimes|file|mimes:pdf,png,jpg,jpeg|max:10240',
        ]);

        if ($request->hasFile('file')) {
            Storage::disk('public')->delete($schedule->file_path);
            $validated['file_path'] = $request->file('file')->store('study_schedules', 'public');
            unset($validated['file']);
        }

        $schedule->update($validated);

        return response()->json([
            'message' => 'Study schedule updated successfully.',
            'data'    => $this->format($schedule->load(['program', 'uploader'])),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $schedule = StudySchedule::findOrFail($id);
        Storage::disk('public')->delete($schedule->file_path);
        $schedule->delete();

        return response()->json(['message' => 'Study schedule deleted successfully.']);
    }

    private function format(StudySchedule $s): array
    {
        return [
            'id'           => $s->id,
            'program_id'   => $s->program_id,
            'program_name' => $s->program->name ?? null,
            'semester_id'  => $s->semester_id,
            'level'        => $s->level,
            'title'        => $s->title,
            'file_url'     => $s->file_path ? url('storage/' . $s->file_path) : null,
            'uploaded_by'  => $s->uploader->name ?? null,
            'uploaded_at'  => $s->updated_at,
        ];
    }
}
