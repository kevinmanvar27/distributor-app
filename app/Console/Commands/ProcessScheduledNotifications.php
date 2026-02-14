<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\ScheduledNotification;
use App\Models\User;
use App\Models\UserGroup;
use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Support\Facades\Log;

class ProcessScheduledNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'notifications:process-scheduled';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Process and send scheduled push notifications';

    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        parent::__construct();
        $this->notificationService = $notificationService;
    }

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Processing scheduled notifications...');

        // Get all due notifications
        $notifications = ScheduledNotification::due()
            ->with(['user', 'userGroup'])
            ->get();

        if ($notifications->isEmpty()) {
            $this->info('No scheduled notifications to process.');
        } else {
            $this->info("Found {$notifications->count()} notification(s) to process.");

            foreach ($notifications as $notification) {
                $this->processNotification($notification);
            }

            $this->info('Scheduled notifications processing completed.');
        }

        // Cleanup old sent notifications (older than 48 hours)
        $this->cleanupOldNotifications();

        return 0;
    }

    /**
     * Remove sent/failed/cancelled notifications older than 48 hours
     */
    protected function cleanupOldNotifications()
    {
        $this->info('Cleaning up old notifications...');

        $cutoffTime = now()->subHours(48);

        $deleted = ScheduledNotification::whereIn('status', [
                ScheduledNotification::STATUS_SENT,
                ScheduledNotification::STATUS_FAILED,
                ScheduledNotification::STATUS_CANCELLED,
            ])
            ->where('sent_at', '<', $cutoffTime)
            ->delete();

        if ($deleted > 0) {
            $this->info("Deleted {$deleted} old notification(s) older than 48 hours.");
            Log::info('Old scheduled notifications cleaned up', ['deleted_count' => $deleted]);
        } else {
            $this->info('No old notifications to clean up.');
        }
    }

    /**
     * Process a single scheduled notification
     */
    protected function processNotification(ScheduledNotification $notification)
    {
        $this->info("Processing notification ID: {$notification->id} - Target: {$notification->target_type}");

        try {
            $payload = [
                'title' => $notification->title,
                'body' => $notification->body,
                'message' => $notification->body,
                'type' => 'scheduled_notification',
                'data' => array_merge(
                    $notification->data ?? [],
                    [
                        'type' => 'scheduled_notification',
                        'scheduled_notification_id' => (string) $notification->id,
                    ]
                )
            ];

            $successCount = 0;
            $failCount = 0;
            $errors = [];

            // Process based on target type
            switch ($notification->target_type) {
                case ScheduledNotification::TARGET_USER:
                    $this->processSingleUser($notification, $payload, $successCount, $failCount, $errors);
                    break;

                case ScheduledNotification::TARGET_GROUP:
                    $this->processUserGroup($notification, $payload, $successCount, $failCount, $errors);
                    break;

                case ScheduledNotification::TARGET_ALL_USERS:
                    $this->processAllUsers($notification, $payload, $successCount, $failCount, $errors);
                    break;

                default:
                    throw new \Exception("Unknown target type: {$notification->target_type}");
            }

            // Update notification status
            $status = $successCount > 0 ? ScheduledNotification::STATUS_SENT : ScheduledNotification::STATUS_FAILED;
            
            $notification->update([
                'status' => $status,
                'success_count' => $successCount,
                'fail_count' => $failCount,
                'error_message' => !empty($errors) ? implode('; ', array_slice($errors, 0, 5)) : null,
                'sent_at' => now(),
            ]);

            Log::info('Scheduled notification processed', [
                'notification_id' => $notification->id,
                'target_type' => $notification->target_type,
                'status' => $status,
                'success_count' => $successCount,
                'fail_count' => $failCount,
            ]);

            $this->info("Notification ID: {$notification->id} - Sent: {$successCount}, Failed: {$failCount}");

        } catch (\Exception $e) {
            Log::error('Failed to process scheduled notification', [
                'notification_id' => $notification->id,
                'error' => $e->getMessage(),
            ]);

            $notification->update([
                'status' => ScheduledNotification::STATUS_FAILED,
                'error_message' => $e->getMessage(),
                'sent_at' => now(),
            ]);

            $this->error("Failed to process notification ID: {$notification->id} - {$e->getMessage()}");
        }
    }

    /**
     * Process notification for a single user
     */
    protected function processSingleUser($notification, $payload, &$successCount, &$failCount, &$errors)
    {
        $user = User::find($notification->user_id);

        if (!$user) {
            $errors[] = "User not found: {$notification->user_id}";
            $failCount++;
            return;
        }

        // Save notification to database
        Notification::create([
            'user_id' => $user->id,
            'title' => $notification->title,
            'message' => $notification->body,
            'type' => 'scheduled',
            'data' => $notification->data ?? [],
            'read' => false,
        ]);

        // Send push notification if user has device token
        if (!empty($user->device_token)) {
            $result = $this->notificationService->sendPushNotification($user->device_token, $payload);
            
            if ($result['success']) {
                $successCount++;
            } else {
                $failCount++;
                $errors[] = "User {$user->id}: " . ($result['message'] ?? 'Unknown error');
            }
        } else {
            // Notification saved but no push sent
            $successCount++;
        }
    }

    /**
     * Process notification for a user group
     */
    protected function processUserGroup($notification, $payload, &$successCount, &$failCount, &$errors)
    {
        $userGroup = UserGroup::with('users')->find($notification->user_group_id);

        if (!$userGroup) {
            $errors[] = "User group not found: {$notification->user_group_id}";
            $failCount++;
            return;
        }

        foreach ($userGroup->users as $user) {
            // Save notification to database
            Notification::create([
                'user_id' => $user->id,
                'title' => $notification->title,
                'message' => $notification->body,
                'type' => 'scheduled',
                'data' => $notification->data ?? [],
                'read' => false,
            ]);

            // Send push notification if user has device token
            if (!empty($user->device_token)) {
                $result = $this->notificationService->sendPushNotification($user->device_token, $payload);
                
                if ($result['success']) {
                    $successCount++;
                } else {
                    $failCount++;
                    $errors[] = "User {$user->id}: " . ($result['message'] ?? 'Unknown error');
                }
            } else {
                // Notification saved but no push sent
                $successCount++;
            }
        }
    }

    /**
     * Process notification for all users
     */
    protected function processAllUsers($notification, $payload, &$successCount, &$failCount, &$errors)
    {
        // Get all users
        User::chunk(100, function($users) use ($notification, $payload, &$successCount, &$failCount, &$errors) {
            foreach ($users as $user) {
                // Save notification to database
                Notification::create([
                    'user_id' => $user->id,
                    'title' => $notification->title,
                    'message' => $notification->body,
                    'type' => 'scheduled',
                    'data' => $notification->data ?? [],
                    'read' => false,
                ]);

                // Send push notification if user has device token
                if (!empty($user->device_token)) {
                    $result = $this->notificationService->sendPushNotification($user->device_token, $payload);
                    
                    if ($result['success']) {
                        $successCount++;
                    } else {
                        $failCount++;
                        if (count($errors) < 10) { // Limit error collection
                            $errors[] = "User {$user->id}: " . ($result['message'] ?? 'Unknown error');
                        }
                    }
                } else {
                    // Notification saved but no push sent
                    $successCount++;
                }
            }
        });
    }
}
