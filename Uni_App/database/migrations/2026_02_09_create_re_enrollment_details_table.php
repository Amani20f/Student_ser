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
        Schema::create('re_enrollment_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('request_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            
            // Student uploaded file path
            $table->string('university_id_path');
            
            // Academic Fields (filled by Student Affairs)
            $table->string('major')->nullable();
            $table->integer('academic_level')->nullable();
            $table->string('batch')->nullable();
            $table->string('academic_year')->nullable();
            
            // Financial Fields (filled by Accountant)
            $table->decimal('university_fees', 12, 2)->nullable();
            $table->decimal('other_fees', 12, 2)->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('re_enrollment_details');
    }
};
