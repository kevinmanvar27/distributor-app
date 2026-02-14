<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Process scheduled push notifications every minute
Schedule::command('notifications:process-scheduled')
    ->everyMinute()
    ->withoutOverlapping()
    ->runInBackground()
    ->description('Process and send scheduled push notifications');
