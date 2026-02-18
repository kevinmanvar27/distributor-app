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
        // Modify the enum to include 'followup' status
        DB::statement("ALTER TABLE leads MODIFY COLUMN status ENUM('new', 'contacted', 'followup', 'qualified', 'converted', 'lost') DEFAULT 'new'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert back to original enum values
        DB::statement("ALTER TABLE leads MODIFY COLUMN status ENUM('new', 'contacted', 'qualified', 'converted', 'lost') DEFAULT 'new'");
    }
};
