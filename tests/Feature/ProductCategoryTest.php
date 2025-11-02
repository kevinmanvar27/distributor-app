<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\SubCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductCategoryTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_store_product_with_categories()
    {
        // Create a user with super admin role
        $user = User::factory()->create([
            'user_role' => 'super_admin'
        ]);

        // Create categories and subcategories
        $category1 = Category::factory()->create(['name' => 'Electronics']);
        $subcategory1 = SubCategory::factory()->create([
            'name' => 'Mobile Phones',
            'category_id' => $category1->id
        ]);
        
        $category2 = Category::factory()->create(['name' => 'Clothing']);
        $subcategory2 = SubCategory::factory()->create([
            'name' => 'T-Shirts',
            'category_id' => $category2->id
        ]);

        // Login as user
        $this->actingAs($user);

        // Submit product with categories
        $response = $this->post(route('admin.products.store'), [
            'name' => 'Test Product',
            'description' => 'Test product description',
            'mrp' => 100.00,
            'selling_price' => 90.00,
            'in_stock' => 1,
            'stock_quantity' => 10,
            'status' => 'published',
            'product_categories' => [
                [
                    'category_id' => $category1->id,
                    'subcategory_ids' => [$subcategory1->id]
                ],
                [
                    'category_id' => $category2->id,
                    'subcategory_ids' => [$subcategory2->id]
                ]
            ]
        ]);

        // Assert redirection to products index
        $response->assertRedirect(route('admin.products.index'));

        // Assert product was created with categories
        $this->assertDatabaseHas('products', [
            'name' => 'Test Product',
        ]);

        // Get the created product
        $product = \App\Models\Product::where('name', 'Test Product')->first();
        
        // Assert categories were stored correctly
        $this->assertIsArray($product->product_categories);
        $this->assertCount(2, $product->product_categories);
        
        // Check first category
        $this->assertEquals($category1->id, $product->product_categories[0]['category_id']);
        $this->assertContains($subcategory1->id, $product->product_categories[0]['subcategory_ids']);
        
        // Check second category
        $this->assertEquals($category2->id, $product->product_categories[1]['category_id']);
        $this->assertContains($subcategory2->id, $product->product_categories[1]['subcategory_ids']);
    }

    /** @test */
    public function it_can_update_product_with_categories()
    {
        // Create a user with super admin role
        $user = User::factory()->create([
            'user_role' => 'super_admin'
        ]);

        // Create categories and subcategories
        $category1 = Category::factory()->create(['name' => 'Electronics']);
        $subcategory1 = SubCategory::factory()->create([
            'name' => 'Mobile Phones',
            'category_id' => $category1->id
        ]);
        
        $category2 = Category::factory()->create(['name' => 'Clothing']);
        $subcategory2 = SubCategory::factory()->create([
            'name' => 'T-Shirts',
            'category_id' => $category2->id
        ]);

        // Create a product
        $product = \App\Models\Product::factory()->create();

        // Login as user
        $this->actingAs($user);

        // Update product with categories
        $response = $this->put(route('admin.products.update', $product), [
            'name' => 'Updated Product',
            'description' => 'Updated product description',
            'mrp' => 150.00,
            'selling_price' => 120.00,
            'in_stock' => 1,
            'stock_quantity' => 5,
            'status' => 'published',
            'product_categories' => [
                [
                    'category_id' => $category1->id,
                    'subcategory_ids' => [$subcategory1->id]
                ],
                [
                    'category_id' => $category2->id,
                    'subcategory_ids' => [$subcategory2->id]
                ]
            ]
        ]);

        // Assert redirection to products index
        $response->assertRedirect(route('admin.products.index'));

        // Assert product was updated with categories
        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'name' => 'Updated Product',
        ]);

        // Refresh the product
        $product->refresh();
        
        // Assert categories were stored correctly
        $this->assertIsArray($product->product_categories);
        $this->assertCount(2, $product->product_categories);
        
        // Check first category
        $this->assertEquals($category1->id, $product->product_categories[0]['category_id']);
        $this->assertContains($subcategory1->id, $product->product_categories[0]['subcategory_ids']);
        
        // Check second category
        $this->assertEquals($category2->id, $product->product_categories[1]['category_id']);
        $this->assertContains($subcategory2->id, $product->product_categories[1]['subcategory_ids']);
    }
}