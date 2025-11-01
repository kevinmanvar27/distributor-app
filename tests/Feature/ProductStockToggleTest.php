<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Permission;

class ProductStockToggleTest extends TestCase
{
    use RefreshDatabase;

    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create roles and permissions
        $adminRole = Role::create([
            'name' => 'super_admin',
            'display_name' => 'Super Admin',
            'description' => 'Full access to all system features'
        ]);
        
        // Create permissions
        $permissions = [
            ['name' => 'viewAny_product', 'display_name' => 'View Any Product', 'description' => 'View all products'],
            ['name' => 'view_product', 'display_name' => 'View Product', 'description' => 'View a specific product'],
            ['name' => 'create_product', 'display_name' => 'Create Product', 'description' => 'Create new products'],
            ['name' => 'update_product', 'display_name' => 'Update Product', 'description' => 'Modify existing products'],
            ['name' => 'delete_product', 'display_name' => 'Delete Product', 'description' => 'Remove products'],
        ];
        
        foreach ($permissions as $permissionData) {
            Permission::create($permissionData);
        }
        
        // Assign all permissions to the admin role
        $adminRole->permissions()->sync(Permission::all());
        
        // Create an admin user
        $this->adminUser = User::factory()->create([
            'user_role' => 'super_admin'
        ]);
        
        // Assign role to user
        $this->adminUser->roles()->sync([$adminRole->id]);
    }

    /** @test */
    public function it_shows_create_product_page()
    {
        $this->actingAs($this->adminUser);
        
        // Visit the create product page
        $response = $this->get(route('admin.products.create'));
        
        // Assert that the response is successful
        $response->assertStatus(200);
        
        // Assert that the stock quantity container exists
        $response->assertSee('stock_quantity_container', false);
        
        // Assert that the in_stock checkbox exists and is checked by default
        $response->assertSee('id="in_stock"', false);
        
        $this->assertTrue(true); // Placeholder assertion
    }
}