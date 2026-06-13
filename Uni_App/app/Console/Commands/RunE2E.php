<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

class RunE2E extends Command
{
    protected $signature = 'e2e:run';
    protected $description = 'Run End-to-End API tests against live seeded DB';

    public function handle()
    {
        $this->info("Running E2E tests...");

        $admin = \App\Models\User::role('admin')->first();
        $studentUser = \App\Models\User::role('student')->first();
        $staffUser = \App\Models\User::role('student_affairs')->first();
        $gradeStaff = \App\Models\User::role('grade_control')->first();
        $accountant = \App\Models\User::role('accountant')->first();

        if (!$studentUser) {
            $this->error("No student user found.");
            return;
        }

        $results = [];

        $results['student_grades'] = $this->makeRequest('GET', '/api/student/grades', $studentUser);
        $results['student_payments'] = $this->makeRequest('GET', '/api/student/payments', $studentUser);
        $results['student_requests'] = $this->makeRequest('GET', '/api/student/my-requests', $studentUser);
        $results['student_appeals'] = $this->makeRequest('GET', '/api/student/appeals', $studentUser);
        $results['student_study_schedules'] = $this->makeRequest('GET', '/api/student/study-schedules', $studentUser);

        $results['admin_stats'] = $this->makeRequest('GET', '/api/admin/stats', $admin);
        $results['staff_requests'] = $this->makeRequest('GET', '/api/staff/requests', $staffUser);
        $results['staff_grades'] = $this->makeRequest('GET', '/api/staff/grades', $gradeStaff);
        $results['staff_appeals'] = $this->makeRequest('GET', '/api/staff/appeals', $accountant);
        $results['staff_study_schedules'] = $this->makeRequest('GET', '/api/staff/study-schedules', $admin);

        file_put_contents(base_path('e2e_results.json'), json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        $this->info("Saved to e2e_results.json");
    }

    private function makeRequest($method, $uri, $user)
    {
        try {
            $request = Request::create($uri, $method);
            auth('sanctum')->setUser($user);
            $response = app()->handle($request);
            
            return [
                'status' => $response->getStatusCode(),
                'content' => json_decode($response->getContent(), true) ?? $response->getContent()
            ];
        } catch (\Exception $e) {
            return [
                'status' => 500,
                'content' => ['error' => $e->getMessage()]
            ];
        }
    }
}
