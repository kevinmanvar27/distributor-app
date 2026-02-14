// Debug helper for variation image upload issue
// Paste this into browser console on the product edit page

console.log('=== VARIATION IMAGE DEBUG HELPER LOADED ===');

// Function to check all variation image_id inputs
window.debugVariationImages = function() {
    console.log('\n=== CHECKING ALL VARIATION IMAGE_ID INPUTS ===\n');
    
    // Method 1: Find by class
    const byClass = $('.variation-image-id');
    console.log(`Found ${byClass.length} inputs by class "variation-image-id"`);
    
    byClass.each(function(index) {
        const $input = $(this);
        console.log(`\nVariation ${index} (by class):`, {
            name: $input.attr('name'),
            jqueryVal: $input.val(),
            domValue: this.value,
            attrValue: $input.attr('value'),
            propValue: $input.prop('value'),
            isEmpty: !$input.val() || $input.val() === '' || $input.val() === 'null',
            isDisabled: $input.prop('disabled'),
            isVisible: $input.is(':visible'),
            hasParent: $input.parent().length > 0,
            element: this
        });
    });
    
    // Method 2: Find by name attribute
    console.log('\n--- Method 2: By name attribute ---\n');
    const byName = $('input[name^="variations["][name$="][image_id]"]');
    console.log(`Found ${byName.length} inputs by name pattern`);
    
    byName.each(function(index) {
        console.log(`\nVariation ${index} (by name):`, {
            name: $(this).attr('name'),
            jqueryVal: $(this).val(),
            domValue: this.value,
            attrValue: $(this).attr('value')
        });
    });
    
    // Method 3: Check variation cards
    console.log('\n--- Method 3: By variation cards ---\n');
    const cards = $('.variation-card');
    console.log(`Found ${cards.length} variation cards`);
    
    cards.each(function(index) {
        const $card = $(this);
        const varIndex = $card.data('variation-index');
        const $imageIdInput = $card.find('.variation-image-id');
        const $imageIdByName = $card.find('input[name*="[image_id]"]');
        
        console.log(`\nCard ${index} (variation-index: ${varIndex}):`, {
            hasImageIdByClass: $imageIdInput.length > 0,
            hasImageIdByName: $imageIdByName.length > 0,
            imageIdValue: $imageIdInput.length > 0 ? $imageIdInput.val() : 'NOT FOUND',
            imageIdByNameValue: $imageIdByName.length > 0 ? $imageIdByName.val() : 'NOT FOUND',
            cardElement: this
        });
    });
    
    console.log('\n=== END DEBUG CHECK ===\n');
};

// Function to manually set a variation image_id for testing
window.setVariationImageId = function(variationIndex, imageId) {
    console.log(`\nAttempting to set variation ${variationIndex} image_id to ${imageId}...`);
    
    const $card = $(`.variation-card[data-variation-index="${variationIndex}"]`);
    if ($card.length === 0) {
        console.error(`Could not find variation card with index ${variationIndex}`);
        return false;
    }
    
    const $imageIdInput = $card.find('.variation-image-id');
    if ($imageIdInput.length === 0) {
        console.error(`Could not find image_id input in variation ${variationIndex}`);
        return false;
    }
    
    // Set using multiple methods
    $imageIdInput.val(imageId);
    $imageIdInput.attr('value', imageId);
    $imageIdInput.prop('value', imageId);
    
    if ($imageIdInput[0]) {
        $imageIdInput[0].value = imageId;
        $imageIdInput[0].setAttribute('value', imageId);
    }
    
    console.log('Set complete. Verifying...');
    setTimeout(function() {
        console.log('Verification:', {
            jqueryVal: $imageIdInput.val(),
            domValue: $imageIdInput[0] ? $imageIdInput[0].value : 'N/A',
            attrValue: $imageIdInput.attr('value')
        });
    }, 100);
    
    return true;
};

// Function to check form data before submission
window.checkFormData = function() {
    console.log('\n=== FORM DATA CHECK ===\n');
    
    const form = document.getElementById('product-form');
    if (!form) {
        console.error('Form not found!');
        return;
    }
    
    const formData = new FormData(form);
    
    console.log('All form entries:');
    for (let [key, value] of formData.entries()) {
        if (key.includes('image_id')) {
            console.log(`${key}: ${value}`);
        }
    }
    
    console.log('\n=== END FORM DATA CHECK ===\n');
};

console.log('\nAvailable commands:');
console.log('  debugVariationImages() - Check all variation image_id inputs');
console.log('  setVariationImageId(index, imageId) - Manually set a variation image_id');
console.log('  checkFormData() - Check what will be submitted in the form');
console.log('\nExample: setVariationImageId(0, 123)');
