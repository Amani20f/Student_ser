<?php

namespace App\Services\Academic;

use App\Models\Course;
use App\Models\Grade;
use App\Models\Student;
use App\Mail\GradeUpdated;
use App\Services\Academic\GradeCalculationService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Maatwebsite\Excel\Facades\Excel;
use Maatwebsite\Excel\HeadingRowImport;

class GradeImportService
{
    public function __construct(
        private GradeCalculationService $gradeCalculationService
    ) {}

    /**
     * Get headers and first 5 rows of the spreadsheet.
     */
    public function getPreviewData(string $path): array
    {
        $rows = Excel::toArray([], $path)[0] ?? [];
        
        return [
            'headers' => $rows[0] ?? [],
            'sample' => array_slice($rows, 1, 5)
        ];
    }

    /**
     * Validate the import without saving.
     */
    public function validateImport(string $path, array $mapping, int $semesterId): array
    {
        $rows = Excel::toArray([], $path)[0] ?? [];
        $headerRow = array_shift($rows); // Remove headers

        $stats = [
            'total' => count($rows), 
            'valid_count' => 0, 
            'invalid_count' => 0, 
            'will_update_count' => 0,
            'errors' => []
        ];

        foreach ($rows as $index => $row) {
            try {
                $data = $this->extractDataFromRow($row, $mapping, $headerRow);
                
                $student = Student::where('student_number', $data['student_number'])->first();
                if (!$student) throw new \Exception("Student [{$data['student_number']}] not found.");

                $course = Course::where('course_code', $data['course_code'])->first();
                if (!$course) throw new \Exception("Course [{$data['course_code']}] not found.");



                // Check if it will update an existing record
                $exists = Grade::where([
                    'student_id' => $student->id,
                    'course_id' => $course->id,
                    'semester_id' => $semesterId
                ])->exists();

                if ($exists) {
                    $stats['will_update_count']++;
                }

                $stats['valid_count']++;
            } catch (\Exception $e) {
                $stats['invalid_count']++;
                $stats['errors'][] = "Row " . ($index + 2) . ": " . $e->getMessage();
            }
        }

        return $stats;
    }

    /**
     * Helper to extract data from mapped row.
     */
    private function extractDataFromRow(array $row, array $mapping, array $headerRow): array
    {
        $data = [];
        foreach ($mapping as $dbField => $userValue) {
            $columnIndex = is_numeric($userValue) 
                ? (int)$userValue 
                : array_search($userValue, $headerRow);

            if ($columnIndex === false) {
                throw new \Exception("Mapping failed: Column [{$userValue}] not found in spreadsheet.");
            }

            $data[$dbField] = $row[$columnIndex] ?? null;
        }
        return $data;
    }

    /**
     * Process the full import using the mapping.
     */
    public function processImport(string $path, array $mapping, int $semesterId): array
    {
        $rows = Excel::toArray([], $path)[0] ?? [];
        $headerRow = array_shift($rows); // Remove headers

        $stats = ['total' => count($rows), 'success' => 0, 'failed' => 0, 'errors' => []];

        foreach ($rows as $index => $row) {
            try {
                DB::transaction(function () use ($row, $mapping, $headerRow, $semesterId, &$stats) {
                    $data = $this->extractDataFromRow($row, $mapping, $headerRow);

                    $grade = $this->importRow($data, $semesterId);
                    Mail::to($grade->student->user->email)->send(new GradeUpdated($grade));
                    $stats['success']++;
                });
            } catch (\Exception $e) {
                $stats['failed']++;
                $stats['errors'][] = "Row " . ($index + 2) . ": " . $e->getMessage();
            }
        }

        return $stats;
    }

    /**
     * Import a single validated row.
     */
   private function importRow(array $data, int $semesterId): Grade
{
    $student = Student::where('student_number', $data['student_number'])->first();
    if (!$student) throw new \Exception("Student [{$data['student_number']}] not found.");

    $course = Course::where('course_code', $data['course_code'])->first();
    if (!$course) throw new \Exception("Course [{$data['course_code']}] not found.");

    $scoreData = [
        'first' => floatval($data['first'] ?? 0),
        'second' => floatval($data['second'] ?? 0),
        'midterm' => floatval($data['midterm'] ?? 0),
        'final' => floatval($data['final'] ?? 0),
    ];

    $result = $this->gradeCalculationService->calculateTotalAndGPA($scoreData);

    // If a manual estimate is provided, use it
    $estimate = !empty($data['grade_estimate']) 
        ? $data['grade_estimate'] 
        : $result['grade_estimate']->value;

    return Grade::updateOrCreate(
        [
            'student_id' => $student->id,
            'course_id' => $course->id,
            'semester_id' => $semesterId,
        ],
        array_merge($scoreData, [
            'total' => $result['total'],
            'gpa' => $result['gpa'],
            'status' => $result['status']->value,
            'grade_estimate' => $estimate,
        ])
    );
}
}
