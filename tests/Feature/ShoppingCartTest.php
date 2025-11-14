<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\ShoppingCartItem;

class ShoppingCartTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $product;

    protected function setUp(): void
    {
        parent::setUp();

        // Create a user
        $this->user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        // Create a product
        $this->product = Product::factory()->create([
            'name' => 'Test Product',
            'description' => 'This is a test product',
            'mrp' => 100.00,
            'selling_price' => 90.00,
            'in_stock' => true,
            'stock_quantity' => 10,
            'status' => 'published',
        ]);
    }

    /** @test */
    public function user_can_add_product_to_cart()
    {
        $this->actingAs($this->user);

        $response = $this->postJson(route('frontend.cart.add'), [
            'product_id' => $this->product->id,
            'quantity' => 2,
        ]);

        $response->assertJson([
            'success' => true,
            'message' => 'Product added to cart successfully!',
        ]);

        $this->assertDatabaseHas('shopping_cart_items', [
            'user_id' => $this->user->id,
            'product_id' => $this->product->id,
            'quantity' => 2,
            'price' => 90.00,
        ]);
    }

    /** @test */
    public function user_can_view_their_cart()
    {
        // Add item to cart
        ShoppingCartItem::create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id,
            'quantity' => 1,
            'price' => 90.00,
        ]);

        $this->actingAs($this->user);

        $response = $this->get(route('frontend.cart.index'));

        $response->assertStatus(200);
        $response->assertSee('Test Product');
        $response->assertSee('₹90.00');
    }

    /** @test */
    public function user_can_update_cart_item_quantity()
    {
        // Add item to cart
        $cartItem = ShoppingCartItem::create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id,
            'quantity' => 1,
            'price' => 90.00,
        ]);

        $this->actingAs($this->user);

        $response = $this->putJson(route('frontend.cart.update', $cartItem->id), [
            'quantity' => 3,
        ]);

        $response->assertJson([
            'success' => true,
            'message' => 'Cart updated successfully!',
        ]);

        $this->assertDatabaseHas('shopping_cart_items', [
            'id' => $cartItem->id,
            'quantity' => 3,
        ]);
    }

    /** @test */
    public function user_can_remove_item_from_cart()
    {
        // Add item to cart
        $cartItem = ShoppingCartItem::create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id,
            'quantity' => 1,
            'price' => 90.00,
        ]);

        $this->actingAs($this->user);

        $response = $this->deleteJson(route('frontend.cart.remove', $cartItem->id));

        $response->assertJson([
            'success' => true,
            'message' => 'Item removed from cart!',
        ]);

        $this->assertDatabaseMissing('shopping_cart_items', [
            'id' => $cartItem->id,
        ]);
    }

    /** @test */
    public function user_cannot_add_out_of_stock_product_to_cart()
    {
        // Update product to be out of stock
        $this->product->update([
            'in_stock' => false,
            'stock_quantity' => 0,
        ]);

        $this->actingAs($this->user);

        $response = $this->postJson(route('frontend.cart.add'), [
            'product_id' => $this->product->id,
            'quantity' => 1,
        ]);

        $response->assertJson([
            'success' => false,
            'message' => 'Product is out of stock or insufficient quantity available.',
        ]);
    }
}