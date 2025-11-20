<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\NotificationService;
use Illuminate\Http\Request;

class FirebaseController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Test Firebase configuration
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function testConfiguration()
    {
        $result = $this->notificationService->testConfiguration();
        return response()->json($result);
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