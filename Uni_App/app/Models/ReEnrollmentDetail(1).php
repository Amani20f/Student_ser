<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReEnrollmentDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'request_id',
        'student_id',
        'university_id_path',
        'major',
        'academic_level',
        'batch',
        'academic_year',
        'university_fees',
        'other_fees',
    ];

    /**
     * Get the request that owns the re-enrollment details.
     */
    public function request(): BelongsTo
    {
        return $this->belongsTo(Request::class);
    }

    /**
     * Get the student associated with the re-enrollment details.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
