<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('programs', function (Blueprint $table) {
            $table->decimal('fees', 10, 2)->default(0)->after('degree_type');
            $table->softDeletes();
        });

        Schema::table('courses', function (Blueprint $table) {
            $table->integer('order_index')->default(0)->after('semester_level')->comment('Order within the semester');
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('programs', function (Blueprint $table) {
            $table->dropColumn('fees');
            $table->dropSoftDeletes();
        });

        Schema::table('courses', function (Blueprint $table) {
            $table->dropColumn('order_index');
            $table->dropSoftDeletes();
        });
    }
};
