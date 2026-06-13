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
        Schema::table('students', function (Blueprint $table) {
            $table->string('national_id')->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->string('nationality')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->string('profile_photo_path')->nullable();
            $table->decimal('cumulative_gpa', 3, 2)->default(0.00);
            $table->integer('completed_credit_hours')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $table->dropColumn([
                'national_id',
                'gender',
                'nationality',
                'date_of_birth',
                'profile_photo_path',
                'cumulative_gpa',
                'completed_credit_hours'
            ]);
        });
    }
};
