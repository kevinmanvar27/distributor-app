<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use App\Models\User;

abstract class TestCase extends BaseTestCase
{
    protected function actingAsAdmin()
    {
        // Create an admin user for testing
        $admin = User::factory()->create([
            'is_admin' => true,
        ]);
        
        return $this->actingAs($admin);
    }
    
    protected function actingAsUser()
    {
        // Create a regular user for testing
        $user = User::factory()->create([
            'is_admin' => false,
        ]);
        
        return $this->actingAs($user);
    }
}