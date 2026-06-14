<?php

use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\Admin\StaffManagementController;
use App\Http\Controllers\Api\Admin\UserManagementController;
use App\Http\Controllers\Api\Admin\RequestTypeController;
use App\Http\Controllers\Api\Admin\StudentApplicationManagementController;
use App\Http\Controllers\Api\Admin\AnnouncementController as AdminAnnouncementController;
use App\Http\Controllers\Api\Admin\SurveyController as AdminSurveyController;
use App\Http\Controllers\Api\Student\AnnouncementController as StudentAnnouncementController;
use App\Http\Controllers\Api\Student\SurveyController as StudentSurveyController;
use App\Http\Controllers\Api\AcademicStructureController;
use App\Http\Controllers\Api\ServiceRequestController;
use App\Http\Controllers\Api\StudentApplicationController;
use App\Http\Controllers\Api\Staff\GradeManagementController;
use App\Http\Controllers\Api\Staff\GradeImportController;
use App\Http\Controllers\Api\Staff\StudyScheduleController as StaffStudyScheduleController;
use App\Http\Controllers\Api\Staff\PaymentController as StaffPaymentController;
use App\Http\Controllers\Api\Staff\RequestController as StaffRequestController;
use App\Http\Controllers\Api\Student\GradeController;
use App\Http\Controllers\Api\Student\StudyScheduleController as StudentStudyScheduleController;
use App\Http\Controllers\Api\Student\PaymentController as StudentPaymentController;
use App\Http\Controllers\Api\Student\RequestController as StudentRequestController;
use App\Http\Controllers\Api\Student\ProfileController;
use App\Http\Controllers\Api\Student\AcademicRecordController;
use Illuminate\Support\Facades\Route;

// ── Public Routes (No Authentication Required) ──────────────────────────────

// Academic Structure — used by student portal forms and registration screen
Route::get('/colleges', [AcademicStructureController::class, 'colleges']);
Route::get('/programs',  [AcademicStructureController::class, 'programs']);
Route::get('/semesters', [AcademicStructureController::class, 'semesters']);

// Student Registration Application — public submission
Route::post('/apply', [StudentApplicationController::class, 'store']);
Route::get('/apply/{applicationNumber}/status', [StudentApplicationController::class, 'checkStatus']);
Route::get('/apply/status/{nationalId}', [StudentApplicationController::class, 'checkStatusByNationalId']);

// Auth
Route::post('/login', [AuthController::class, 'login']);

/**
 * Protected Routes
 */
