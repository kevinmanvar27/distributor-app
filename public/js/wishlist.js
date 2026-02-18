/**
 * Wishlist functionality for frontend
 * Handles adding/removing products from wishlist with AJAX
 */

// Toggle product in wishlist
function toggleWishlist(productId, button = null) {
    return fetch('/wishlist/toggle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content || ''
        },
        body: JSON.stringify({
            product_id: productId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Update button state if provided
            if (button) {
                updateWishlistButton(button, data.in_wishlist);
            }

            // Update all wishlist buttons for this product
            const allButtons = document.querySelectorAll(`[data-product-id="${productId}"]`);
            allButtons.forEach(btn => {
                updateWishlistButton(btn, data.in_wishlist);
            });

            // Update wishlist count in header
            updateWishlistCount(data.wishlist_count);

            // Show notification
            showNotification(data.message, 'success');
        } else {
            showNotification(data.message || 'Failed to update wishlist', 'error');
        }
        return data;
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('An error occurred. Please try again.', 'error');
        throw error;
    });
}

// Add product to wishlist
function addToWishlist(productId, button = null) {
    fetch('/wishlist/add', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content || ''
        },
        body: JSON.stringify({
            product_id: productId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Update button state if provided
            if (button) {
                updateWishlistButton(button, true);
            }

            // Update all wishlist buttons for this product
            const allButtons = document.querySelectorAll(`[data-product-id="${productId}"]`);
            allButtons.forEach(btn => {
                updateWishlistButton(btn, true);
            });

            // Update wishlist count in header
            updateWishlistCount(data.wishlist_count);

            // Show notification
            showNotification(data.message, 'success');
        } else {
            showNotification(data.message || 'Failed to add to wishlist', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

// Remove product from wishlist
function removeFromWishlist(productId, button = null) {
    fetch('/wishlist/remove', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content || ''
        },
        body: JSON.stringify({
            product_id: productId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Update button state if provided
            if (button) {
                updateWishlistButton(button, false);
            }

            // Update all wishlist buttons for this product
            const allButtons = document.querySelectorAll(`[data-product-id="${productId}"]`);
            allButtons.forEach(btn => {
                updateWishlistButton(btn, false);
            });

            // Update wishlist count in header
            updateWishlistCount(data.wishlist_count);

            // Show notification
            showNotification(data.message, 'success');
        } else {
            showNotification(data.message || 'Failed to remove from wishlist', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('An error occurred. Please try again.', 'error');
    });
}

// Update wishlist button appearance
function updateWishlistButton(button, inWishlist) {
    if (!button) return;

    const heartIcon = button.querySelector('i.fa-heart');
    
    if (inWishlist) {
        // Filled heart
        button.classList.add('in-wishlist');
        button.setAttribute('title', 'Remove from wishlist');
        if (heartIcon) {
            heartIcon.classList.add('text-danger');
        }
    } else {
        // Outline heart
        button.classList.remove('in-wishlist');
        button.setAttribute('title', 'Add to wishlist');
        if (heartIcon) {
            heartIcon.classList.remove('text-danger');
        }
    }
}

// Update wishlist count in header
function updateWishlistCount(count) {
    const wishlistCountElements = document.querySelectorAll('.wishlist-count');
    wishlistCountElements.forEach(element => {
        element.textContent = count;
        
        // Show/hide badge based on count
        if (count > 0) {
            element.classList.remove('d-none');
            element.style.display = '';
        } else {
            element.classList.add('d-none');
        }
    });
}

// Show notification message
function showNotification(message, type = 'success') {
    // Check if showToast function exists (from main site)
    if (typeof showToast === 'function') {
        showToast(message, type);
        return;
    }

    // Fallback notification
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.wishlist-notification');
    existingNotifications.forEach(notification => notification.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `wishlist-notification alert alert-${type === 'success' ? 'success' : 'danger'} position-fixed`;
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 250px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);';
    notification.textContent = message;

    // Add to page
    document.body.appendChild(notification);

    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transition = 'opacity 0.3s';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Initialize wishlist functionality on page load
document.addEventListener('DOMContentLoaded', function() {
    // Add click handlers to all wishlist buttons
    const wishlistButtons = document.querySelectorAll('.wishlist-btn');
    wishlistButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const productId = this.getAttribute('data-product-id');
            if (productId) {
                toggleWishlist(productId, this);
            }
        });
    });

    // Load initial wishlist count if user is logged in
    const wishlistCountElements = document.querySelectorAll('.wishlist-count');
    if (wishlistCountElements.length > 0) {
        fetch('/wishlist/count')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateWishlistCount(data.count);
                }
            })
            .catch(error => console.error('Error loading wishlist count:', error));
    }
});
