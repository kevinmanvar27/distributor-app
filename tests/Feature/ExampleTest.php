<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Setting;

class ExampleTest extends TestCase
{
    use RefreshDatabase;
    /**
     * A basic test example.
     */
    public function test_the_application_redirects_to_login(): void
    {
        // Create a basic setting to ensure the app works
        Setting::create([
            'site_title' => 'Test Site',
        ]);
        
        $response = $this->get('/');

        $response->assertStatus(302); // Should redirect to login
    }
}
