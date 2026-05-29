<?php

namespace App\Filters;

class GradeFilter extends QueryFilter
{
    public function semester_id($value)
    {
        $this->where('semester_id', $value);
    }

    public function course_id($value)
    {
        $this->where('course_id', $value);
    }

    public function program_id($value)
    {
        $this->builder->whereHas('student', function ($query) use ($value) {
            $query->where('program_id', $value);
        });
    }

    public function status($value)
    {
        if ($value === 'passed') {
            $this->builder->where('total', '>=', 50);
        } elseif ($value === 'failed') {
            $this->builder->where('total', '<', 50);
        }
    }

    public function min_total($value)
    {
        $this->builder->where('total', '>=', $value);
    }

    public function max_total($value)
    {
        $this->builder->where('total', '<=', $value);
    }

    public function search($value)
    {
        $this->builder->where(function ($query) use ($value) {
            $query->whereHas('student.user', function ($q) use ($value) {
                $q->where('name', 'like', "%{$value}%");
            })->orWhereHas('student', function ($q) use ($value) {
                $q->where('student_number', 'like', "%{$value}%");
            });
        });
    }
}
