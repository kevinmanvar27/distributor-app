<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Media;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;

class SimpleProductTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function test_product_model_gallery_photos_accessor()
    {
        // Create a product
        $product = Product::factory()->create();
        
        // Create some media items
        $media1 = Media::factory()->create();
        $media2 = Media::factory()->create();
        
        // Set the product gallery
        $product->product_gallery = [$media1->id, $media2->id];
        $product->save();
        
        // Access the gallery photos through the accessor
        $galleryPhotos = $product->galleryPhotos;
        
        // Check that the gallery photos are loaded correctly
        $this->assertEquals(2, $galleryPhotos->count());
        $this->assertTrue($galleryPhotos->contains($media1));
        $this->assertTrue($galleryPhotos->contains($media2));
    }
}