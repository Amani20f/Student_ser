# Implementation Plan - University Service Ecosystem (Static Study Plan)

This plan outlines the restructuring of the database schema to support the "Read/Service-only" student portal logic, strict academic hierarchy, and detailed grading system.

## Goal
Transition the current schema to a strict, level-based curriculum system with enhanced service features (Requests, Payments, Notifications) and detailed audit trails.

## User Review Required
> [!IMPORTANT]
> **Data Structure Changes**:
> *   **Users**: Adding `username` and native `role` ENUM.
> *   **Courses**: Moving ownership from `Department` to `Program` to support strict curriculum mapping.
> *   **Grades**: Expanding from a single `grade` column to detailed breakdown (`first`, `second`, `midterm`, `final`, `total`).
> *   **Requests**: separation into `RequestType` catalog and `Request` entries.
> *   **PostgreSQL Strictness**: Enforcing `JSONB` for logs and `DECIMAL` for financials.

## Proposed Schema (Mermaid ERD)

```mermaid
erDiagram
    User ||--o| Student : "identifies"
    User ||--o{ Request : "processes"
    User ||--o{ Payment : "verifies"
    User ||--o{ ActivityLog : "performs"
    User ||--o{ NotificationUser : "receives"

    College ||--o{ Department : "contains"
    Department ||--o{ Program : "offers"
    Program ||--o{ Course : "defines_curriculum"
    Program ||--o{ Student : "enrolls"

    Student ||--o{ Grade : "earns"
    Student ||--o{ Request : "submits"
    Student ||--o{ Payment : "pays"

    Course ||--o{ Grade : "graded_in"
    Semester ||--o{ Grade : "recorded_in"
    Semester ||--o{ Payment : "applies_to"

    RequestType ||--o{ Request : "categorizes"
    Notification ||--o{ NotificationUser : "targets"

    User {
        bigint id PK
        string username "UK"
        string email "UK"
        string password
        enum role "admin, student_affairs, grade_control, accountant, student"
    }

    Student {
        bigint id PK
        string student_number "UK"
        string phone
        int current_level
        enum status "active, suspended, graduated"
        bigint user_id FK "UK"
        bigint program_id FK
    }

    Course {
        bigint id PK
        string course_code "UK"
        string name
        int semester_level
        bigint program_id FK
    }

    Grade {
        bigint id PK
        bigint student_id FK
        bigint course_id FK
        bigint semester_id FK
        decimal first "nullable"
        decimal second "nullable"
        decimal midterm "nullable"
        decimal final "nullable"
        decimal total
        decimal gpa
        enum status "passed, failed"
    }

    Request {
        bigint id PK
        bigint student_id FK
        bigint request_type_id FK
        string description
        string attachment "path"
        enum status "pending, approved, rejected"
        bigint processed_by FK "nullable"
    }

    Payment {
        bigint id PK
        bigint student_id FK
        bigint semester_id FK
        decimal amount "12,2"
        string receipt_image "path"
        enum status "pending, verified, rejected"
    }

    ActivityLog {
        bigint id PK
        bigint user_id FK
        string action
        string model_type
        bigint model_id
        jsonb old_values
        jsonb new_values
    }
```

## Proposed Changes

### 1. Identity & Profile
*   **Modify `users`**:
    *   Add `username` (string, unique).
    *   Add `role` (enum: 'admin', 'student_affairs', 'grade_control', 'accountant', 'student').
*   **Modify `students`**:
    *   Add `phone` (string).
    *   Ensure `user_id` is unique and strictly linked.

### 2. Static Academic Hierarchy
*   **Modify `courses`**:
    *   Add `program_id` (FK).
    *   Drop `department_id` (Logic: Courses belong to a Program's curriculum).

### 3. Temporal Logic & Performance
*   **Modify `grades`**:
    *   Add `first`, `second`, `midterm`, `final` (nullable decimals).
    *   Add `total` (decimal).
    *   Retain `gpa` and `status`.
*   **Modify `semesters`**:
    *   Ensure `year` and `term` structure matches requirements.

### 4. Service Ecosystem
*   **Create `request_types`**:
    *   `name`, `description`, `is_active`.
*   **Modify `requests`**:
    *   Add `request_type_id` (FK).
    *   Remove `request_type` string column.
    *   Add `attachment` (string path).
*   **Modify `payments`**:
    *   Rename `transaction_reference` to `receipt_image` (or keep both if online payment is also needed, but prompt specifies `receipt_image`).
    *   Ensure `amount` is `DECIMAL(12,2)`.

### 5. Communications & Security
*   **Create `notifications`**:
    *   `title`, `message`, `target_type`.
*   **Create `notification_user`** (Pivot):
    *   `notification_id`, `user_id`, `is_read`.
*   **Modify `activity_logs`**:
    *   Ensure `old_values` and `new_values` use `JSONB` type for PostgreSQL.

## Verification Plan
1.  **Run Migrations**: Execute `php artisan migrate:fresh` to apply the strict new schema.
2.  **Model Inspection**: Verify Models have correct `$fillable`, `casts`, and relationships (`belongsTo`, `hasMany`).
3.  **Constraint Testing**: Attempt to insert invalid data (e.g., duplicate student number) to test database-level constraints.
