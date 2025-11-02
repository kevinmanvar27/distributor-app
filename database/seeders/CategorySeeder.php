<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\SubCategory;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create sample categories
        $categories = [
            [
                'name' => 'Electronics',
                'description' => 'Electronic devices and gadgets',
                'is_active' => true,
            ],
            [
                'name' => 'Clothing',
                'description' => 'Apparel and fashion items',
                'is_active' => true,
            ],
            [
                'name' => 'Home & Kitchen',
                'description' => 'Household and kitchen items',
                'is_active' => true,
            ],
            [
                'name' => 'Books',
                'description' => 'Books and educational materials',
                'is_active' => true,
            ],
        ];

        foreach ($categories as $categoryData) {
            $category = Category::create($categoryData);

            // Create sample subcategories for each category
            $subcategories = [
                [
                    'name' => $category->name . ' - General',
                    'description' => 'General items in ' . $category->name,
                    'category_id' => $category->id,
                    'is_active' => true,
                ],
                [
                    'name' => $category->name . ' - Premium',
                    'description' => 'Premium items in ' . $category->name,
                    'category_id' => $category->id,
                    'is_active' => true,
                ],
            ];

            foreach ($subcategories as $subcategoryData) {
                SubCategory::create($subcategoryData);
            }
        }
    }
}