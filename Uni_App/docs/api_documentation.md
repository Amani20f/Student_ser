# University Ecosystem - API Documentation

This document provides technical details for testing the implemented API endpoints.

**Base URL**: `http://localhost:8000/api`
**Headers**:
- `Accept`: `application/json`
- `Authorization`: `Bearer {YOUR_TOKEN}` (Required for protected routes)

---

## 🔐 Authentication

### 1. Login
- **Endpoint**: `POST /login`
- **Body**: `{"email": "...", "password": "..."}`

### 2. Logout
- **Endpoint**: `POST /logout`
- **Auth**: Required

### 3. Change Password
- **Endpoint**: `PUT /change-password`
- **Body**: `{"current_password": "...", "new_password": "...", "new_password_confirmation": "..."}`

### 4. Forgot Password
- **Endpoint**: `POST /forgot-password`
- **Body**: `{"email": "..."}`

### 5. Reset Password
- **Endpoint**: `POST /reset-password`
- **Body**: `{"email": "...", "token": "...", "password": "...", "password_confirmation": "..."}`

---

## 🎓 Student Portal (Role: `student`)

### 1. Notifications
- **List**: `GET /student/notifications`
- **Mark Read**: `PUT /student/notifications/{id}/read`

### 2. Submit Service Request
- **Endpoint**: `POST /student/service-requests`
- **Body**:
  - `type_id`: (int) ID of Request Type (Absence, Grievance, etc.)
  - `form_data`: (json) specific fields for the request

### 3. My Requests
- **Endpoint**: `GET /student/my-requests`

### 4. Submit Payment
- **Endpoint**: `POST /student/payments`
- **Body**: `{"semester_id": 1, "amount": 500, "receipt_image": (file)}`

### 5. Grades
- **Endpoint**: `GET /student/grades`

---

## 🏛️ Staff Operations

### 1. Request Management (Role: `grade_control`, `student_affairs`, `admin`)
*Requests are automatically routed based on the Staff's Role.*

- **List Pending**: `GET /staff/requests`
- **Update Status**: `PUT /staff/service-requests/{id}/status`
  - **Body**: `{"status": "approved" | "rejected", "response_message": "..."}`
- **Ratify Absence**: `POST /staff/requests/{id}/ratify`
  - **Body**: `{"items": [...], "response_message": "..."}`

### 2. Payment Verification (Role: `accountant`, `admin`)
- **Pending Payments**: `GET /staff/payments/pending`
- **Verify**: `PUT /staff/payments/{id}/verify`
- **Reject**: `PUT /staff/payments/{id}/reject`
  - **Body**: `{"reason": "Receipt is blurry"}`

### 3. Grade Management (Role: `grade_control`, `admin`)
- **Update Grade**: `PUT /staff/grades/{id}`
- **Program Grades**: `GET /staff/programs/{programId}/grades`

---

## 🛡️ Admin Operations (Role: `admin`)

**Global Access**: Admin bypasses all departmental filters and sees all requests/payments.

### 1. Student Management
- **List Students**: `GET /admin/students`
- **Delete Student**: `DELETE /admin/students/{id}`

### 2. Staff Management
- **List Staff**: `GET /admin/staff`
- **Create Staff**: `POST /admin/staff`
- **Delete Staff**: `DELETE /admin/staff/{id}`

### 3. System Overview
- **Stats**: `GET /admin/stats`
- **Logs**: `GET /admin/logs`

---

## 🧪 Request Types (Seeded)
| Slug | Target Role | Description |
|------|-------------|-------------|
| `absence_excuse` | `student_affairs` | Submit excuse for absence |
| `suspension_of_enrollment` | `student_affairs` | Request suspension |
| `re_enrollment` | `student_affairs` | Request re-enrollment |
| `grade_grievance` | `grade_control` | Grade dispute |
