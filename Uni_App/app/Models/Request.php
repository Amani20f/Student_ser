<?php

namespace App\Models;

use App\Enums\RequestStatusEnum;
use App\Traits\Filterable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Log;

class Request extends Model
{
    use HasFactory, Filterable;

    protected $fillable = [
        'student_id',
        'request_type_id',
        'description',
        'attachment',
        'status',
        'processed_by',
        'form_data',
        'admin_notes',
        'response_message',
        'is_notified',
    ];

    protected $casts = [
        'status'      => RequestStatusEnum::class,
        'form_data'   => 'array',
        'attachment'  => 'array',
        'is_notified' => 'boolean',
    ];

    /**
     * Accept the request with optional admin notes.
     */
   public function accept(?string $adminNotes = null, bool $shouldNotify = true): void
{
    $oldStatus = $this->status instanceof RequestStatusEnum
        ? $this->status->value
        : $this->status;

    $this->status = RequestStatusEnum::APPROVED;
    $this->admin_notes = $adminNotes;
    $this->save();

    Log::info('Request status changed to APPROVED', [
        'request_id' => $this->id,
        'student_id' => $this->student_id,
        'request_type' => $this->requestType?->name ?? 'Unknown',
        'old_status' => $oldStatus,
        'new_status' => 'approved',
        'admin_notes' => $adminNotes,
        'processed_by' => $this->processed_by,
        'timestamp' => now()->toDateTimeString(),
    ]);
}

    /**
     * Reject the request with admin notes.
     */
   public function reject(string $adminNotes, bool $shouldNotify = true): void
{
    $oldStatus = $this->status instanceof RequestStatusEnum
        ? $this->status->value
        : $this->status;

    $this->status = RequestStatusEnum::REJECTED;
    $this->admin_notes = $adminNotes;
    $this->save();

    Log::info('Request status changed to REJECTED', [
        'request_id' => $this->id,
        'student_id' => $this->student_id,
        'request_type' => $this->requestType?->name ?? 'Unknown',
        'old_status' => $oldStatus,
        'new_status' => 'rejected',
        'admin_notes' => $adminNotes,
        'processed_by' => $this->processed_by,
        'timestamp' => now()->toDateTimeString(),
    ]);
}

    /**
     * Mark the request as notified.
     */
    public function markAsNotified(): void
    {
        $this->is_notified = true;
        $this->save();
    }

    /**
     * Get the student who made the request.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the type of request.
     */
    public function requestType(): BelongsTo
    {
        return $this->belongsTo(RequestType::class);
    }

    /**
     * Get the staff user who processed the request.
     */
    public function processedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'processed_by');
    }

    /**
     * Get the absence excuse details associated with the request.
     */
    public function absenceExcuse(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(AbsenceExcuse::class);
    }
}

