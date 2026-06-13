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
        Schema::create('student_applications', function (Blueprint $table) {
            $table->bigIncrements('id');
            
            // Application identifiers
            $table->string('application_number')->unique();
            $table->enum('application_status', ['pending', 'submitted', 'completed'])->default('pending');
            
            // PERSONAL INFORMATION
            $table->string('full_name');
            $table->string('national_id_number')->unique();
            $table->date('date_of_birth');
            $table->enum('gender', ['male', 'female']);
            $table->string('nationality');
            
            // CONTACT INFORMATION
            $table->string('phone_number');
            $table->string('email_address');
            $table->text('address')->nullable();
            
            // ACADEMIC INFORMATION
            $table->unsignedBigInteger('desired_program_id');
            $table->integer('desired_academic_level');
            
            // ATTACHMENTS
            $table->string('identity_document_path')->nullable();
            $table->string('qualification_document_path')->nullable();
            $table->string('personal_photo_path')->nullable();
            
            // ADDITIONAL FORM DATA
            $table->json('form_responses')->nullable();
            
            // SYSTEM FIELDS
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();
            
            // Foreign key constraints
            $table->foreign('desired_program_id')
                  ->references('id')
                  ->on('programs')
                  ->onDelete('cascade');
            
            // Indexes for query performance
            $table->index('application_status');
            $table->index('email_address');
            $table->index('national_id_number');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('student_applications');
    }
};
