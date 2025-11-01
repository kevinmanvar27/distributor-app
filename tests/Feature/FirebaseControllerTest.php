<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Setting;
use App\Models\User;

class FirebaseControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create an admin user
        $this->adminUser = User::factory()->create([
            'user_role' => 'super_admin'
        ]);
    }

    /** @test */
    public function it_can_test_firebase_configuration_when_not_configured()
    {
        $response = $this->actingAs($this->adminUser)->getJson(route('admin.firebase.test'));

        $response->assertStatus(200)
            ->assertJson([
                'success' => false,
                'message' => 'Firebase is not properly configured. Please check your settings.'
            ]);
    }

    /** @test */
    public function it_can_test_firebase_configuration_when_configured()
    {
        Setting::create([
            'firebase_project_id' => 'test-project-id',
            'firebase_client_email' => 'test@example.com',
            'firebase_private_key' => '-----BEGIN PRIVATE KEY-----\ntest-key\n-----END PRIVATE KEY-----',
        ]);

        $response = $this->actingAs($this->adminUser)->getJson(route('admin.firebase.test'));

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Firebase is properly configured and ready to send notifications.'
            ]);
    }
}