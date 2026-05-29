<?php

namespace App\Filters;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

abstract class QueryFilter
{
    /**
     * @var Request
     */
    protected $request;

    /**
     * @var Builder
     */
    protected $builder;

    /**
     * @param Request $request
     */
    public function __construct(Request $request)
    {
        $this->request = $request;
    }

    /**
     * Apply the filters to the builder.
     *
     * @param Builder $builder
     * @return Builder
     */
    public function apply(Builder $builder): Builder
    {
        $this->builder = $builder;

        foreach ($this->filters() as $filter => $value) {
            if (method_exists($this, $filter)) {
                $this->$filter($value);
            }
        }

        return $this->builder;
    }

    /**
     * Get all request filters data.
     *
     * @return array
     */
    public function filters(): array
    {
        return $this->request->all();
    }

    /**
     * Helper to apply basic where filter.
     */
    protected function where(string $column, $value)
    {
        if ($value !== null && $value !== '') {
            $this->builder->where($column, $value);
        }
    }

    /**
     * Helper to apply like filter.
     */
    protected function whereLike(string $column, $value)
    {
        if ($value !== null && $value !== '') {
            $this->builder->where($column, 'like', "%{$value}%");
        }
    }

    /**
     * Helper to apply date range filter.
     */
    protected function whereBetween(string $column, $from, $to)
    {
        if ($from) {
            $this->builder->where($column, '>=', $from);
        }
        if ($to) {
            $this->builder->where($column, '<=', $to);
        }
    }
}
