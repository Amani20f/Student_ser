<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('student_applications', function (Blueprint $table) {
            if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement('ALTER TABLE student_applications DROP CONSTRAINT IF EXISTS student_applications_application_status_check'); }
            if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE student_applications ADD CONSTRAINT student_applications_application_status_check CHECK (application_status::text = ANY (ARRAY['pending'::character varying, 'submitted'::character varying, 'completed'::character varying, 'rejected'::character varying]::text[]))"); }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('student_applications', function (Blueprint $table) {
            if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement('ALTER TABLE student_applications DROP CONSTRAINT IF EXISTS student_applications_application_status_check'); }
            if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE student_applications ADD CONSTRAINT student_applications_application_status_check CHECK (application_status::text = ANY (ARRAY['pending'::character varying, 'submitted'::character varying, 'completed'::character varying]::text[]))"); }
        });
    }
};
