<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Services\Academic\GradeImportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Maatwebsite\Excel\Facades\Excel;

class GradeImportController extends Controller
{
    public function __construct(
        private GradeImportService $gradeImportService
    ) {}

    /**
     * Download a CSV template for importing grades.
     */
    public function template()
    {
        $headers = [
            'Student ID / Number',
            'Course Code',
            'First Exam',
            'Second Exam',
            'Midterm Exam',
            'Final Exam',
            'Grade Estimate'
        ];

        $callback = function() use($headers) {
            $file = fopen('php://output', 'w');
            fputcsv($file, $headers);
            fputcsv($file, ['STU-2026-0001', 'CS101', '15', '15', '18', '35', '']); // Numeric Example
            fputcsv($file, ['STU-2026-0002', 'CS101', '', '', '', '', 'excellent']); // Estimate Example
            fclose($file);
        };

        return response()->streamDownload($callback, 'grades_import_template.csv', [
            'Content-Type' => 'text/csv',
        ]);
    }

    /**
     * Preview an Excel file to get headers and sample data for mapping.
     */
    public function preview(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,xls,csv|max:5120',
        ]);

        $path = $request->file('file')->store('temp/imports');
        
        $previewData = $this->gradeImportService->getPreviewData($path);

        return response()->json([
            'temp_path' => $path,
            'headers' => $previewData['headers'],
            'sample_data' => $previewData['sample'],
            'db_fields' => [
                ['key' => 'student_number', 'label' => 'Student ID / Number (Required)'],
                ['key' => 'course_code', 'label' => 'Course Code (Required)'],
                ['key' => 'first', 'label' => 'First Exam (0-20)'],
                ['key' => 'second', 'label' => 'Second Exam (0-20)'],
                ['key' => 'midterm', 'label' => 'Midterm Exam (0-20)'],
                ['key' => 'final', 'label' => 'Final Exam (0-40)'],
                ['key' => 'grade_estimate', 'label' => 'Grade Estimate (e.g., excellent, very_good)'],
            ]
        ]);
    }

    /**
     * Validate the import mapping without saving.
     */
    public function validateImport(Request $request): JsonResponse
    {
        $request->validate([
            'temp_path' => 'required|string',
            'mapping' => 'required|array',
            'semester_id' => 'required|integer|exists:semesters,id',
        ]);

        if (!Storage::exists($request->temp_path)) {
            return response()->json(['message' => 'Temporary file not found or expired.'], 422);
        }

        $results = $this->gradeImportService->validateImport(
            $request->temp_path,
            $request->mapping,
            $request->semester_id
        );

        return response()->json([
            'summary' => $results
        ]);
    }

    /**
     * Commit the import with the validated mapping.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'temp_path' => 'required|string',
            'mapping' => 'required|array',
            'semester_id' => 'required|integer|exists:semesters,id',
        ]);

        if (!Storage::exists($request->temp_path)) {
            return response()->json(['message' => 'Temporary file not found or expired.'], 422);
        }

        $results = $this->gradeImportService->processImport(
            $request->temp_path,
            $request->mapping,
            $request->semester_id
        );

        // Clean up temp file
        Storage::delete($request->temp_path);

        return response()->json([
            'message' => 'Import completed',
            'summary' => [
                'total_rows' => $results['total'],
                'success_count' => $results['success'],
                'fail_count' => $results['failed'],
                'errors' => $results['errors']
            ]
        ]);
    }
}
