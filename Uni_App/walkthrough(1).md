# Walkthrough - Database Restructuring (Static Study Plan)

I have successfully restructured the database layer to align with the "Static Study Plan" architecture for the University Service Ecosystem.

## Changes Implemented

### 1. Identity & Profile
- **Users**: Added `username` (unique) and `role` (ENUM: admin, student_affairs, grade_control, accountant, student).
- **Students**: Added `phone` number, established unique 1:1 link with Users, and linked to a Program.

### 2. Static Academic Hierarchy
- **Colleges & Departments**: Standardized structure.
- **Programs**: Now serves as the primary owner of the curriculum.
- **Courses**: Migrated `department_id` to `program_id` to enforce the level-based curriculum logic.

### 3. Temporal Logic & Performance
- **Semesters**: Simplified to `year`, `term`, and `is_active` status.
- **Grades**: Expanded to a multi-column breakdown:
    - `first`, `second`, `midterm`, `final` scores.
    - Calculated `total` and `gpa`.
    - `status` (passed/failed).

### 4. Service Ecosystem & Financials
- **RequestTypes**: New entity to categorize student services (e.g., Grade Grievance).
- **Requests**: Updated to link with `RequestType`, added `attachment` support, and linked to processing staff.
- **Payments**: Standardized with `amount` (12,2 decimal), `receipt_image` path, and `status` ENUM.

### 5. Communications & Security
- **Notifications**: New entity with `target_type` (all, individual, group).
- **NotificationUser**: Pivot table tracking `is_read` status for each user.
- **ActivityLogs**: Migrated to PostgreSQL `JSONB` for high-performance audit trails of data snapshots.

## Verification Results

### Migration Success
All 17 migration files executed successfully, establishing 14 core entities with strict foreign key constraints and PostgreSQL-optimized types.

```powershell
   INFO  Running migrations.  

  0001_01_01_000000_create_users_table ................................... 89.21ms DONE
  ...
  2026_02_01_172250_create_request_types_table ........................... 23.51ms DONE
  2026_02_01_172255_create_notifications_table ........................... 47.21ms DONE
  ...
  2026_02_01_172311_create_activity_logs_table ........................... 26.20ms DONE
```

### Seeding Success
The database has been populated with virtual data to facilitate testing:
- **Users**: 12 users created (1 Admin, 1 Staff, 10 Students).
- **Hierarchy**: 3 Colleges, 3 Departments, 3 Programs, and 9 Courses.
- **Grades**: 18 historic grade records with detailed breakdowns (first, second, midterm, final).
- **Financials**: 10 verified payment records with sample receipt paths.
- **Communication**: Sample notifications linked to users.

### Security & Audit
- `ActivityLog` successfully captured all seeding events using the updated high-performance JSONB structure.
- `Observers` fixed to correctly handle the new schema during automatic logging.

