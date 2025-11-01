<?php
require_once 'vendor/autoload.php';

use Illuminate\Container\Container;
use Illuminate\Events\Dispatcher;
use Illuminate\Http\Request;
use Illuminate\Routing\Router;
use Illuminate\Session\SessionManager;
use Illuminate\Filesystem\Filesystem;
use Illuminate\Config\Repository;

// Create a service container
$app = new Container();

// Bind the container instance
Container::setInstance($app);

// Create a request from server variables
$request = Request::capture();
$app->instance('request', $request);

// Set up the router
$events = new Dispatcher($app);
$router = new Router($events, $app);
$app->instance('router', $router);

// Initialize Laravel
$app->singleton('config', function () {
    return new Repository();
});

// Simulate authentication
// Assuming user ID 1 exists and has the editor role
$_SERVER['HTTP_HOST'] = 'localhost';
$_SERVER['REQUEST_URI'] = '/admin/dashboard';
session_start();

// Include Laravel's bootstrap
require_once 'bootstrap/app.php';

// Initialize the application
$app = require_once 'bootstrap/app.php';

// Make the app handle the request
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);

// Check if the user has the manage_roles permission
auth()->loginUsingId(1);
echo "User role: " . auth()->user()->user_role . "\n";
echo "Has manage_roles permission: " . (auth()->user()->hasPermission('manage_roles') ? 'Yes' : 'No') . "\n";

// Clean up
$kernel->terminate($request, $response);