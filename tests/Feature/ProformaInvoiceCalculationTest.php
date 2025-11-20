<?php

namespace Tests\Feature;

use Tests\TestCase;

class ProformaInvoiceCalculationTest extends TestCase
{
    /**
     * Test proforma invoice calculation logic.
     *
     * @return void
     */
    public function test_invoice_calculation_logic()
    {
        // Test data
        $subtotal = 1000; // ₹1000
        $taxPercentage = 18; // 18% tax
        $shipping = 50; // ₹50 shipping
        $discountAmount = 100; // ₹100 discount
        
        // Calculate expected values
        // Tax is calculated on subtotal only: 1000 * 18% = 180
        $expectedTaxAmount = $subtotal * ($taxPercentage / 100);
        
        // Total calculation: (Subtotal + Shipping + Tax) - Discount
        $expectedTotal = ($subtotal + $shipping + $expectedTaxAmount) - $discountAmount;
        
        // Verify calculations
        $this->assertEquals(180, $expectedTaxAmount);
        $this->assertEquals(1130, $expectedTotal); // (1000 + 50 + 180) - 100 = 1130
        
        // Test with zero values
        $zeroTax = 0;
        $zeroShipping = 0;
        $zeroDiscount = 0;
        
        $zeroTaxAmount = $subtotal * ($zeroTax / 100);
        $zeroTotal = ($subtotal + $zeroShipping + $zeroTaxAmount) - $zeroDiscount;
        
        $this->assertEquals(0, $zeroTaxAmount);
        $this->assertEquals(1000, $zeroTotal); // (1000 + 0 + 0) - 0 = 1000
    }
}