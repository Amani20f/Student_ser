<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Announcement extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'image_path',
        'target_audience',
        'target_college_id',
        'target_program_id',
        'is_active',
        'published_at',
        'expires_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'published_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    protected $appends = ['image_url'];

    public function getImageUrlAttribute()
    {
        return $this->image_path ? asset('storage/' . $this->image_path) : null;
    }

    /**
     * Get the college targeted by this announcement (if applicable).
     */
    public function targetCollege()
    {
        return $this->belongsTo(College::class, 'target_college_id');
    }

    /**
     * Get the program targeted by this announcement (if applicable).
     */
    public function targetProgram()
    {
        return $this->belongsTo(Program::class, 'target_program_id');
    }
}
