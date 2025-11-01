<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Setting;

class FirebaseSettingsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Clear any existing settings
        Setting::truncate();
    }

    /** @test */
    public function it_can_save_firebase_settings()
    {
        $setting = Setting::create([
            'firebase_project_id' => 'test-project-id',
            'firebase_client_email' => 'test@example.com',
            'firebase_private_key' => '-----BEGIN PRIVATE KEY-----\ntest-key\n-----END PRIVATE KEY-----',
        ]);

        $this->assertEquals('test-project-id', $setting->firebase_project_id);
        $this->assertEquals('test@example.com', $setting->firebase_client_email);
        $this->assertEquals('-----BEGIN PRIVATE KEY-----\ntest-key\n-----END PRIVATE KEY-----', $setting->firebase_private_key);
    }

    /** @test */
    public function it_can_check_if_firebase_is_configured()
    {
        // Test when not configured
        $this->assertFalse(is_firebase_configured());

        // Test when fully configured
        Setting::create([
            'firebase_project_id' => 'test-project-id',
            'firebase_client_email' => 'test@example.com',
            'firebase_private_key' => '-----BEGIN PRIVATE KEY-----\ntest-key\n-----END PRIVATE KEY-----',
        ]);

        $this->assertTrue(is_firebase_configured());
    }

    /** @test */
    public function it_can_retrieve_firebase_settings_via_helpers()
    {
        Setting::create([
            'firebase_project_id' => 'test-project-id',
            'firebase_client_email' => 'test@example.com',
            'firebase_private_key' => '-----BEGIN PRIVATE KEY-----\ntest-key\n-----END PRIVATE KEY-----',
        ]);

        $this->assertEquals('test-project-id', firebase_project_id());
        $this->assertEquals('test@example.com', firebase_client_email());
        $this->assertEquals('-----BEGIN PRIVATE KEY-----\ntest-key\n-----END PRIVATE KEY-----', firebase_private_key());
    }
}