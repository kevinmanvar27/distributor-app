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
        Schema::table('settings', function (Blueprint $table) {
            // Add banner image field
            if (!Schema::hasColumn('settings', 'banner_image')) {
                $table->string('banner_image')->nullable()->after('favicon');
            }
            
            // Add GST text field
            if (!Schema::hasColumn('settings', 'gst_text')) {
                $table->string('gst_text')->nullable()->after('gst_number');
            }
            
            // Add delivery charge field
            if (!Schema::hasColumn('settings', 'delivery_charge')) {
                $table->decimal('delivery_charge', 10, 2)->default(0)->after('gst_text');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            if (Schema::hasColumn('settings', 'banner_image')) {
                $table->dropColumn('banner_image');
            }
            
            if (Schema::hasColumn('settings', 'gst_text')) {
                $table->dropColumn('gst_text');
            }
            
            if (Schema::hasColumn('settings', 'delivery_charge')) {
                $table->dropColumn('delivery_charge');
            }
        });
    }
};
