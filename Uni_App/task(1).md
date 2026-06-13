# Database Restructuring Task List

- [ ] **Identity & Profile (1:1 Logic)**
    - [x] Update `create_users_table` migration (username, role ENUM) <!-- id: 0 -->
    - [x] Update `create_students_table` migration (phone, strict FK) <!-- id: 1 -->
    - [x] Update `User` Model (fillable, casts, relationships) <!-- id: 2 -->
    - [x] Update `Student` Model (fillable, relationships) <!-- id: 3 -->

- [ ] **Static Academic Hierarchy**
    - [x] Update `create_colleges_table` migration <!-- id: 4 -->
    - [x] Update `create_departments_table` migration <!-- id: 5 -->
    - [x] Update `create_programs_table` migration <!-- id: 6 -->
    - [x] Update `create_courses_table` migration (move department_id to program_id) <!-- id: 7 -->
    - [x] Update Hierarchy Models (`College`, `Department`, `Program`, `Course`) <!-- id: 8 -->

- [x] **Temporal Logic & Performance**
    - [x] Update `create_semesters_table` migration <!-- id: 9 -->
    - [x] Update `create_grades_table` migration (detailed breakdown, strict constraints) <!-- id: 10 -->
    - [x] Update Temporal Models (`Semester`, `Grade`) <!-- id: 11 -->

- [x] **Service Ecosystem & Financials**
    - [x] Create `create_request_types_table` migration <!-- id: 12 -->
    - [x] Update `create_requests_table` migration (link to request_type, attachment) <!-- id: 13 -->
    - [x] Update `create_payments_table` migration (receipt_image, amount type) <!-- id: 14 -->
    - [x] Update/Create Service Models (`RequestType`, `Request`, `Payment`) <!-- id: 15 -->

- [x] **Communications & Security Audit**
    - [x] Create `create_notifications_table` migration <!-- id: 16 -->
    - [x] Create `create_notification_user_table` migration <!-- id: 17 -->
    - [x] Update `create_activity_logs_table` migration (JSONB) <!-- id: 18 -->
    - [x] Update/Create Security Models (`Notification`, `ActivityLog`) <!-- id: 19 -->

- [x] **Verification**
    - [x] Run `php artisan migrate:fresh` <!-- id: 20 -->
    - [x] Verify Schema <!-- id: 21 -->
