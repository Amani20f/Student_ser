<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\StudySchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class StudyScheduleController extends Controller
{
    /**
     * List all study schedules with optional filters.
     */
    public function index(Request $request): JsonResponse
    {
        $query = StudySchedule::with(['program', 'semester']);

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

    /**
     * Store a new study schedule.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'program_id'  => 'required|exists:programs,id',
            'semester_id' => 'required|exists:semesters,id',
            'level'       => 'required|integer|min:1|max:10',
            'image'       => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240',
            'notes'       => 'nullable|string|max:1000',
        ]);

        $path = $request->file('image')->store('study_schedules', 'public');

        $schedule = StudySchedule::create([
            'program_id'          => $validated['program_id'],
            'semester_id'         => $validated['semester_id'],
            'level'               => $validated['level'],
            'schedule_image_path' => $path,
            'notes'               => $validated['notes'] ?? null,
        ]);

        return response()->json([
            'message' => 'Study schedule created successfully.',
            'data'    => $this->format($schedule->load(['program', 'semester'])),
        ], 201);
    }

    /**
     * Update an existing study schedule.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $schedule = StudySchedule::findOrFail($id);

        $validated = $request->validate([
            'notes' => 'sometimes|nullable|string|max:1000',
            'image' => 'sometimes|file|mimes:jpg,jpeg,png,pdf|max:10240',
        ]);

        if ($request->hasFile('image')) {
            Storage::disk('public')->delete($schedule->schedule_image_path);
            $validated['schedule_image_path'] = $request->file('image')->store('study_schedules', 'public');
            unset($validated['image']);
        }

        $schedule->update($validated);

        return response()->json([
            'message' => 'Study schedule updated successfully.',
            'data'    => $this->format($schedule->load(['program', 'semester'])),
        ]);
    }

    /**
     * Delete a study schedule.
     */
    public function destroy(int $id): JsonResponse
    {
        $schedule = StudySchedule::findOrFail($id);
        Storage::disk('public')->delete($schedule->schedule_image_path);
        $schedule->delete();

        return response()->json(['message' => 'Study schedule deleted successfully.']);
    }

    private function format(StudySchedule $s): array
    {
        return [
            'id'                  => $s->id,
            'program_id'          => $s->program_id,
            'program_name'        => $s->program->name ?? null,
            'semester_id'         => $s->semester_id,
            'academic_year'       => $s->semester->academic_year ?? null,
            'term'                => $s->semester->term->value ?? null,
            'level'               => $s->level,
            'schedule_image_url'  => $s->schedule_image_path ? url('storage/' . $s->schedule_image_path) : null,
            'notes'               => $s->notes,
        ];
    }
}
