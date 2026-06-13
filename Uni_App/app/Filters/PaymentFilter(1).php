<?php

namespace App\Filters;

class PaymentFilter extends QueryFilter
{
    public function status($value)
    {
        $this->where('status', $value);
    }

    public function semester_id($value)
    {
        $this->where('semester_id', $value);
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

    public function min_amount($value)
    {
        $this->builder->where('amount', '>=', $value);
    }

    public function max_amount($value)
    {
        $this->builder->where('amount', '<=', $value);
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
                $q->where('name', 'like', "%{$value}%");
            })->orWhere('purpose', 'like', "%{$value}%");
        });
    }
}
