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
        Schema::create('application_consents', function (Blueprint $table) {
            $table->bigIncrements('id');
            
            // Foreign keys
            $table->unsignedBigInteger('student_application_id');
            $table->unsignedBigInteger('consent_document_id');
            
            // Acceptance tracking
            $table->timestamp('accepted_at');
            $table->timestamp('created_at')->useCurrent();
            
            // Foreign key constraints
            $table->foreign('student_application_id')
                  ->references('id')
                  ->on('student_applications')
                  ->onDelete('cascade');
                  
            $table->foreign('consent_document_id')
                  ->references('id')
                  ->on('consent_documents')
                  ->onDelete('cascade');
            
            // Prevent duplicate consent records for same application-document pair
            $table->unique(['student_application_id', 'consent_document_id'], 'unique_application_consent');
            
            // Indexes for query performance
            $table->index('student_application_id');
            $table->index('consent_document_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('application_consents');
    }
};
