<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

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
        'description',
        'mrp',
        'selling_price',
        'in_stock',
        'stock_quantity',
        'status',
        'main_photo_id',
        'product_gallery',
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
        'mrp' => 'decimal:2',
        'selling_price' => 'decimal:2',
    ];

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
        return $this->belongsToMany(Media::class, 'product_gallery');
    }
}