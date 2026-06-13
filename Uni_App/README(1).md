# University Service Ecosystem - API Backend

A production-grade Laravel 12 API for university management.

## 🚀 Environment Setup (Recommended: Laravel Sail)

To avoid OS-level DLL issues (mbstring, fileinfo, zip) and ensure environment parity, we recommend using Docker via Laravel Sail.

### Prerequisites
- Docker Desktop installed and running.
- PHP 8.2+ and Composer installed locally.

### Installation Steps
1. **Clone the repository** (if not already done).
2. **Install Composer dependencies**:
   ```bash
   composer install
   ```
3. **Setup Sail Environment**:
   ```bash
   php artisan sail:install --with=pgsql,redis,mailpit
   ```
4. **Start the environment**:
   ```bash
   ./vendor/bin/sail up -d
   ```
5. **Generate App Key and Migrate**:
   ```bash
   ./vendor/bin/sail artisan key:generate
   ./vendor/bin/sail artisan migrate --seed
   ```

---

### Manual Installation (Local Server/XAMPP)

If you prefer manual installation, ensure the following PHP extensions are enabled in your `php.ini`:

- **Required Extensions**:
  - `bcmath`
  - `ctype`
  - `fileinfo` (Critical for Excel/Images)
  - `gd`
  - `json`
  - `mbstring` (Critical for String handling)
  - `openssl`
  - `pdo_pgsql`
  - `tokenizer`
  - `xml`
  - `zip` (Critical for Excel Exports/Imports)

---

## 🔐 Authentication & RBAC

The system uses **Laravel Sanctum** for API tokens and **Spatie Laravel Permission** for RBAC.

### Registered Roles:
- `admin`: Full system access.
- `student_affairs`: Manage Service Requests.
- `accountant`: Financial / Payment verification.
- `grade_control`: Grade management and Excel imports.
- `student`: Standard student operations.

### API Middleware:
Registered aliases in `bootstrap/app.php`:
- `role`: `\Spatie\Permission\Middleware\RoleMiddleware`
- `permission`: `\Spatie\Permission\Middleware\PermissionMiddleware`

---

## 📊 Excel Grade Import (Smart Mapping)

The import flow involves two steps:
1. **Preview**: Upload file to `POST /api/staff/grades/import/preview` to receive headers.
2. **Store**: Send mapping JSON to `POST /api/staff/grades/import/store`.

**Example Mapping JSON**:
```json
{
  "temp_path": "temp/imports/xxx.xlsx",
  "mapping": {
    "student_number": 0,
    "course_code": 1,
    "semester_id": 2,
    "first": 3,
    "final": 6
  }
}
```
*Note: The mapping values (0, 1, 2...) correspond to the column index from the original spreadsheet.*
