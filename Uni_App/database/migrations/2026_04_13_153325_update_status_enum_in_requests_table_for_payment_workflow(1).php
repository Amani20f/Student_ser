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
        DB::statement('ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check');
        
        Schema::table('requests', function (Blueprint $table) {
            $table->string('status')->default('pending')->change();
        });

        DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check');
        
        Schema::table('requests', function (Blueprint $table) {
            $table->string('status')->default('pending')->change();
        });

        DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))");
    }
};
