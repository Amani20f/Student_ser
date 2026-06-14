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
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement('ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check'); }
        
        Schema::table('requests', function (Blueprint $table) {
            $table->string('status')->default('pending')->change();
        });

        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'ratified', 'approved', 'rejected'))"); }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement('ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check'); }
        
        Schema::table('requests', function (Blueprint $table) {
            $table->string('status')->default('pending')->change();
        });

        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))"); }
    }
};
