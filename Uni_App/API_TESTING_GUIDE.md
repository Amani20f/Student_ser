# Service Request API - Manual Testing Guide

## Overview

This guide provides cURL commands and Postman examples for manually testing the Absence Excuse service request API endpoints.

## Base URL

```
http://localhost:8000/api
```

---

## 1. Student: Submit Absence Excuse Request

### Endpoint
```
POST /student/service-requests
```

### cURL Command

```bash
curl -X POST http://localhost:8000/api/student/service-requests \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "student_id": 1,
    "type_id": 1,
    "form_data": {
      "specialization": "Computer Science",
      "level": 3,
      "college": "College of Engineering",
      "semester": "Fall",
      "academic_year": "2025/2026",
      "absence_reason": "Medical emergency requiring hospitalization for surgery and recovery period",
      "courses": [
        {
          "course_name": "Software Engineering",
          "absence_date": "2026-02-01",
          "day": "Saturday"
        },
        {
          "course_name": "Database Systems",
          "absence_date": "2026-02-03",
          "day": "Monday"
        }
      ]
    }
  }'
```

### Expected Response (201 Created)

```json
{
  "success": true,
  "message": "Request submitted successfully",
  "data": {
    "id": 1,
    "student": {
      "id": 1,
      "name": "John Doe"
    },
    "request_type": {
      "id": 1,
      "name": "Absence Excuse",
      "slug": "absence_excuse"
    },
    "status": "pending",
    "form_data": {
      "specialization": "Computer Science",
      "level": 3,
      "college": "College of Engineering",
      "semester": "Fall",
      "academic_year": "2025/2026",
      "absence_reason": "Medical emergency requiring hospitalization for surgery and recovery period",
      "courses": [
        {
          "course_name": "Software Engineering",
          "absence_date": "2026-02-01",
          "day": "Saturday"
        },
        {
          "course_name": "Database Systems",
          "absence_date": "2026-02-03",
          "day": "Monday"
        }
      ]
    },
    "submitted_at": "2026-02-07 19:30:00"
  }
}
```

---

## 2. Student: Get Specific Request

### Endpoint
```
GET /student/service-requests/{id}
```

### cURL Command

```bash
curl -X GET http://localhost:8000/api/student/service-requests/1 \
  -H "Accept: application/json"
```

### Expected Response (200 OK)

```json
{
  "success": true,
  "data": {
    "id": 1,
    "student": {
      "id": 1,
      "name": "John Doe"
    },
    "request_type": {
      "id": 1,
      "name": "Absence Excuse",
      "slug": "absence_excuse"
    },
    "status": "pending",
    "form_data": { /* ... */ },
    "admin_notes": null,
    "processed_by": null,
    "is_notified": false,
    "submitted_at": "2026-02-07 19:30:00",
    "updated_at": "2026-02-07 19:30:00"
  }
}
```

---

## 3. Staff: Accept Request

### Endpoint
```
PUT /staff/service-requests/{id}/status
```

### cURL Command

```bash
curl -X PUT http://localhost:8000/api/staff/service-requests/1/status \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "status": "accepted",
    "admin_notes": "Medical documentation verified and approved. Excuse granted for specified dates.",
    "should_notify": true
  }'
```

### Expected Response (200 OK)

```json
{
  "success": true,
  "message": "Request status updated successfully",
  "data": {
    "id": 1,
    "student": {
      "id": 1,
      "name": "John Doe"
    },
    "request_type": {
      "id": 1,
      "name": "Absence Excuse",
      "slug": "absence_excuse"
    },
    "status": "accepted",
    "admin_notes": "Medical documentation verified and approved. Excuse granted for specified dates.",
    "processed_by": 5,
    "is_notified": false,
    "updated_at": "2026-02-07 20:15:00"
  }
}
```

---

## 4. Staff: Reject Request

### Endpoint
```
PUT /staff/service-requests/{id}/status
```

### cURL Command

```bash
curl -X PUT http://localhost:8000/api/staff/service-requests/2/status \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "status": "rejected",
    "admin_notes": "Insufficient medical documentation. Please provide official hospital records.",
    "should_notify": true
  }'
```

### Expected Response (200 OK)

```json
{
  "success": true,
  "message": "Request status updated successfully",
  "data": {
    "id": 2,
    "status": "rejected",
    "admin_notes": "Insufficient medical documentation. Please provide official hospital records.",
    "processed_by": 5,
    "updated_at": "2026-02-07 20:20:00"
  }
}
```

---

## 5. Validation Error Examples

### Missing Required Fields

```bash
curl -X POST http://localhost:8000/api/student/service-requests \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "student_id": 1,
    "type_id": 1,
    "form_data": {
      "specialization": "Computer Science"
    }
  }'
```

**Response (422 Unprocessable Entity)**:
```json
{
  "message": "The form_data.level field is required. (and 5 more errors)",
  "errors": {
    "form_data.level": ["Academic level is required."],
    "form_data.college": ["College name is required."],
    "form_data.semester": ["Semester is required."],
    "form_data.academic_year": ["Academic year is required."],
    "form_data.absence_reason": ["Absence reason is required."],
    "form_data.courses": ["At least one course absence must be specified."]
  }
}
```

