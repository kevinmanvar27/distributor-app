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
        // Skip if table already exists
        if (Schema::hasTable('scheduled_notifications')) {
            return;
        }
        
        Schema::create('scheduled_notifications', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('vendor_id')->nullable(); // Nullable for admin notifications
            $table->boolean('is_admin_notification')->default(false);
            $table->string('title');
            $table->text('body');
            $table->json('data')->nullable(); // Additional JSON data
            $table->string('target_type')->default('all'); // all, selected, user, group, all_users
            $table->json('customer_ids')->nullable(); // For selected customers (vendor)
            $table->unsignedBigInteger('user_id')->nullable(); // For single user (admin)
            $table->unsignedBigInteger('user_group_id')->nullable(); // For user group (admin)
            $table->dateTime('scheduled_at');
            $table->enum('status', ['pending', 'sent', 'failed', 'cancelled'])->default('pending');
            $table->text('error_message')->nullable();
            $table->integer('success_count')->default(0);
            $table->integer('fail_count')->default(0);
            $table->dateTime('sent_at')->nullable();
            $table->unsignedBigInteger('created_by')->nullable(); // User who created the notification
            $table->timestamps();
            
            // Indexes for efficient querying
            $table->index(['status', 'scheduled_at']);
            $table->index(['is_admin_notification', 'status']);
            
            // Foreign keys (nullable for admin notifications)
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('user_group_id')->references('id')->on('user_groups')->onDelete('cascade');
            $table->foreign('created_by')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('scheduled_notifications');
    }
};
