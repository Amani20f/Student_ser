<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Survey extends Model
{
    protected $fillable = [
        'title',
        'google_form_url',
        'semester_id',
        'is_active',
        'is_required_for_grades',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_required_for_grades' => 'boolean',
    ];

    public function semester()
    {
        return $this->belongsTo(Semester::class);
    }
}
