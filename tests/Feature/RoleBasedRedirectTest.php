<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;

class RoleBasedRedirectTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function user_with_user_role_is_redirected_to_frontend_home_after_login()
    {
        $user = User::factory()->create([
            'email' => 'user@example.com',
            'password' => bcrypt('password123'),
            'user_role' => 'user',
        ]);

        $response = $this->post('/login', [
            'email' => 'user@example.com',
            'password' => 'password123',
        ]);

        $this->assertAuthenticatedAs($user);
        $response->assertRedirect(route('frontend.home'));
    }

    /** @test */
    public function user_with_admin_role_is_redirected_to_admin_dashboard_after_login()
    {
        $user = User::factory()->create([
            'email' => 'admin@example.com',
            'password' => bcrypt('password123'),
            'user_role' => 'admin',
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'admin@example.com',
            'password' => 'password123',
        ]);

        $this->assertAuthenticatedAs($user);
        $response->assertRedirect(route('dashboard'));
    }

    /** @test */
    public function user_with_super_admin_role_is_redirected_to_admin_dashboard_after_login()
    {
        $user = User::factory()->create([
            'email' => 'superadmin@example.com',
            'password' => bcrypt('password123'),
            'user_role' => 'super_admin',
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'superadmin@example.com',
            'password' => 'password123',
        ]);

        $this->assertAuthenticatedAs($user);
        $response->assertRedirect(route('dashboard'));
    }

    /** @test */
    public function user_with_user_role_cannot_access_admin_login()
    {
        $user = User::factory()->create([
            'email' => 'frontenduser@example.com',
            'password' => bcrypt('password123'),
            'user_role' => 'user',
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'frontenduser@example.com',
            'password' => 'password123',
        ]);

        // User should be logged out and redirected back with error
        $this->assertGuest();
        $response->assertSessionHasErrors('email');
        $response->assertSessionHas('errors');
    }
}