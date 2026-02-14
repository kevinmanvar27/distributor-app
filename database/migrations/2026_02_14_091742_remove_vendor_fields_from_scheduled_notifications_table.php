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
        Schema::table('scheduled_notifications', function (Blueprint $table) {
            // Remove vendor-related columns
            if (Schema::hasColumn('scheduled_notifications', 'vendor_id')) {
                $table->dropColumn('vendor_id');
            }
            if (Schema::hasColumn('scheduled_notifications', 'is_admin_notification')) {
                $table->dropColumn('is_admin_notification');
            }
            if (Schema::hasColumn('scheduled_notifications', 'customer_ids')) {
                $table->dropColumn('customer_ids');
            }
        });
        
        // Drop the old index separately if it exists
        try {
            Schema::table('scheduled_notifications', function (Blueprint $table) {
                $table->dropIndex('scheduled_notifications_is_admin_notification_status_index');
            });
        } catch (\Exception $e) {
            // Index might not exist, ignore
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('scheduled_notifications', function (Blueprint $table) {
            // Add back the columns if needed for rollback
            $table->unsignedBigInteger('vendor_id')->nullable();
            $table->boolean('is_admin_notification')->default(false);
            $table->json('customer_ids')->nullable();
            
            // Re-create the index
            $table->index(['is_admin_notification', 'status']);
        });
    }
};
