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
     * Preview an Excel file to get headers and sample data for mapping.
     */
    public function preview(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|mimes:xlsx,xls,csv,txt|max:5120',
        ]);

        $path = $request->file('file')->store('temp/imports');
        
        $previewData = $this->gradeImportService->getPreviewData($path);

        return response()->json([
            'temp_path' => $path,
            'headers' => $previewData['headers'],
            'sample_data' => $previewData['sample'],
            'db_fields' => [
                ['key' => 'student_number', 'label' => 'Student ID'],
                ['key' => 'coursework', 'label' => 'Coursework'],
                ['key' => 'midterm', 'label' => 'Midterm'],
                ['key' => 'final', 'label' => 'Final'],
            ]
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
            'semester_id' => 'required|integer',
            'program_id' => 'required|integer',
            'course_id' => 'required|integer',
        ]);

        if (!Storage::exists($request->temp_path)) {
            return response()->json(['message' => 'Temporary file not found or expired.'], 422);
        }

        $results = $this->gradeImportService->processImport(
            $request->temp_path,
            $request->mapping,
            $request->semester_id,
            $request->course_id
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

    /**
     * Validate the spreadsheet mapping before importing.
     */
    public function validate(Request $request): JsonResponse
    {
        $request->validate([
            'temp_path' => 'required|string',
            'mapping' => 'required|array',
            'semester_id' => 'required|integer',
            'program_id' => 'required|integer',
            'course_id' => 'required|integer',
        ]);

        if (!Storage::exists($request->temp_path)) {
            return response()->json(['message' => 'Temporary file not found or expired.'], 422);
        }

        $results = $this->gradeImportService->validateImport(
            $request->temp_path,
            $request->mapping,
            $request->semester_id,
            $request->course_id
        );
        
        return response()->json($results);
    }

    /**
     * Download a sample CSV template for grade imports.
     */
    public function template(): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        $headers = [
            'Student ID',
            'Coursework',
            'Midterm',
            'Final',
        ];

        $students = \App\Models\Student::limit(5)->get();

        $tempFile = tempnam(sys_get_temp_dir(), 'grade_import_template');
        $handle = fopen($tempFile, 'w');
        
        fputs($handle, chr(0xEF) . chr(0xBB) . chr(0xBF)); // BOM for UTF-8
        fputcsv($handle, $headers);
        
        foreach ($students as $student) {
            fputcsv($handle, [
                $student->student_number,
                rand(10, 40),
                rand(10, 20),
                rand(20, 40),
            ]);
        }

        fclose($handle);

        return response()->download($tempFile, 'grades_sample.csv')->deleteFileAfterSend(true);
    }
}
