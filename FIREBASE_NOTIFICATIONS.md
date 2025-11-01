# Firebase Cloud Messaging Integration

This application supports push notifications through Firebase Cloud Messaging (FCM). This document explains how to configure and use this feature.

## Configuration

1. Go to the Admin Panel → Settings → Notifications
2. Fill in the following Firebase credentials:
   - **Firebase Project ID**: Your project ID from the Firebase Console
   - **Firebase Client Email**: Service account email from Firebase
   - **Firebase Private Key**: Private key from Firebase service account JSON file

## Firebase Setup

To obtain these credentials:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project or create a new one
3. Navigate to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Download the JSON file
6. Extract the following values from the JSON:
   - `project_id` → Firebase Project ID
   - `client_email` → Firebase Client Email
   - `private_key` → Firebase Private Key

## Usage

Once configured, the application can send push notifications using the `NotificationService`:

```php
use App\Services\NotificationService;

$notificationService = new NotificationService();
$result = $notificationService->sendPushNotification($deviceToken, [
    'title' => 'Hello',
    'body' => 'World'
]);
```

## Testing

You can test your Firebase configuration by visiting `/admin/test-firebase` while logged in as an admin.