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
     * Process the full import using the mapping.
     */
    public function processImport(string $path, array $mapping, int $semesterId, int $courseId): array
    {
        $rows = Excel::toArray([], $path)[0] ?? [];
        $headerRow = array_shift($rows); // Remove headers

        $stats = ['total' => count($rows), 'success' => 0, 'failed' => 0, 'errors' => []];

        foreach ($rows as $index => $row) {
            $grade = null;
            try {
                DB::transaction(function () use ($row, $mapping, $headerRow, $semesterId, $courseId, &$stats, &$grade) {
                    $data = ['semester_id' => $semesterId, 'course_id' => $courseId];
                    foreach ($mapping as $dbField => $userValue) {
                        // Support both index (0, 1, 2...) and Header String ("Student ID")
                        $columnIndex = is_numeric($userValue) 
                            ? (int)$userValue 
                            : array_search($userValue, $headerRow);

                        if ($columnIndex === false) {
                            throw new \Exception("Mapping failed: Column [{$userValue}] not found in spreadsheet.");
                        }

                        $data[$dbField] = $row[$columnIndex] ?? null;
                    }

                    $grade = $this->importRow($data);
                    $stats['success']++;
                });

                // Send email OUTSIDE transaction so a mail failure doesn't rollback the saved grade
                if ($grade) {
                    try {
                        Mail::to($grade->student->user->email)->send(new GradeUpdated($grade));
                    } catch (\Exception $mailEx) {
                        // Log mail failure but don't fail the import
                        \Illuminate\Support\Facades\Log::warning("Grade import mail failed for grade {$grade->id}: " . $mailEx->getMessage());
                    }
                }
            } catch (\Exception $e) {
                $stats['failed']++;
                $stats['errors'][] = "Row " . ($index + 2) . ": " . $e->getMessage();
            }
        }

        return $stats;
    }

    /**
     * Validate the import mapping before committing.
     */
    public function validateImport(string $path, array $mapping, int $semesterId, int $courseId): array
    {
        $rows = Excel::toArray([], $path)[0] ?? [];
        $headerRow = array_shift($rows); // Remove headers

        $stats = [
            'total' => count($rows),
            'valid_count' => 0,
            'invalid_count' => 0,
            'will_update_count' => 0,
            'errors' => [],
            'preview_rows' => []
        ];

        foreach ($rows as $index => $row) {
            try {
                DB::transaction(function () use ($row, $mapping, $headerRow, $semesterId, $courseId, &$stats) {
                    $data = ['semester_id' => $semesterId, 'course_id' => $courseId];
                    foreach ($mapping as $dbField => $userValue) {
                        $columnIndex = is_numeric($userValue) 
                            ? (int)$userValue 
                            : array_search($userValue, $headerRow);

                        if ($columnIndex === false) {
                            throw new \Exception("Mapping failed: Column [{$userValue}] not found in spreadsheet.");
                        }

                        $data[$dbField] = $row[$columnIndex] ?? null;
                    }

                    // Check if student exists
                    $student = Student::with('user')->where('student_number', $data['student_number'])->first();
                    if (!$student) throw new \Exception("Student [{$data['student_number']}] not found.");

                    // Check if exists in DB to see if it will update
                    $exists = Grade::where([
                        'student_id' => $student->id,
                        'course_id' => $courseId,
                        'semester_id' => $semesterId,
                    ])->exists();

                    if ($exists) {
                        $stats['will_update_count']++;
                    }
                    $stats['valid_count']++;
                    
                    $coursework = floatval($data['coursework'] ?? 0);
                    $midterm = floatval($data['midterm'] ?? 0);
                    $final = floatval($data['final'] ?? 0);
                    
                    $stats['preview_rows'][] = [
                        'student_number' => $student->student_number,
                        'student_name' => $student->user->name ?? 'Unknown',
                        'coursework' => $coursework,
                        'midterm' => $midterm,
                        'final' => $final,
                        'total' => $coursework + $midterm + $final
                    ];
                    
                    // Throw exception to rollback transaction
                    throw new \Exception("ROLLBACK");
                });
            } catch (\Exception $e) {
                if ($e->getMessage() !== 'ROLLBACK') {
                    $stats['invalid_count']++;
                    $stats['errors'][] = "Row " . ($index + 2) . ": " . $e->getMessage();
                }
            }
        }

        return $stats;
    }

    /**
     * Import a single validated row.
     */
   private function importRow(array $data): Grade
{
    $student = Student::with('user')->where('student_number', $data['student_number'])->first();
    if (!$student) throw new \Exception("Student [{$data['student_number']}] not found.");

    $scoreData = [
        'first' => floatval($data['coursework'] ?? 0),
        'second' => 0,
        'midterm' => floatval($data['midterm'] ?? 0),
        'final' => floatval($data['final'] ?? 0),
    ];

    $result = $this->gradeCalculationService->calculateTotalAndGPA($scoreData);

    return Grade::updateOrCreate(
        [
            'student_id' => $student->id,
            'course_id' => $data['course_id'],
            'semester_id' => $data['semester_id'],
        ],
        array_merge($scoreData, [
            'total' => $result['total'],
            'gpa' => $result['gpa'],
            'status' => $result['status']->value,
            'grade_estimate' => $result['grade_estimate']->value,
        ])
    );
}
}
