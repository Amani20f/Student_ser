<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StudyPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'program_id',
        'title',
        'file_path',
        'uploaded_by',
    ];

    public function program(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Program::class);
    }

    public function uploader(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
