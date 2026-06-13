<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AnnouncementController extends Controller
{
    public function index(Request $request)
    {
        $student = Auth::user()->student;

        if (!$student) {
            return response()->json([]);
        }

        $now = now();

        $announcements = Announcement::where('is_active', true)
            ->where(function ($q) use ($now) {
                $q->whereNull('published_at')->orWhere('published_at', '<=', $now);
            })
            ->where(function ($q) use ($now) {
                $q->whereNull('expires_at')->orWhere('expires_at', '>=', $now);
            })
            ->where(function ($q) use ($student) {
                $q->where('target_audience', 'all_students')
                  ->orWhere(function ($sub) use ($student) {
                      $sub->where('target_audience', 'specific_program')
                          ->where('target_program_id', $student->program_id);
                  })
                  ->orWhere(function ($sub) use ($student) {
                      $sub->where('target_audience', 'specific_college')
                          ->whereHas('targetProgram', function ($p) use ($student) {
                              $p->where('id', $student->program_id);
                          });
                  });
            })
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($announcements);
    }
}
