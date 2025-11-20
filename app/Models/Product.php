<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use Illuminate\Support\Collection;

class Product extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'slug',
        'description',
        'mrp',
        'selling_price',
        'in_stock',
        'stock_quantity',
        'status',
        'main_photo_id',
        'product_gallery',
        'product_categories', // Added for category/subcategory storage
        'meta_title',
        'meta_description',
        'meta_keywords',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'in_stock' => 'boolean',
        'product_gallery' => 'array',
        'product_categories' => 'array', // Added for category/subcategory storage
        'mrp' => 'decimal:2',
        'selling_price' => 'decimal:2',
    ];

    /**
     * Boot the model.
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($product) {
            if (empty($product->slug)) {
                $product->slug = Str::slug($product->name);
            }
        });

        static::updating(function ($product) {
            if (empty($product->slug)) {
                $product->slug = Str::slug($product->name);
            }
        });
    }

    /**
     * Get the main photo for the product.
     */
    public function mainPhoto()
    {
        return $this->belongsTo(Media::class, 'main_photo_id');
    }

    /**
     * Get the gallery media for the product.
     */
    public function galleryMedia()
    {
        // Gallery is stored as JSON array of media IDs
        if (empty($this->product_gallery)) {
            return $this->hasMany(Media::class, 'id', 'id'); // Return empty relationship
        }
        
        return Media::whereIn('id', $this->product_gallery);
    }

    /**
     * Get the gallery photos for the product.
     */
    public function getGalleryPhotosAttribute()
    {
        if (empty($this->product_gallery)) {
            return new Collection();
        }

        return Media::whereIn('id', $this->product_gallery)->get();
    }

    /**
     * Get the categories for the product.
     */
    public function getCategoriesAttribute()
    {
        if (empty($this->product_categories)) {
            return new Collection();
        }

        $categoryIds = collect($this->product_categories)->pluck('category_id')->toArray();
        return Category::whereIn('id', $categoryIds)->get();
    }

    /**
     * Get the subcategories for the product.
     */
    public function getSubCategoriesAttribute()
    {
        if (empty($this->product_categories)) {
            return new Collection();
        }

        $subcategoryIds = collect($this->product_categories)
            ->pluck('subcategory_ids')
            ->flatten()
            ->toArray();

        return SubCategory::whereIn('id', $subcategoryIds)->get();
    }
}