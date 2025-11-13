<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class FontSizeSettingsTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_save_font_size_settings()
    {
        // Create an admin user
        $admin = User::factory()->create([
            'user_role' => 'admin',
        ]);
        
        $this->actingAs($admin);
        
        $response = $this->post(route('admin.settings.update'), [
            'active_tab' => 'appearance',
            'desktop_h1_size' => 40,
            'desktop_h2_size' => 36,
            'desktop_h3_size' => 32,
            'desktop_h4_size' => 28,
            'desktop_h5_size' => 24,
            'desktop_h6_size' => 20,
            'desktop_body_size' => 18,
            'tablet_h1_size' => 36,
            'tablet_h2_size' => 32,
            'tablet_h3_size' => 28,
            'tablet_h4_size' => 24,
            'tablet_h5_size' => 20,
            'tablet_h6_size' => 18,
            'tablet_body_size' => 16,
            'mobile_h1_size' => 32,
            'mobile_h2_size' => 28,
            'mobile_h3_size' => 24,
            'mobile_h4_size' => 20,
            'mobile_h5_size' => 18,
            'mobile_h6_size' => 16,
            'mobile_body_size' => 14,
        ]);

        $response->assertStatus(302);
        $response->assertSessionHas('success');

        $this->assertDatabaseHas('settings', [
            'desktop_h1_size' => 40,
            'desktop_h2_size' => 36,
            'desktop_h3_size' => 32,
            'desktop_h4_size' => 28,
            'desktop_h5_size' => 24,
            'desktop_h6_size' => 20,
            'desktop_body_size' => 18,
            'tablet_h1_size' => 36,
            'tablet_h2_size' => 32,
            'tablet_h3_size' => 28,
            'tablet_h4_size' => 24,
            'tablet_h5_size' => 20,
            'tablet_h6_size' => 18,
            'tablet_body_size' => 16,
            'mobile_h1_size' => 32,
            'mobile_h2_size' => 28,
            'mobile_h3_size' => 24,
            'mobile_h4_size' => 20,
            'mobile_h5_size' => 18,
            'mobile_h6_size' => 16,
            'mobile_body_size' => 14,
        ]);
    }

    /** @test */
    public function it_can_reset_font_size_settings_to_defaults()
    {
        // Create an admin user
        $admin = User::factory()->create([
            'user_role' => 'admin',
        ]);
        
        $this->actingAs($admin);
        
        // First save some custom values
        $this->post(route('admin.settings.update'), [
            'active_tab' => 'appearance',
            'desktop_h1_size' => 50,
        ]);

        // Then reset to defaults
        $response = $this->post(route('admin.settings.reset'));

        $response->assertStatus(302);
        $response->assertSessionHas('success');

        $setting = Setting::first();
        $this->assertEquals(36, $setting->desktop_h1_size);
    }

    /** @test */
    public function it_has_font_size_helper_functions()
    {
        // Test that helper functions exist and return default values
        $this->assertEquals(36, desktop_h1_size());
        $this->assertEquals(30, desktop_h2_size());
        $this->assertEquals(24, desktop_h3_size());
        $this->assertEquals(20, desktop_h4_size());
        $this->assertEquals(18, desktop_h5_size());
        $this->assertEquals(16, desktop_h6_size());
        $this->assertEquals(16, desktop_body_size());
    }
}