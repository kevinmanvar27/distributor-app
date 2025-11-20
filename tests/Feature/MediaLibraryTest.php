<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Media;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Foundation\Testing\RefreshDatabase;

class MediaLibraryTest extends TestCase
{
    use RefreshDatabase;

    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create an admin user
        $this->adminUser = User::factory()->create([
            'user_role' => 'super_admin',
        ]);
    }

    /**
     * Test media upload with various file types
     */
    public function test_media_upload_various_file_types()
    {
        Storage::fake('public');
        
        $this->actingAs($this->adminUser);
        
        // Test image upload
        $image = UploadedFile::fake()->image('test.jpg');
        $response = $this->post('/admin/media', [
            'file' => $image,
            'name' => 'Test Image'
        ]);
        
        $response->assertStatus(200);
        $response->assertJson(['success' => true]);
        
        // Test PDF upload
        $pdf = UploadedFile::fake()->create('document.pdf', 1000, 'application/pdf');
        $response = $this->post('/admin/media', [
            'file' => $pdf,
            'name' => 'Test PDF'
        ]);
        
        $response->assertStatus(200);
        $response->assertJson(['success' => true]);
        
        // Test DOCX upload
        $docx = UploadedFile::fake()->create('document.docx', 1000, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        $response = $this->post('/admin/media', [
            'file' => $docx,
            'name' => 'Test DOCX'
        ]);
        
        $response->assertStatus(200);
        $response->assertJson(['success' => true]);
    }

    /**
     * Test media upload with file size limits
     */
    public function test_media_upload_file_size_limit()
    {
        Storage::fake('public');
        
        $this->actingAs($this->adminUser);
        
        // Test upload with file larger than 20MB (should fail)
        $largeFile = UploadedFile::fake()->create('large_file.jpg', 25000); // 25MB
        $response = $this->post('/admin/media', [
            'file' => $largeFile,
            'name' => 'Large File'
        ]);
        
        $response->assertStatus(422); // Validation error
    }

    /**
     * Test media upload in product context
     */
    public function test_product_media_upload()
    {
        Storage::fake('public');
        
        $this->actingAs($this->adminUser);
        
        // Test image upload through product controller
        $image = UploadedFile::fake()->image('product_image.jpg');
        $response = $this->post('/admin/products/media', [
            'file' => $image,
            'name' => 'Product Image'
        ]);
        
        $response->assertStatus(200);
        $response->assertJson(['success' => true]);
    }

    /**
     * Test media deletion
     */
    public function test_media_deletion()
    {
        Storage::fake('public');
        
        $this->actingAs($this->adminUser);
        
        // Create a media item
        $image = UploadedFile::fake()->image('test.jpg');
        $response = $this->post('/admin/media', [
            'file' => $image,
            'name' => 'Test Image'
        ]);
        
        $mediaId = $response->json('media.id');
        
        // Delete the media item
        $response = $this->delete("/admin/media/{$mediaId}");
        
        $response->assertStatus(200);
        $response->assertJson(['success' => true]);
        
        // Verify media record is deleted
        $this->assertDatabaseMissing('media', ['id' => $mediaId]);
    }
}