Route::middleware('auth:sanctum')->group(function () {
    
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/change-password', [AuthController::class, 'changePassword']);

    // Password Reset
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->withoutMiddleware('auth:sanctum');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->withoutMiddleware('auth:sanctum');

    /**
     * Admin Endpoints (Role: admin)
     */
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('/stats', [AdminController::class, 'getStats']);
        Route::get('/logs', [AdminController::class, 'getLogs']);

        // Staff Management (read + create + update — no delete of admins)
        Route::apiResource('staff', StaffManagementController::class);

        // Program Management
        Route::apiResource('programs', \App\Http\Controllers\Api\Admin\ProgramController::class);
        Route::post('/programs/{program}/restore', [\App\Http\Controllers\Api\Admin\ProgramController::class, 'restore']);

        // Course Management
        Route::apiResource('courses', \App\Http\Controllers\Api\Admin\CourseController::class);
        Route::post('/courses/{course}/restore', [\App\Http\Controllers\Api\Admin\CourseController::class, 'restore']);

        // Semester Management
        Route::apiResource('semesters', \App\Http\Controllers\Api\Admin\SemesterController::class);

        // Student Management (read-only)
        Route::apiResource('students', \App\Http\Controllers\Api\Admin\StudentManagementController::class)->only(['index', 'destroy']);

        // User Management (create any role, delete any user, update info & passwords)
        Route::get('/users', [UserManagementController::class, 'index']);
        Route::post('/users', [UserManagementController::class, 'store']);
        Route::put('/users/{user}', [UserManagementController::class, 'update']);
        Route::delete('/users/{user}', [UserManagementController::class, 'destroy']);
        Route::put('/users/{user}/password', [UserManagementController::class, 'updatePassword']);

        // Request Type Management
        Route::get('/request-types', [RequestTypeController::class, 'index']);
        Route::post('/request-types', [RequestTypeController::class, 'store']);
        Route::put('/request-types/{requestType}', [RequestTypeController::class, 'update']);
        Route::patch('/request-types/{requestType}/toggle', [RequestTypeController::class, 'toggle']);

    });

    /**
     * Shared Admin/Student Affairs Endpoints
     */
    Route::middleware('role:admin|student_affairs')->prefix('admin')->group(function () {
        // Student Application Management
        Route::get('/applications', [StudentApplicationManagementController::class, 'index']);
        Route::get('/applications/{id}', [StudentApplicationManagementController::class, 'show']);
        Route::post('/applications/{id}/approve', [StudentApplicationManagementController::class, 'approve']);
        Route::post('/applications/{id}/reject', [StudentApplicationManagementController::class, 'reject']);
    });

    /**
     * Student Endpoints
     */
    Route::middleware('role:student')->prefix('student')->group(function () {
        // Profile
        Route::get('/profile', [ProfileController::class, 'show']);
        Route::put('/profile', [ProfileController::class, 'update']);
        Route::put('/change-password', [ProfileController::class, 'changePassword']);

        // Grades & Academic Records
        Route::get('/grades', [GradeController::class, 'index']);
        Route::get('/results', [AcademicRecordController::class, 'results']);
        Route::get('/transcript', [AcademicRecordController::class, 'transcript']);
        
        // Payments
        Route::get('/payments', [StudentPaymentController::class, 'index']);
        Route::post('/payments', [StudentPaymentController::class, 'store']);
        
        // Service Requests (Original controller - kept for backward compatibility)
        Route::get('/requests', [StudentRequestController::class, 'index']);
        Route::get('/requests/{id}', [StudentRequestController::class, 'show']);
        Route::post('/requests', [StudentRequestController::class, 'store']);
        
        // Active Request Types for Student Portal
        Route::get('/request-types', [\App\Http\Controllers\Api\Admin\RequestTypeController::class, 'activeTypes']);
        
        // Service Requests (New dynamic system with validation)
        Route::post('/service-requests', [ServiceRequestController::class, 'store']);
        Route::get('/service-requests/{id}', [ServiceRequestController::class, 'show']);
        Route::get('/my-requests', [ServiceRequestController::class, 'studentRequests']);
        
        // Re-enrollment Workflow
        Route::post('/re-enrollment', [\App\Http\Controllers\Api\ReEnrollmentController::class, 'store']);

        // Notifications
        Route::get('/notifications', [\App\Http\Controllers\Api\Student\NotificationController::class, 'index']);
        Route::put('/notifications/{id}/read', [\App\Http\Controllers\Api\Student\NotificationController::class, 'markAsRead']);

        // Announcements
        Route::get('/announcements', [StudentAnnouncementController::class, 'index']);

        // Surveys
        Route::post('/surveys/complete', [StudentSurveyController::class, 'complete']);

        // Grade Appeals
        Route::get('/appeals', [\App\Http\Controllers\Api\Student\AppealController::class, 'index']);
        Route::post('/appeals', [\App\Http\Controllers\Api\Student\AppealController::class, 'store']);
        Route::get('/appeals/{id}', [\App\Http\Controllers\Api\Student\AppealController::class, 'show']);
        Route::post('/appeals/pay', [\App\Http\Controllers\Api\Student\AppealController::class, 'submitPayment']);

        // Academic Suspension Requests
        Route::post('/suspension-request', [\App\Http\Controllers\Api\Student\SuspensionRequestController::class, 'store']);
        Route::get('/suspension-requests', [\App\Http\Controllers\Api\Student\SuspensionRequestController::class, 'index']);
        Route::get('/suspension-requests/{id}', [\App\Http\Controllers\Api\Student\SuspensionRequestController::class, 'show']);

        // Study Schedules & Plans
        Route::get('/study-schedules', [StudentStudyScheduleController::class, 'show']);
        Route::get('/study-plan', [\App\Http\Controllers\Api\Student\StudyPlanController::class, 'show']);
        Route::get('/study-schedule', [\App\Http\Controllers\Api\Student\StudyScheduleController::class, 'show']);
    });

    /**
     * Staff Endpoints (Accountant, Grade Control, Admin)
     */
    Route::prefix('staff')->group(function () {

        // Notifications Management
        Route::get('/users', [\App\Http\Controllers\Api\Staff\NotificationController::class, 'users']);
        Route::get('/notifications', [\App\Http\Controllers\Api\Staff\NotificationController::class, 'index']);
        Route::put('/notifications/{id}/read', [\App\Http\Controllers\Api\Staff\NotificationController::class, 'markAsRead']);
        Route::post('/notifications', [\App\Http\Controllers\Api\Staff\NotificationController::class, 'store']);

        // Appeal Management — Accountant
        Route::middleware('role:accountant|admin')->group(function () {
            Route::get('/appeals/pending-payment', [\App\Http\Controllers\Api\Staff\AppealManagementController::class, 'pendingPayment']);
        });
        Route::middleware('role:accountant')->group(function () {
            Route::put('/appeals/{id}/verify-payment', [\App\Http\Controllers\Api\Staff\AppealManagementController::class, 'verifyPayment']);
        });

        // Appeal Management — Grade Control
        Route::middleware('role:grade_control|admin')->group(function () {
            Route::get('/appeals/under-review', [\App\Http\Controllers\Api\Staff\AppealManagementController::class, 'underReview']);
        });
        Route::middleware('role:grade_control')->group(function () {
            Route::put('/appeals/{id}/review', [\App\Http\Controllers\Api\Staff\AppealManagementController::class, 'review']);
        });

        // Common Appeal Management (Staff)
        Route::middleware('role:accountant|grade_control|admin')->group(function () {
            Route::get('/appeals', [\App\Http\Controllers\Api\Staff\AppealManagementController::class, 'index']);
            Route::get('/appeals/{id}', [\App\Http\Controllers\Api\Staff\AppealManagementController::class, 'show']);
        });

        // Grade Management — read access for admin, write only for grade_control
        Route::middleware('role:grade_control|admin')->group(function () {
            Route::get('/grades', [GradeManagementController::class, 'indexBySemester']);
            Route::get('/programs/{programId}/grades', [GradeManagementController::class, 'indexByProgram']);
        });
        Route::middleware('role:grade_control')->group(function () {
            Route::put('/grades/{id}', [GradeManagementController::class, 'update']);
            // Excel Import
            Route::post('/grades/import/preview', [GradeImportController::class, 'preview']);
            Route::post('/grades/import/store', [GradeImportController::class, 'store']);
        });

        // Payment Management — read access for admin, write only for accountant
        Route::middleware('role:accountant|admin')->group(function () {
            Route::get('/payments', [StaffPaymentController::class, 'index']);
        });
        Route::middleware('role:accountant')->group(function () {
            Route::put('/payments/{id}/verify', [StaffPaymentController::class, 'verify']);
            Route::put('/payments/{id}/reject', [StaffPaymentController::class, 'reject']);
        });

        // Service Request Management — read access for admin, write only for student_affairs
        Route::middleware('role:student_affairs|admin')->group(function () {
            Route::get('/requests', [App\Http\Controllers\Api\Staff\RequestController::class, 'index']);
            Route::get('/re-enrollment/{id}', [\App\Http\Controllers\Api\ReEnrollmentController::class, 'show']);

            // Surveys
            Route::apiResource('surveys', AdminSurveyController::class);
            Route::patch('/surveys/{survey}/toggle', [AdminSurveyController::class, 'toggle']);

            // Announcements
            Route::apiResource('announcements', AdminAnnouncementController::class);
            Route::patch('/announcements/{announcement}/toggle', [AdminAnnouncementController::class, 'toggle']);
        });
        Route::middleware('role:student_affairs')->group(function () {
            Route::patch('/requests/{id}/status', [App\Http\Controllers\Api\Staff\RequestController::class, 'updateStatus']);
            Route::post('/requests/{id}/ratify', [App\Http\Controllers\Api\Staff\RequestController::class, 'ratify']);

            // Service Requests (New dynamic system)
            Route::put('/service-requests/{id}/status', [ServiceRequestController::class, 'updateStatus']);

            // Re-enrollment Workflow (write)
            Route::put('/re-enrollment/{id}/ratify', [\App\Http\Controllers\Api\ReEnrollmentController::class, 'ratify']);
            Route::put('/re-enrollment/{id}/approve', [\App\Http\Controllers\Api\ReEnrollmentController::class, 'approve']);
            Route::put('/re-enrollment/{id}/reject', [\App\Http\Controllers\Api\ReEnrollmentController::class, 'reject']);

            // Study Plans and Schedules Documents — student_affairs full CRUD
            Route::apiResource('study-plans', \App\Http\Controllers\Api\Staff\StudyPlanController::class)->except(['show']);
            Route::apiResource('study-schedules', StaffStudyScheduleController::class)->except(['show']);
        });
    });
});
