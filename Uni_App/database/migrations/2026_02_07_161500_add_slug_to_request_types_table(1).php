<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use App\Models\RequestType;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add slug column as nullable first
        Schema::table('request_types', function (Blueprint $table) {
            $table->string('slug')->nullable()->after('name');
        });

        // Populate slug for existing records
        $types = RequestType::all();
        foreach ($types as $type) {
            $slug = match($type->name) {
                'Excuses' => 'absence_excuse',
                'Grievances' => 'grievances',
                'Suspension of Enrollment' => 'suspension_of_enrollment',
                'Re-enrollment' => 're_enrollment',
                default => Str::slug($type->name)
            };
            $type->update(['slug' => $slug]);
        }

        // Now make it non-nullable and unique
        Schema::table('request_types', function (Blueprint $table) {
            $table->string('slug')->nullable(false)->unique()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('request_types', function (Blueprint $table) {
            $table->dropColumn('slug');
        });
    }
};