### Invalid Absence Date (Future Date)

```bash
curl -X POST http://localhost:8000/api/student/service-requests \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "student_id": 1,
    "type_id": 1,
    "form_data": {
      "specialization": "Computer Science",
      "level": 3,
      "college": "College of Engineering",
      "semester": "Fall",
      "academic_year": "2025/2026",
      "absence_reason": "Medical emergency",
      "courses": [
        {
          "course_name": "Software Engineering",
          "absence_date": "2027-02-01",
          "day": "Saturday"
        }
      ]
    }
  }'
```

**Response (422)**:
```json
{
  "errors": {
    "form_data.courses.0.absence_date": ["Absence date cannot be in the future."]
  }
}
```

---

## Postman Collection JSON

Save this as `service_requests.postman_collection.json`:

```json
{
  "info": {
    "name": "Service Requests API",
    "description": "API endpoints for dynamic service request system",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Student - Submit Absence Excuse",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"student_id\": 1,\n  \"type_id\": 1,\n  \"form_data\": {\n    \"specialization\": \"Computer Science\",\n    \"level\": 3,\n    \"college\": \"College of Engineering\",\n    \"semester\": \"Fall\",\n    \"academic_year\": \"2025/2026\",\n    \"absence_reason\": \"Medical emergency requiring hospitalization for surgery and recovery period\",\n    \"courses\": [\n      {\n        \"course_name\": \"Software Engineering\",\n        \"absence_date\": \"2026-02-01\",\n        \"day\": \"Saturday\"\n      },\n      {\n        \"course_name\": \"Database Systems\",\n        \"absence_date\": \"2026-02-03\",\n        \"day\": \"Monday\"\n      }\n    ]\n  }\n}"
        },
        "url": {
          "raw": "{{base_url}}/student/service-requests",
          "host": ["{{base_url}}"],
          "path": ["student", "service-requests"]
        }
      }
    },
    {
      "name": "Student - Get Request Details",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{base_url}}/student/service-requests/1",
          "host": ["{{base_url}}"],
          "path": ["student", "service-requests", "1"]
        }
      }
    },
    {
      "name": "Staff - Accept Request",
      "request": {
        "method": "PUT",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"status\": \"accepted\",\n  \"admin_notes\": \"Medical documentation verified and approved. Excuse granted for specified dates.\",\n  \"should_notify\": true\n}"
        },
        "url": {
          "raw": "{{base_url}}/staff/service-requests/1/status",
          "host": ["{{base_url}}"],
          "path": ["staff", "service-requests", "1", "status"]
        }
      }
    },
    {
      "name": "Staff - Reject Request",
      "request": {
        "method": "PUT",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"status\": \"rejected\",\n  \"admin_notes\": \"Insufficient medical documentation. Please provide official hospital records.\",\n  \"should_notify\": true\n}"
        },
        "url": {
          "raw": "{{base_url}}/staff/service-requests/2/status",
          "host": ["{{base_url}}"],
          "path": ["staff", "service-requests", "2", "status"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8000/api"
    }
  ]
}
```

---

## Testing Workflow

### 1. Setup (First Time)
```bash
# Run migrations
php artisan migrate

# Seed request types
php artisan db:seed --class=RequestTypeSeeder
```

### 2. Submit a Request
Use the "Student - Submit Absence Excuse" cURL command above.

### 3. Verify in Database
```bash
php artisan tinker
>>> App\Models\Request::latest()->first()->form_data
```

### 4. Update Status (Accept/Reject)
Use the "Staff - Accept Request" or "Staff - Reject Request" cURL commands.

### 5. Check Logs
View the Laravel log file to see status change logging:
```bash
# On Windows
type storage\logs\laravel.log | Select-String "Request status changed"

# On Linux/Mac
tail -f storage/logs/laravel.log | grep "Request status"
```

**Expected Log Entry**:
```
[2026-02-07 20:15:00] local.INFO: Request status changed to ACCEPTED {"request_id":1,"student_id":1,"request_type":"Absence Excuse","old_status":"pending","new_status":"accepted","admin_notes":"Medical documentation verified and approved.","processed_by":5,"timestamp":"2026-02-07 20:15:00"}
```

---

## Quick Test Scenarios

### ✅ Valid Request
- All required fields present
- Valid academic year format (2025/2026)
- Absence dates not in future
- At least one course

### ❌ Invalid Requests to Test

1. **Missing fields**: Remove required fields
2. **Short absence reason**: Less than 10 characters
3. **Future date**: Set absence_date to future
4. **Invalid level**: Set level to 10
5. **Wrong year format**: Use 2025-2026 instead of 2025/2026
6. **Empty courses**: Set courses to []
7. **Rejection without notes**: Omit admin_notes when rejecting

---

## Notes

- Replace `student_id` and `type_id` with actual IDs from your database
- For authenticated requests, add: `-H "Authorization: Bearer YOUR_TOKEN"`
- Check `laravel.log` for detailed logging of all operations
- Use Postman environment variables for `base_url` to switch between local/staging easily
