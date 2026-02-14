/**
 * Variation Image Debug Helper
 * 
 * Paste this into your browser console (F12) to debug variation image issues
 */

(function() {
    console.log('=== VARIATION IMAGE DEBUG HELPER ===\n');
    
    // Check if we're on the product edit page
    if (!$('#product-form').length) {
        console.error('Not on product edit page!');
        return;
    }
    
    // Check variation cards
    const $variations = $('.variation-card');
    console.log(`Found ${$variations.length} variation card(s)\n`);
    
    if ($variations.length === 0) {
        console.warn('No variations found!');
        return;
    }
    
    // Check each variation
    $variations.each(function(index) {
        const $card = $(this);
        const variationIndex = $card.data('variation-index');
        const variationId = $card.data('variation-id');
        
        console.log(`--- Variation ${index} ---`);
        console.log('  Card Index:', variationIndex);
        console.log('  Variation ID:', variationId);
        
        // Check image_id input
        const $imageIdInput = $card.find('.variation-image-id');
        if ($imageIdInput.length) {
            console.log('  ✓ Image ID input found');
            console.log('    Name:', $imageIdInput.attr('name'));
            console.log('    Value:', $imageIdInput.val() || '(empty)');
            console.log('    Class:', $imageIdInput.attr('class'));
        } else {
            console.error('  ✗ Image ID input NOT found!');
        }
        
        // Check file input
        const $fileInput = $card.find('.variation-image-input');
        if ($fileInput.length) {
            console.log('  ✓ File input found');
            console.log('    Has file:', $fileInput[0].files.length > 0);
        } else {
            console.error('  ✗ File input NOT found!');
        }
        
        // Check remove flag
        const $removeFlag = $card.find('.remove-image-flag');
        if ($removeFlag.length) {
            console.log('  ✓ Remove flag found');
            console.log('    Value:', $removeFlag.val());
        }
        
        // Check if image is displayed
        const $preview = $card.find('.variation-image-preview');
        if ($preview.length) {
            console.log('  ✓ Image preview displayed');
            console.log('    Source:', $preview.attr('src'));
        } else {
            console.log('  - No image preview');
        }
        
        console.log('');
    });
    
    // Check media library modal
    console.log('--- Media Library Modal ---');
    if ($('#mediaLibraryModal').length) {
        console.log('✓ Modal exists');
    } else {
        console.error('✗ Modal NOT found!');
    }
    
    // Check select buttons
    const $selectButtons = $('.select-variation-image-btn');
    console.log(`Found ${$selectButtons.length} "Select from Library" button(s)`);
    
    if ($selectButtons.length > 0) {
        $selectButtons.each(function(index) {
            const $btn = $(this);
            console.log(`  Button ${index}:`);
            console.log('    Target:', $btn.data('target'));
            console.log('    Variation Index:', $btn.data('variation-index'));
        });
    }
    
    console.log('\n=== END DEBUG ===');
    console.log('\nTo test image selection:');
    console.log('1. Click "Select from Library" on any variation');
    console.log('2. Select an image');
    console.log('3. Check console for new messages');
    console.log('4. Run this script again to see updated values');
    
})();
