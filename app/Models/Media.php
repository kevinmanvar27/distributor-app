<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class Media extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'file_name',
        'mime_type',
        'path',
        'size',
    ];

    /**
     * The accessors to append to the model's array form.
     *
     * @var array
     */
    protected $appends = ['url'];

    /**
     * Get the URL for the media file.
     */
    public function getUrlAttribute()
    {
        return Storage::disk('public')->url($this->path);
    }

    /**
     * Get the products that use this media as their main photo.
     */
    public function productsAsMainPhoto()
    {
        return $this->hasMany(Product::class, 'main_photo_id');
    }

    /**
     * Get the products that use this media in their gallery.
     */
    public function productsInGallery()
    {
        return $this->belongsToMany(Product::class, 'product_gallery');
    }

    /**
     * Get the categories that use this media.
     */
    public function categories()
    {
        return $this->hasMany(Category::class, 'image_id');
    }

    /**
     * Get the subcategories that use this media.
     */
    public function subCategories()
    {
        return $this->hasMany(SubCategory::class, 'image_id');
    }

    /**
     * Get the product variations that use this media.
     */
    public function productVariations()
    {
        return $this->hasMany(ProductVariation::class, 'image_id');
    }

    /**
     * Check if this media is being used by any entity.
     *
     * @return bool
     */
    public function isInUse()
    {
        // Check if used by products as main photo
        if ($this->productsAsMainPhoto()->exists()) {
            return true;
        }

        // Check if used in product galleries
        if (DB::table('products')->whereJsonContains('product_gallery', $this->id)->exists()) {
            return true;
        }

        // Check if used by categories
        if ($this->categories()->exists()) {
            return true;
        }

        // Check if used by subcategories
        if ($this->subCategories()->exists()) {
            return true;
        }

        // Check if used by product variations
        if ($this->productVariations()->exists()) {
            return true;
        }

        return false;
    }

    /**
     * Delete the media file and record if not in use.
     *
     * @param bool $force Force delete even if in use
     * @return bool
     */
    public function safeDelete($force = false)
    {
        if (!$force && $this->isInUse()) {
            return false;
        }

        // Delete the file from storage
        if (Storage::disk('public')->exists($this->path)) {
            Storage::disk('public')->delete($this->path);
        }

        // Delete the database record
        return $this->delete();
    }

    /**
     * Find and delete all orphaned media (not referenced by any entity).
     *
     * @return int Number of deleted media items
     */
    public static function deleteOrphaned()
    {
        $deletedCount = 0;
        $allMedia = self::all();

        foreach ($allMedia as $media) {
            if (!$media->isInUse()) {
                if ($media->safeDelete(true)) {
                    $deletedCount++;
                }
            }
        }

        return $deletedCount;
    }
}