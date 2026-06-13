<?php

namespace App\Filters;

class RequestFilter extends QueryFilter
{
    public function status($value)
    {
        $this->where('status', $value);
    }

    public function request_type_id($value)
    {
        $this->where('request_type_id', $value);
    }

    public function student_id($value)
    {
        $this->where('student_id', $value);
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

    public function from_date($value)
    {
        $this->builder->where('created_at', '>=', $value . ' 00:00:00');
    }

    public function to_date($value)
    {
        $this->builder->where('created_at', '<=', $value . ' 23:59:59');
    }

    public function search($value)
    {
        $this->builder->where(function ($query) use ($value) {
            $query->whereHas('student.user', function ($q) use ($value) {
                $q->where('name', 'like', "%{$value}%")
                  ->orWhere('email', 'like', "%{$value}%");
            })->orWhereHas('student', function ($q) use ($value) {
                $q->where('student_number', 'like', "%{$value}%");
            });
        });
    }
}
