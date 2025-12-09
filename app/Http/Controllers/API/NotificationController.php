<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\API\ApiController;
use App\Services\NotificationService;
use App\Models\User;
use App\Models\UserGroup;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Send notification to a single user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendToUser(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'data' => 'nullable|array'
        ]);

        $user = User::findOrFail($request->user_id);

        $payload = [
            'notification' => [
                'title' => $request->title,
                'body' => $request->body
            ],
            'data' => $request->data ?? []
        ];

        $result = $this->notificationService->sendToUser($user, $payload);

        return response()->json($result);
    }

    /**
     * Send notification to a user group
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendToUserGroup(Request $request)
    {
        $request->validate([
            'user_group_id' => 'required|exists:user_groups,id',
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'data' => 'nullable|array'
        ]);

        $userGroup = UserGroup::with('users')->findOrFail($request->user_group_id);

        $payload = [
            'notification' => [
                'title' => $request->title,
                'body' => $request->body
            ],
            'data' => $request->data ?? []
        ];

        $result = $this->notificationService->sendToUserGroup($userGroup, $payload);

        return response()->json($result);
    }

    /**
     * Register or update device token for a user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function registerDeviceToken(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'device_token' => 'required|string'
        ]);

        $user = User::findOrFail($request->user_id);
        $user->device_token = $request->device_token;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Device token registered successfully'
        ]);
    }

    /**
     * Get Firebase notification statistics
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getStatistics()
    {
        $stats = $this->notificationService->getStatistics();
        return response()->json($stats);
    }
}