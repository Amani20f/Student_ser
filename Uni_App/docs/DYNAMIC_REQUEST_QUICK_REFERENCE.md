# Dynamic Request System - Quick Reference Guide

## 📋 JSON Structure for Absence Excuse

### Request Creation Payload
```json
{
  "student_id": 123,
  "type_id": 1,
  "form_data": {
    "specialization": "Computer Science",
    "level": 3,
    "college": "College of Engineering",
    "semester": "Fall",
    "academic_year": "2025/2026",
    "absence_reason": "Medical emergency requiring hospitalization",
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
}
```

### Validation Rules Summary

| Field | Type | Rules | Notes |
|-------|------|-------|-------|
| `specialization` | string | required, max:255 | Student's major |
| `level` | integer | required, 1-8 | Academic level/year |
| `college` | string | required, max:255 | College name |
| `semester` | string | required, in:Fall,Spring,Summer | Current semester |
| `academic_year` | string | required, YYYY/YYYY format | Must be sequential (e.g., 2025/2026) |
| `absence_reason` | string | required, min:10, max:1000 | Detailed explanation |
| `courses` | array | required, min:1 | At least one course |
| `courses.*.course_name` | string | required, max:255 | Course name |
| `courses.*.absence_date` | date | required, not future | Date of absence |
| `courses.*.day` | string | required, valid weekday | Day of the week |

---

## 🔄 Workflow Methods

### Accept a Request
```php
$request = Request::find($id);
$request->accept('Medical documentation verified and approved.');

// Or without notification
$request->accept('Approved', shouldNotify: false);
```

### Reject a Request
```php
$request = Request::find($id);
$request->reject('Insufficient medical documentation provided.');

// Or without notification
$request->reject('Rejected due to...', shouldNotify: false);
```

### Mark as Notified
```php
$request->markAsNotified();
```

---

## 🔍 Finding Request Types

```php
// By slug (recommended)
$absenceType = RequestType::findBySlug('absence_excuse');

// By ID
$type = RequestType::find(1);

// Get all active types
$activeTypes = RequestType::where('is_active', true)->get();
```

---

## 📝 Example Queries

### Get All Pending Absence Excuse Requests
```php
use App\Enums\RequestStatusEnum;

$pendingAbsences = Request::whereHas('requestType', function($q) {
    $q->where('slug', 'absence_excuse');
})->where('status', RequestStatusEnum::PENDING)->get();
```

### Get Student's Request History
```php
$studentRequests = Request::where('student_id', $studentId)
    ->with('requestType')
    ->latest()
    ->get();
```

### Get Accepted Requests for a Student
```php
$acceptedRequests = Request::where('student_id', $studentId)
    ->where('status', RequestStatusEnum::ACCEPTED)
    ->get();
```

---

## 🎯 Using Validation Classes

### In a Controller

```php
use App\Http\Requests\Request\StoreAbsenceExcuseRequest;
use App\Http\Requests\Request\UpdateRequestStatusRequest;

class RequestController extends Controller
{
    public function store(StoreAbsenceExcuseRequest $request)
    {
        // Data is already validated
        $validated = $request->validated();
        
        $serviceRequest = Request::create([
            'student_id' => $validated['student_id'],
            'request_type_id' => $validated['type_id'],
            'description' => 'Absence Excuse Request',
            'status' => RequestStatusEnum::PENDING,
            'form_data' => $validated['form_data'],
        ]);
        
        return response()->json($serviceRequest, 201);
    }
    
    public function updateStatus(UpdateRequestStatusRequest $request, $id)
    {
        $serviceRequest = Request::findOrFail($id);
        $validated = $request->validated();
        
        if ($validated['status'] === 'accepted') {
            $serviceRequest->accept(
                $validated['admin_notes'] ?? null,
                $validated['should_notify'] ?? true
            );
        } else {
            $serviceRequest->reject(
                $validated['admin_notes'],
                $validated['should_notify'] ?? true
            );
        }
        
        return response()->json($serviceRequest);
    }
}
```

---

## 🗄️ Database Schema Reference

### request_types Table
```
- id
- name
- slug (unique, indexed) ✨ NEW
- description
- is_active (boolean)
- created_at
- updated_at
```

### requests Table
```
- id
- student_id (FK)
- request_type_id (FK)
- description
- attachment
- status (enum: pending, accepted, rejected) ✨ UPDATED
- processed_by (FK to users)
- form_data (JSON) ✨ NEW
- admin_notes (TEXT) ✨ NEW
- is_notified (BOOLEAN) ✨ NEW
- created_at
- updated_at
```

---

## 🚀 Commands to Run

```powershell
# Run migrations
php artisan migrate

# Seed request types
php artisan db:seed --class=RequestTypeSeeder

# Launch Tinker for testing
php artisan tinker

# Rollback last migration batch (if needed)
php artisan migrate:rollback

# Fresh migration + seed (⚠️ deletes all data)
php artisan migrate:fresh --seed
```

---

## 📌 Key Files Reference

**Migrations:**
- `2026_02_07_161500_add_slug_to_request_types_table.php`
- `2026_02_07_161600_add_dynamic_fields_to_requests_table.php`
- `2026_02_07_161700_update_status_enum_in_requests_table.php`

**Models:**
- `app/Models/Request.php`
- `app/Models/RequestType.php`
- `app/Enums/RequestStatusEnum.php`

**Validation:**
- `app/Http/Requests/Request/BaseServiceRequestRequest.php`
- `app/Http/Requests/Request/StoreAbsenceExcuseRequest.php`
- `app/Http/Requests/Request/UpdateRequestStatusRequest.php`

**Seeders:**
- `database/seeders/RequestTypeSeeder.php`
