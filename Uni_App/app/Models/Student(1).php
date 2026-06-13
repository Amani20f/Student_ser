<?php

namespace App\Models;

use App\Enums\StudentStatusEnum;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Student extends Model
{
    use HasFactory, \App\Traits\Filterable;

    protected $fillable = [
        'user_id',
        'student_number',
        'phone',
        'program_id',
        'current_level',
        'status',
        'national_id',
        'gender',
        'nationality',
        'date_of_birth',
        'profile_photo_path',
        'cumulative_gpa',
        'completed_credit_hours',
    ];

    protected $casts = [
        'status' => StudentStatusEnum::class,
        'current_level' => 'integer',
        'date_of_birth' => 'date',
        'cumulative_gpa' => 'decimal:2',
        'completed_credit_hours' => 'integer',
    ];

    /**
     * Recalculate cumulative GPA and completed credit hours.
     */
    public function recalculateGPAAndCredits(): void
    {
        $grades = $this->grades()->with('course')->get();

        $completedCredits = 0;
        $totalCreditsForGPA = 0;
        $totalPoints = 0.0;

        foreach ($grades as $grade) {
            $credits = $grade->course->credit_hours ?? 0;

            if ($grade->status === \App\Enums\GradeStatusEnum::PASSED) {
                $completedCredits += $credits;
            }

            if ($grade->status !== \App\Enums\GradeStatusEnum::INCOMPLETE) {
                $totalCreditsForGPA += $credits;
                $totalPoints += ($grade->gpa ?? 0.0) * $credits;
            }
        }

        $gpa = $totalCreditsForGPA > 0 ? round($totalPoints / $totalCreditsForGPA, 2) : 0.00;

        $this->update([
            'cumulative_gpa' => $gpa,
            'completed_credit_hours' => $completedCredits,
        ]);
    }

    /**
     * Get the user that owns the student record.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the program the student is enrolled in.
     */
    public function program(): BelongsTo
    {
        return $this->belongsTo(Program::class);
    }

    /**
     * Get all grades for the student.
     */
    public function grades(): HasMany
    {
        return $this->hasMany(Grade::class);
    }

    /**
     * Get all payments for the student.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Get all requests submitted by the student.
     */
    public function requests(): HasMany
    {
        return $this->hasMany(Request::class);
    }

    /**
     * Get all grade appeals submitted by the student.
     */
    public function appeals(): HasMany
    {
        return $this->hasMany(Appeal::class);
    }

    /**
     * Get count of accepted suspension requests for this student.
     * Used to validate suspension limit (4 for Bachelor, 2 for Diploma).
     */
    public function getAcceptedSuspensionCount(): int
    {
        return $this->requests()
            ->whereHas('requestType', function ($query) {
                $query->where('slug', 'suspension_of_enrollment');
            })
            ->where('status', \App\Enums\RequestStatusEnum::APPROVED)
            ->count();
    }
}
