<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Media;
use App\Models\Role;
use App\Models\Permission;

class ProductTest extends TestCase
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
    public function it_can_create_a_product()
    {
        $this->actingAs($this->adminUser);
        
        // Create a media item for testing
        $media = Media::factory()->create();
        
        $productData = [
            'name' => 'Test Product',
            'description' => 'This is a test product',
            'mrp' => 100.00,
            'selling_price' => 90.00,
            'in_stock' => true,
            'stock_quantity' => 10,
            'status' => 'published',
            'main_photo_id' => $media->id,
            'product_gallery' => json_encode([$media->id]),
            'meta_title' => 'Test Product Meta Title',
            'meta_description' => 'Test product meta description',
            'meta_keywords' => 'test,product,keywords',
        ];

        $response = $this->post(route('admin.products.store'), $productData);

        $response->assertRedirect(route('admin.products.index'));
        $this->assertDatabaseHas('products', [
            'name' => 'Test Product',
            'mrp' => 100.00,
            'status' => 'published',
        ]);
    }

    /** @test */
    public function it_can_view_products()
    {
        $this->actingAs($this->adminUser);
        
        Product::factory()->count(3)->create();

        $response = $this->get(route('admin.products.index'));

        $response->assertStatus(200);
        $response->assertViewHas('products');
    }

    /** @test */
    public function it_can_update_a_product()
    {
        $this->actingAs($this->adminUser);
        
        $product = Product::factory()->create([
            'name' => 'Original Product',
            'mrp' => 50.00,
            'status' => 'draft',
        ]);
        
        $media = Media::factory()->create();
        
        $updatedData = [
            'name' => 'Updated Product',
            'description' => 'This product has been updated',
            'mrp' => 75.00,
            'selling_price' => 65.00,
            'in_stock' => false,
            'status' => 'published',
            'main_photo_id' => $media->id,
            'product_gallery' => json_encode([$media->id]),
            'meta_title' => 'Updated Product Meta Title',
            '_method' => 'PUT',
        ];

        $response = $this->post(route('admin.products.update', $product), $updatedData);

        $response->assertRedirect(route('admin.products.index'));
        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'name' => 'Updated Product',
            'mrp' => 75.00,
            'status' => 'published',
        ]);
    }

    /** @test */
    public function it_can_delete_a_product()
    {
        $this->actingAs($this->adminUser);
        
        $product = Product::factory()->create();

        $response = $this->delete(route('admin.products.destroy', $product));

        $response->assertRedirect(route('admin.products.index'));
        $this->assertDatabaseMissing('products', [
            'id' => $product->id,
        ]);
    }
}