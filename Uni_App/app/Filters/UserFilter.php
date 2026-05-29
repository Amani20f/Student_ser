<?php

namespace App\Filters;

class UserFilter extends QueryFilter
{
    public function role($value)
    {
        $this->builder->role($value);
    }

    public function status($value)
    {
        // Combined status for both User and Student
        $this->builder->where(function ($query) use ($value) {
            $query->where('status', $value)
                  ->orWhereHas('student', function ($q) use ($value) {
                      $q->where('status', $value);
                  });
        });
    }

    public function program_id($value)
    {
        $this->builder->whereHas('student', function ($q) use ($value) {
            $q->where('program_id', $value);
        });
    }

    public function current_level($value)
    {
        $this->builder->whereHas('student', function ($q) use ($value) {
            $q->where('current_level', $value);
        });
    }

    public function search($value)
    {
        $this->builder->where(function ($query) use ($value) {
            $query->where('name', 'like', "%{$value}%")
                  ->orWhere('email', 'like', "%{$value}%")
                  ->orWhereHas('student', function ($q) use ($value) {
                      $q->where('student_number', 'like', "%{$value}%");
                  });
        });
    }
}
