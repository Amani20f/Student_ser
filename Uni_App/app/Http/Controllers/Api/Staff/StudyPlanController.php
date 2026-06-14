<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\StudyPlan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class StudyPlanController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = StudyPlan::with(['program', 'uploader']);

        if ($request->filled('program_id')) {
            $query->where('program_id', $request->program_id);
        }

        return response()->json(['data' => $query->get()->map(fn($p) => $this->format($p))]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'program_id' => 'required|exists:programs,id',
            'file'       => 'required|file|mimes:pdf,png,jpg,jpeg|max:10240',
            'title'      => 'required|string|max:255',
        ]);

        $existing = StudyPlan::where('program_id', $validated['program_id'])->first();

        if ($existing) {
            Storage::disk('public')->delete($existing->file_path);
        }

        $path = $request->file('file')->store('study_plans', 'public');

        $plan = StudyPlan::updateOrCreate(
            ['program_id' => $validated['program_id']],
            [
                'title'       => $validated['title'],
                'file_path'   => $path,
                'uploaded_by' => $request->user()->id,
            ]
        );

        return response()->json([
            'message' => 'Study plan uploaded successfully.',
            'data'    => $this->format($plan->load(['program', 'uploader'])),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $plan = StudyPlan::findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'file'  => 'sometimes|file|mimes:pdf,png,jpg,jpeg|max:10240',
        ]);

        if ($request->hasFile('file')) {
            Storage::disk('public')->delete($plan->file_path);
            $validated['file_path'] = $request->file('file')->store('study_plans', 'public');
            unset($validated['file']);
        }

        $plan->update($validated);

        return response()->json([
            'message' => 'Study plan updated successfully.',
            'data'    => $this->format($plan->load(['program', 'uploader'])),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $plan = StudyPlan::findOrFail($id);
        Storage::disk('public')->delete($plan->file_path);
        $plan->delete();

        return response()->json(['message' => 'Study plan deleted successfully.']);
    }

    private function format(StudyPlan $p): array
    {
        return [
            'id'           => $p->id,
            'program_id'   => $p->program_id,
            'program_name' => $p->program->name ?? null,
            'title'        => $p->title,
            'file_url'     => $p->file_path ? url('storage/' . $p->file_path) : null,
            'uploaded_by'  => $p->uploader->name ?? null,
            'uploaded_at'  => $p->updated_at,
        ];
    }
}
