<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentApplication extends Model
{
    use HasFactory;

    protected $fillable = [
        'application_number',
        'application_status',
        'rejection_reason',
        'full_name',
        'national_id_number',
        'date_of_birth',
        'gender',
        'nationality',
        'phone_number',
        'email_address',
        'address',
        'desired_program_id',
        'desired_academic_level',
        'identity_document_path',
        'qualification_document_path',
        'personal_photo_path',
        'payment_receipt_path',
        'form_responses',
        'submitted_at',
    ];

    protected $casts = [
        'form_responses' => 'array',
        'date_of_birth'  => 'date',
        'submitted_at'   => 'datetime',
    ];

    public function desiredProgram(): BelongsTo
    {
        return $this->belongsTo(Program::class, 'desired_program_id');
    }

    /**
     * Generate a unique application number.
     */
    public static function generateApplicationNumber(): string
    {
        do {
            $number = 'APP-' . now()->year . '-' . strtoupper(substr(md5(uniqid()), 0, 6));
        } while (self::where('application_number', $number)->exists());

        return $number;
    }
}
