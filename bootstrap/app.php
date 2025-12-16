<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use App\Http\Middleware\SetTheme;
use App\Http\Middleware\SiteManagement;
use App\Http\Middleware\CheckPermission;
use App\Http\Middleware\FrontendRedirectIfAuthenticated;
use App\Http\Middleware\Authenticate;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->web(append: [
            SetTheme::class,
            SiteManagement::class,
        ]);
        
        // Register middleware aliases
        $middleware->alias([
            'auth' => Authenticate::class,
            'permission' => CheckPermission::class,
            'frontend.guest' => FrontendRedirectIfAuthenticated::class,
            'frontend.access' => \App\Http\Middleware\CheckFrontendAccess::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();