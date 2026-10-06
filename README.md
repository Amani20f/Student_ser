## 👩‍💻 My Role

I worked across the full stack of this project:
- **Backend:** built REST API endpoints with Laravel 12, including authentication (Sanctum) and role-based permissions
- **Frontend:** developed Flutter screens for the student portal and admin dashboard and connected them to the API
- **Database:** designed the PostgreSQL schema, migrations, and seeders (colleges, programs, courses, grades, requests, payments)

# 🎓 University Service Ecosystem

A full university services platform that lets students handle their academic and administrative needs from one app, and gives university staff a dashboard to manage them.

> Graduation project · team of 5 · Flutter + Laravel + PostgreSQL

---

## ✨ Features

**Student Portal (Flutter mobile app)**
- Secure login and student profile
- View grades (first, second, midterm, final, total, GPA)
- Study plan, semesters, and schedules
- Submit service requests with attachments (e.g. grade grievance, re-enrollment, stop enrollment)
- Upload payment receipts and track their status
- Announcements, notifications, and surveys

**Admin Dashboard (Flutter Web)**
- Manage admissions, students, and service requests
- Approve / reject requests and verify payments
- Send notifications to all students, a group, or an individual
- Arabic & English support (localization)

**REST API (Laravel 12)**
- Token authentication with **Laravel Sanctum**
- Role-based access control with **Spatie Permission**: `admin`, `student_affairs`, `accountant`, `grade_control`, `student`
- Smart **Excel grade import** with column mapping (preview → store)
- Activity logs stored as PostgreSQL `JSONB`
- Docker setup with **Laravel Sail**

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter, Dart |
| Admin dashboard | Flutter Web |
| Backend API | Laravel 12, PHP 8.2 |
| Database | PostgreSQL |
| Auth | Laravel Sanctum, Spatie Permission |
| DevOps | Docker (Laravel Sail), Redis |
| Testing | PHPUnit, Postman collection |

---

## 📁 Project Structure

```
Uni_App/
├── app/, routes/, database/   # Laravel API
├── student_portal/            # Flutter student app
├── admin_dashboard/           # Flutter Web admin dashboard
└── docs: api_documentation.md, schema_documentation.md, API_TESTING_GUIDE.md
```

---

## 🚀 Getting Started

### Backend (Laravel API)
```bash
cd Uni_App
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```
Or with Docker: `./vendor/bin/sail up -d`

### Student Portal / Admin Dashboard (Flutter)
```bash
cd Uni_App/student_portal     # or admin_dashboard
flutter pub get
flutter run
```

Full API docs: [`api_documentation.md`](Uni_App/api_documentation.md)

---

## 👩‍💻 My Role

I worked across the full stack of this project:
- **Backend:** built REST API endpoints with Laravel 12, including authentication (Sanctum) and role-based permissions
- **Frontend:** developed Flutter screens for the student portal and admin dashboard and connected them to the API
- **Database:** designed the PostgreSQL schema, migrations, and seeders (colleges, programs, courses, grades, requests, payments)

## 👥 Team
- Amani Rabeea — [@Amani20f](https://github.com/Amani20f)
- Noor Abdullah — [@noorbam](https://github.com/noorbam)
- Nora Omar
- Hanan Omar
- Raghad Akram
