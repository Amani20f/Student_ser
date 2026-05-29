<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('request_types', function (Blueprint $table) {
            $table->enum('target_role', ['grade_control', 'accountant', 'student_affairs', 'admin'])
                  ->default('student_affairs')
                  ->after('slug');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('request_types', function (Blueprint $table) {
            $table->dropColumn('target_role');
        });
    }
};
