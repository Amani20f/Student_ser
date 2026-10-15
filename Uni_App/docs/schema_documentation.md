# Database Schema Documentation

This document provides a detailed overview of the database tables and their attributes for the University API.

## 1. Colleges
Represents the colleges within the university (e.g., College of Engineering).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `name` | `VARCHAR` | `UNIQUE` | Name of the college. |
| `code` | `VARCHAR(10)` | `UNIQUE` | Abbreviation code (e.g., COE). |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 2. Departments
Represents academic departments belonging to a college (e.g., Computer Science).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `college_id` | `BIGINT` | `FK` -> `colleges.id` | The college this department belongs to. Deletes cascade. |
| `name` | `VARCHAR` | | Name of the department. |
| `code` | `VARCHAR(10)` | `UNIQUE` | Abbreviation code (e.g., CS). |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 3. Programs
Represents academic programs offered by departments (e.g., BS in Computer Science).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `department_id` | `BIGINT` | `FK` -> `departments.id` | The department offering this program. Deletes cascade. |
| `name` | `VARCHAR` | | Name of the program. |
| `code` | `VARCHAR(20)` | `UNIQUE` | Program code (e.g., BSCS). |
| `duration_years` | `INTEGER` | `DEFAULT 4` | Standard duration of the program. |
| `degree_type` | `ENUM` | `bachelor`, `master`, `phd` | Type of degree awarded. Default: `bachelor`. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 4. Courses
Represents individual courses/subjects offered.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `department_id` | `BIGINT` | `FK` -> `departments.id` | The department offering this course. Deletes cascade. |
| `course_code` | `VARCHAR(20)` | `UNIQUE` | Course code (e.g., CS101). |
| `course_name` | `VARCHAR` | | Full name of the course. |
| `credit_hours` | `INTEGER` | | Number of credit hours. |
| `semester_level` | `INTEGER` | `INDEX` | The curriculum semester/level (1-8). |
| `description` | `TEXT` | `NULLABLE` | Course description. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 5. Students
Represents enrolled students. Linked to a User account.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `user_id` | `BIGINT` | `FK` -> `users.id`, `UNIQUE` | Linked user account. Deletes cascade. |
| `student_number` | `VARCHAR(20)` | `UNIQUE` | Official student identification number. |
| `program_id` | `BIGINT` | `FK` -> `programs.id` | The program the student is enrolled in. |
| `current_level` | `INTEGER` | `DEFAULT 1` | Current year level (e.g., 1, 2, 3, 4). |
| `gpa` | `DECIMAL(3,2)` | `DEFAULT 0.00` | Current Grade Point Average. |
| `enrollment_date` | `DATE` | | Date of enrollment. |
| `status` | `ENUM` | `active`, `suspended`, `graduated` | Current status of the student. Default: `active`. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 6. Semesters
Represents academic terms.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `academic_year` | `INTEGER` | | The year of the semester (e.g., 2024). |
| `term` | `ENUM` | `fall`, `spring`, `summer` | The term of the semester. |
| `start_date` | `DATE` | | Start date of the semester. |
| `end_date` | `DATE` | | End date of the semester. |
| `is_active` | `BOOLEAN` | `DEFAULT false` | Whether this is the currently active semester. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |
| **Unique Key** | | `(academic_year, term)` | Ensures unique semesters per year. |

## 7. Grades
Represents a student's grade for a specific course in a semester.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `student_id` | `BIGINT` | `FK` -> `students.id` | The student receiving the grade. Deletes cascade. |
| `course_id` | `BIGINT` | `FK` -> `courses.id` | The course being graded. Deletes cascade. |
| `semester_id` | `BIGINT` | `FK` -> `semesters.id` | The semester when the course was taken. |
| `grade` | `DECIMAL(5,2)` | | Numeric grade (0.00 - 100.00). |
| `status` | `ENUM` | `passed`, `failed` | Pass/Fail status. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |
| **Unique Key** | | `(student_id, course_id, semester_id)` | Prevents duplicate grades for the same course attempt. |

## 8. Payments
Represents financial transactions made by students.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `student_id` | `BIGINT` | `FK` -> `students.id` | The student making the payment. Deletes cascade. |
| `semester_id` | `BIGINT` | `FK` -> `semesters.id` | The semester this payment applies to. |
| `amount` | `DECIMAL(10,2)` | | The amount paid. |
| `transaction_reference` | `VARCHAR(100)` | `UNIQUE` | Unique reference for the transaction. |
| `status` | `ENUM` | `pending`, `verified`, `rejected` | Status of the payment. Default: `pending`. |
| `verified_at` | `TIMESTAMP` | `NULLABLE` | Timestamp when payment was verified. |
| `verified_by` | `BIGINT` | `FK` -> `users.id`, `NULLABLE` | Staff user who verified the payment. |
| `notes` | `TEXT` | `NULLABLE` | Administration notes. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 9. Request Types
Represents the types of requests available (e.g., Absence Excuse, Transcript).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `name` | `VARCHAR` | `UNIQUE` | Name of the request type. |
| `slug` | `VARCHAR` | `UNIQUE` | URL-friendly identifier. |
| `description` | `TEXT` | `NULLABLE` | Description of the request type. |
| `is_active` | `BOOLEAN` | `DEFAULT true` | Whether the request type is currently available. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 10. Requests
Represents student requests (e.g., Grade Appeal, Transcript).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `student_id` | `BIGINT` | `FK` -> `students.id` | The student making the request. Deletes cascade. |
| `request_type_id` | `BIGINT` | `FK` -> `request_types.id` | The type of request. Deletes cascade. |
| `description` | `TEXT` | | Detailed description of the request. |
| `attachment` | `VARCHAR` | `NULLABLE` | Path to uploaded supporting documents. |
| `status` | `ENUM` | `pending`, `accepted`, `rejected` | Status of the request. Default: `pending`. |
| `form_data` | `JSON` | `NULLABLE` | Dynamic form data in JSON format. |
| `admin_notes` | `TEXT` | `NULLABLE` | Internal notes for admins. |
| `is_notified` | `BOOLEAN` | `DEFAULT false` | Whether the student has been notified of the status change. |
| `processed_by` | `BIGINT` | `FK` -> `users.id`, `NULLABLE` | Staff user who processed the request. |
| `created_at` | `TIMESTAMP` | | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | | Record update timestamp. |

## 11. Activity Logs
Tracks audit trails for actions performed in the system.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `BIGINT` | `PK`, `AUTO_INCREMENT` | Unique identifier. |
| `user_id` | `BIGINT` | `FK` -> `users.id` | User who performed the action. |
| `model_type` | `VARCHAR` | | Class name of the affected model (e.g., `App\Models\Grade`). |
| `model_id` | `BIGINT` | | ID of the affected model record. |
| `action` | `VARCHAR(20)` | | Action performed (e.g., `created`, `updated`, `deleted`). |
| `old_values` | `JSON` | `NULLABLE` | Data state before the action. |
| `new_values` | `JSON` | `NULLABLE` | Data state after the action. |
| `ip_address` | `VARCHAR(45)` | `NULLABLE` | IP address of the user. |
| `user_agent` | `TEXT` | `NULLABLE` | User agent string (browser/device info). |
| `created_at` | `TIMESTAMP` | | Timestamp of the action. |
| **Indexes** | | `(user_id, created_at)`, `(model_type, model_id)` | For efficient querying. 