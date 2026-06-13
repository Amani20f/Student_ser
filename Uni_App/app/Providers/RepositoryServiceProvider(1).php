<?php

namespace App\Providers;

use App\Repositories\Contracts\ActivityLogRepositoryInterface;
use App\Repositories\Contracts\CourseRepositoryInterface;
use App\Repositories\Contracts\GradeRepositoryInterface;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use App\Repositories\Contracts\SemesterRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use App\Repositories\Eloquent\ActivityLogRepository;
use App\Repositories\Eloquent\CourseRepository;
use App\Repositories\Eloquent\GradeRepository;
use App\Repositories\Eloquent\PaymentRepository;
use App\Repositories\Eloquent\SemesterRepository;
use App\Repositories\Eloquent\StudentRepository;
use App\Repositories\Contracts\RequestRepositoryInterface;
use App\Repositories\Eloquent\RequestRepository;
use App\Repositories\Contracts\AppealRepositoryInterface;
use App\Repositories\Eloquent\AppealRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->bind(StudentRepositoryInterface::class, StudentRepository::class);
        $this->app->bind(GradeRepositoryInterface::class, GradeRepository::class);
        $this->app->bind(PaymentRepositoryInterface::class, PaymentRepository::class);
        $this->app->bind(CourseRepositoryInterface::class, CourseRepository::class);
        $this->app->bind(SemesterRepositoryInterface::class, SemesterRepository::class);
        $this->app->bind(ActivityLogRepositoryInterface::class, ActivityLogRepository::class);
        $this->app->bind(RequestRepositoryInterface::class, RequestRepository::class);
        $this->app->bind(AppealRepositoryInterface::class, AppealRepository::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
