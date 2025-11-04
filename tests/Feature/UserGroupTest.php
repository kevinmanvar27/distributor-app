<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\UserGroup;

class UserGroupTest extends TestCase
{
    use RefreshDatabase;

    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create an admin user for testing
        $this->adminUser = User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'user_role' => 'super_admin',
        ]);
    }

    /** @test */
    public function it_can_create_a_user_group()
    {
        $this->actingAs($this->adminUser);
        
        $response = $this->post(route('admin.user-groups.store'), [
            'name' => 'Test Group',
            'description' => 'A test user group',
            'discount_percentage' => 10.50,
        ]);
        
        $response->assertRedirect(route('admin.user-groups.index'));
        $this->assertDatabaseHas('user_groups', [
            'name' => 'Test Group',
            'description' => 'A test user group',
            'discount_percentage' => 10.50,
        ]);
    }

    /** @test */
    public function it_can_attach_users_to_a_group()
    {
        $this->actingAs($this->adminUser);
        
        // Create some test users
        $user1 = User::factory()->create(['user_role' => 'user']);
        $user2 = User::factory()->create(['user_role' => 'user']);
        
        $userGroup = UserGroup::create([
            'name' => 'Test Group',
            'description' => 'A test user group',
            'discount_percentage' => 10.50,
        ]);
        
        $response = $this->put(route('admin.user-groups.update', $userGroup), [
            'name' => 'Test Group',
            'description' => 'A test user group',
            'discount_percentage' => 10.50,
            'users' => [$user1->id, $user2->id],
        ]);
        
        $response->assertRedirect(route('admin.user-groups.index'));
        $this->assertDatabaseHas('user_group_members', [
            'user_group_id' => $userGroup->id,
            'user_id' => $user1->id,
        ]);
        $this->assertDatabaseHas('user_group_members', [
            'user_group_id' => $userGroup->id,
            'user_id' => $user2->id,
        ]);
    }

    /** @test */
    public function it_can_list_user_groups()
    {
        $this->actingAs($this->adminUser);
        
        // Create some test user groups
        UserGroup::factory()->count(3)->create();
        
        $response = $this->get(route('admin.user-groups.index'));
        
        $response->assertStatus(200);
        $response->assertViewHas('userGroups');
    }
}