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
        Schema::table('appeals', function (Blueprint $table) {
            $table->json('attachment')->nullable()->after('student_note');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('appeals', function (Blueprint $table) {
            $table->dropColumn('attachment');
        });
    }
};
