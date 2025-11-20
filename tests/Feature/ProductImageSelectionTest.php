<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Media;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class ProductImageSelectionTest extends TestCase
{
    use RefreshDatabase;

    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create an admin user
        $this->adminUser = User::factory()->create([
            'user_role' => 'admin',
        ]);
        
        // Assign the admin role to the user
        $adminRole = Role::where('name', 'admin')->first();
        if ($adminRole) {
            $this->adminUser->roles()->attach($adminRole->id);
        }
    }

    /** @test */
    public function admin_can_select_main_photo_for_product()
    {
        // Create a media item
        $media = Media::factory()->create([
            'name' => 'test-image.jpg',
            'file_name' => 'test-image.jpg',
            'mime_type' => 'image/jpeg',
            'path' => 'media/test-image.jpg',
        ]);

        // Login as admin
        $this->actingAs($this->adminUser);

        // Submit product creation form with main photo
        $response = $this->post(route('admin.products.store'), [
            'name' => 'Test Product',
            'description' => 'Test product description',
            'mrp' => 100.00,
            'selling_price' => 80.00,
            'in_stock' => 1,
            'stock_quantity' => 10,
            'status' => 'published',
            'main_photo_id' => $media->id,
            'product_gallery' => '[]',
        ]);

        // Assert that the product was created successfully
        $response->assertRedirect(route('admin.products.index'));
        $response->assertSessionHas('success');

        // Assert that the product has the correct main photo
        $product = Product::where('name', 'Test Product')->first();
        $this->assertNotNull($product);
        $this->assertEquals($media->id, $product->main_photo_id);
    }

    /** @test */
    public function admin_can_select_gallery_photos_for_product()
    {
        // Create media items
        $media1 = Media::factory()->create([
            'name' => 'gallery-image-1.jpg',
            'file_name' => 'gallery-image-1.jpg',
            'mime_type' => 'image/jpeg',
            'path' => 'media/gallery-image-1.jpg',
        ]);

        $media2 = Media::factory()->create([
            'name' => 'gallery-image-2.jpg',
            'file_name' => 'gallery-image-2.jpg',
            'mime_type' => 'image/jpeg',
            'path' => 'media/gallery-image-2.jpg',
        ]);

        // Login as admin
        $this->actingAs($this->adminUser);

        // Submit product creation form with gallery photos
        $response = $this->post(route('admin.products.store'), [
            'name' => 'Test Product with Gallery',
            'description' => 'Test product description',
            'mrp' => 100.00,
            'selling_price' => 80.00,
            'in_stock' => 1,
            'stock_quantity' => 10,
            'status' => 'published',
            'main_photo_id' => null,
            'product_gallery' => json_encode([$media1->id, $media2->id]),
        ]);

        // Assert that the product was created successfully
        $response->assertRedirect(route('admin.products.index'));
        $response->assertSessionHas('success');

        // Assert that the product has the correct gallery photos
        $product = Product::where('name', 'Test Product with Gallery')->first();
        $this->assertNotNull($product);
        $this->assertEquals([$media1->id, $media2->id], $product->product_gallery);
    }

    /** @test */
    public function admin_can_update_product_with_new_images()
    {
        // Create a product
        $product = Product::factory()->create();

        // Create media items
        $media1 = Media::factory()->create([
            'name' => 'main-image.jpg',
            'file_name' => 'main-image.jpg',
            'mime_type' => 'image/jpeg',
            'path' => 'media/main-image.jpg',
        ]);

        $media2 = Media::factory()->create([
            'name' => 'gallery-image.jpg',
            'file_name' => 'gallery-image.jpg',
            'mime_type' => 'image/jpeg',
            'path' => 'media/gallery-image.jpg',
        ]);

        // Login as admin
        $this->actingAs($this->adminUser);

        // Submit product update form with new images
        $response = $this->put(route('admin.products.update', $product), [
            'name' => $product->name,
            'description' => $product->description,
            'mrp' => $product->mrp,
            'selling_price' => $product->selling_price,
            'in_stock' => $product->in_stock,
            'stock_quantity' => $product->stock_quantity,
            'status' => $product->status,
            'main_photo_id' => $media1->id,
            'product_gallery' => json_encode([$media2->id]),
        ]);

        // Assert that the product was updated successfully
        $response->assertRedirect(route('admin.products.index'));
        $response->assertSessionHas('success');

        // Refresh the product from database
        $product->refresh();

        // Assert that the product has the correct images
        $this->assertEquals($media1->id, $product->main_photo_id);
        $this->assertEquals([$media2->id], $product->product_gallery);
    }
}