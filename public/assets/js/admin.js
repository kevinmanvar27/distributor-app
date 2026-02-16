// Common JavaScript functions for the admin panel
// Wrap the entire code in a function that checks for jQuery
(function() {
    // Wait for jQuery to be available
    function waitForjQuery(callback) {
        if (typeof window.jQuery !== 'undefined') {
            callback();
        } else {
            setTimeout(function() {
                waitForjQuery(callback);
            }, 50);
        }
    }
    
    // Initialize when jQuery is ready
    waitForjQuery(function() {
        $(document).ready(function() {
            
            // ========================================
            // MOBILE SIDEBAR TOGGLE FUNCTIONALITY
            // ========================================
            
            const $sidebar = $('#sidebar');
            const $sidebarOverlay = $('#sidebar-overlay');
            const $sidebarToggle = $('#sidebar-toggle');
            const $sidebarClose = $('#sidebar-close');
            
            // Function to open sidebar
            function openSidebar() {
                $sidebar.addClass('show');
                $sidebarOverlay.addClass('show');
                $('body').css('overflow', 'hidden'); // Prevent body scroll when sidebar is open
            }
            
            // Function to close sidebar
            function closeSidebar() {
                $sidebar.removeClass('show');
                $sidebarOverlay.removeClass('show');
                $('body').css('overflow', ''); // Restore body scroll
            }
            
            // Toggle sidebar on hamburger button click
            $sidebarToggle.on('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                if ($sidebar.hasClass('show')) {
                    closeSidebar();
                } else {
                    openSidebar();
                }
            });
            
            // Close sidebar on close button click
            $sidebarClose.on('click', function(e) {
                e.preventDefault();
                closeSidebar();
            });
            
            // Close sidebar on overlay click
            $sidebarOverlay.on('click', function() {
                closeSidebar();
            });
            
            // Close sidebar on nav link click (mobile only)
            $sidebar.find('.nav-link').on('click', function() {
                if ($(window).width() < 768) {
                    closeSidebar();
                }
            });
            
            // Close sidebar on escape key
            $(document).on('keydown', function(e) {
                if (e.key === 'Escape' && $sidebar.hasClass('show')) {
                    closeSidebar();
                }
            });
            
            // Handle window resize - close sidebar if resizing to desktop
            $(window).on('resize', function() {
                if ($(window).width() >= 768) {
                    closeSidebar();
                }
            });
            
            // Handle swipe gestures for mobile
            let touchStartX = 0;
            let touchEndX = 0;
            
            document.addEventListener('touchstart', function(e) {
                touchStartX = e.changedTouches[0].screenX;
            }, { passive: true });
            
            document.addEventListener('touchend', function(e) {
                touchEndX = e.changedTouches[0].screenX;
                handleSwipe();
            }, { passive: true });
            
            function handleSwipe() {
                const swipeThreshold = 50;
                const swipeDistance = touchEndX - touchStartX;
                
                // Swipe right from left edge to open sidebar
                if (touchStartX < 30 && swipeDistance > swipeThreshold && !$sidebar.hasClass('show')) {
                    openSidebar();
                }
                
                // Swipe left to close sidebar
                if (swipeDistance < -swipeThreshold && $sidebar.hasClass('show')) {
                    closeSidebar();
                }
            }
            
            // ========================================
            // END MOBILE SIDEBAR TOGGLE FUNCTIONALITY
            // ========================================
            
            // ========================================
            // DESKTOP SIDEBAR TOGGLE FUNCTIONALITY
            // ========================================
            
            const $desktopSidebarToggle = $('#desktop-sidebar-toggle');
            const $mainContent = $('main.main-content');
            
            // Check localStorage for saved sidebar state
            const savedSidebarState = localStorage.getItem('sidebarCollapsed');
            
            if (savedSidebarState === 'true' && $(window).width() >= 768) {
                $sidebar.addClass('collapsed');
                $mainContent.addClass('sidebar-collapsed');
                $desktopSidebarToggle.find('i').removeClass('fa-bars').addClass('fa-angles-right');
            }
            
            // Desktop sidebar toggle click handler
            $desktopSidebarToggle.on('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                const isCollapsed = $sidebar.hasClass('collapsed');
                
                if (isCollapsed) {
                    // Expand sidebar
                    $sidebar.removeClass('collapsed');
                    $mainContent.removeClass('sidebar-collapsed');
                    $(this).find('i').removeClass('fa-angles-right').addClass('fa-bars');
                    localStorage.setItem('sidebarCollapsed', 'false');
                } else {
                    // Collapse sidebar
                    $sidebar.addClass('collapsed');
                    $mainContent.addClass('sidebar-collapsed');
                    $(this).find('i').removeClass('fa-bars').addClass('fa-angles-right');
                    localStorage.setItem('sidebarCollapsed', 'true');
                }
            });
            
            // ========================================
            // END DESKTOP SIDEBAR TOGGLE FUNCTIONALITY
            // ========================================
            
            // Handle stock status toggle
            function handleStockStatusToggle() {
                const $inStockCheckbox = $('#in_stock');
                const $stockQuantityContainer = $('#stock_quantity_container');
                const $stockStatusText = $('#stock-status-text');
                
                if ($inStockCheckbox.length && $stockQuantityContainer.length) {
                    // Initial state
                    if ($inStockCheckbox.is(':checked')) {
                        $stockQuantityContainer.removeClass('d-none');
                        if ($stockStatusText.length) {
                            $stockStatusText.text('In Stock');
                        }
                    } else {
                        $stockQuantityContainer.addClass('d-none');
                        if ($stockStatusText.length) {
                            $stockStatusText.text('Out of Stock');
                        }
                        // Clear the stock quantity when unchecked
                        $('#stock_quantity').val('');
                    }
                    
                    // Add event listener
                    $inStockCheckbox.on('change', function() {
                        if ($(this).is(':checked')) {
                            $stockQuantityContainer.removeClass('d-none');
                            if ($stockStatusText.length) {
                                $stockStatusText.text('In Stock');
                            }
                        } else {
                            $stockQuantityContainer.addClass('d-none');
                            if ($stockStatusText.length) {
                                $stockStatusText.text('Out of Stock');
                            }
                            // Clear the stock quantity when unchecked
                            $('#stock_quantity').val('');
                        }
                    });
                }
            }
            
            // Initialize stock status toggle
            handleStockStatusToggle();
            
            // Toggle SEO settings
            $('#toggle-seo-settings').on('click', function() {
                const $seoContent = $('#seo-settings-content');
                const $icon = $(this).find('i');
                
                if ($seoContent.hasClass('d-none')) {
                    $seoContent.removeClass('d-none');
                    $icon.removeClass('fa-chevron-down').addClass('fa-chevron-up');
                    $(this).html('<i class="fas fa-chevron-up me-1"></i> Collapse');
                } else {
                    $seoContent.addClass('d-none');
                    $icon.removeClass('fa-chevron-up').addClass('fa-chevron-down');
                    $(this).html('<i class="fas fa-chevron-down me-1"></i> Expand');
                }
            });
            
            // Category functionality
            function initializeCategorySelection() {
                // Handle initial state of category checkboxes
                $('.category-checkbox:checked').each(function() {
                    const categoryId = $(this).val();
                    const $subcategoryContainer = $('#subcategory_container_' + categoryId);
                    // Show subcategories for checked categories
                    $subcategoryContainer.removeClass('d-none');
                });
                
                // Handle category checkbox changes
                $('.category-checkbox').on('change', function() {
                    const categoryId = $(this).val();
                    const $subcategoryContainer = $('#subcategory_container_' + categoryId);
                    
                    if ($(this).is(':checked')) {
                        // Show subcategories when category is selected
                        $subcategoryContainer.removeClass('d-none');
                    } else {
                        // Hide and deselect subcategories when category is deselected
                        $subcategoryContainer.addClass('d-none');
                        $subcategoryContainer.find('.subcategory-checkbox').prop('checked', false);
                    }
                });
                
                // Handle "Manage Categories & Subcategories" button
                $('#manage-categories-btn').on('click', function() {
                    loadCategoriesForManagement();
                    $('#categoryManagementModal').modal('show');
                });
                
                // Handle parent category selection for subcategories
                $('#subcategory-parent-category').on('change', function() {
                    const categoryId = $(this).val();
                    if (categoryId) {
                        $('#add-subcategory-btn').prop('disabled', false);
                        loadSubcategoriesForManagement(categoryId);
                    } else {
                        $('#add-subcategory-btn').prop('disabled', true);
                        $('#subcategories-list').html('');
                    }
                });
                
                // Handle adding new category
                $('#add-category-btn').on('click', function() {
                    const categoryName = $('#new-category-name').val().trim();
                    
                    if (!categoryName) {
                        alert('Please enter a category name');
                        return;
                    }
                    
                    // Make AJAX call to create the category
                    $.ajaxSetup({
                        headers: {
                            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                        }
                    });
                    
                    $.ajax({
                        url: '/admin/categories/create',
                        method: 'POST',
                        data: {
                            name: categoryName,
                            description: ''
                        },
                        success: function(response) {
                            if (response.success) {
                                
                                // Clear the input
                                $('#new-category-name').val('');
                                
                                // Reload categories
                                loadCategoriesForManagement();
                                
                                // Also update the main category selection area
                                updateMainCategorySelection(response.category);
                            } else {
                                alert('Error creating category');
                            }
                        },
                        error: function(xhr) {
                            if (xhr.responseJSON && xhr.responseJSON.errors) {
                                let errors = xhr.responseJSON.errors;
                                let errorMessages = '';
                                for (let field in errors) {
                                    errorMessages += errors[field][0] + '\n';
                                }
                                alert('Error creating category:\n' + errorMessages);
                            } else {
                                alert('Error creating category');
                            }
                        }
                    });
                });
                
                // Handle adding new subcategory
                $('#add-subcategory-btn').on('click', function() {
                    const subcategoryName = $('#new-subcategory-name').val().trim();
                    const parentCategoryId = $('#subcategory-parent-category').val();
                    
                    if (!subcategoryName) {
                        alert('Please enter a subcategory name');
                        return;
                    }
                    
                    if (!parentCategoryId) {
                        alert('Please select a parent category');
                        return;
                    }
                    
                    // Make AJAX call to create the subcategory
                    $.ajaxSetup({
                        headers: {
                            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                        }
                    });
                    
                    $.ajax({
                        url: '/admin/subcategories/create',
                        method: 'POST',
                        data: {
                            category_id: parentCategoryId,
                            name: subcategoryName,
                            description: ''
                        },
                        success: function(response) {
                            if (response.success) {
                                
                                // Clear the input
                                $('#new-subcategory-name').val('');
                                
                                // Reload subcategories
                                loadSubcategoriesForManagement(parentCategoryId);
                                
                                // Also update the main subcategory selection area
                                updateMainSubcategorySelection(response.subcategory);
                            } else {
                                alert('Error creating subcategory');
                            }
                        },
                        error: function(xhr) {
                            if (xhr.responseJSON && xhr.responseJSON.errors) {
                                let errors = xhr.responseJSON.errors;
                                let errorMessages = '';
                                for (let field in errors) {
                                    errorMessages += errors[field][0] + '\n';
                                }
                                alert('Error creating subcategory:\n' + errorMessages);
                            } else {
                                alert('Error creating subcategory');
                            }
                        }
                    });
                });
                
                // Handle saving category selections
                $('#save-category-selections').on('click', function() {
                    // Close the modal
                    $('#categoryManagementModal').modal('hide');
                });
            }
            
            // Load categories for management modal
            function loadCategoriesForManagement() {
                // Make AJAX call to load categories
                $.ajax({
                    url: '/admin/categories-all',
                    method: 'GET',
                    success: function(categories) {
                        let html = '';
                        if (categories.length > 0) {
                            categories.forEach(function(category) {
                                html += `
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" id="manage_category_${category.id}" value="${category.id}" data-category-name="${category.name}">
                                        <label class="form-check-label" for="manage_category_${category.id}">
                                            ${category.name}
                                        </label>
                                    </div>
                                `;
                            });
                        } else {
                            html = '<p class="text-muted">No categories available</p>';
                        }
                        
                        $('#categories-list').html(html);
                        
                        // Update the parent category dropdown for subcategories
                        let dropdownHtml = '<option value="">Select a category first</option>';
                        categories.forEach(function(category) {
                            dropdownHtml += `<option value="${category.id}">${category.name}</option>`;
                        });
                        $('#subcategory-parent-category').html(dropdownHtml);
                    },
                    error: function() {
                        $('#categories-list').html('<p class="text-danger">Error loading categories</p>');
                    }
                });
            }
            
            // Load subcategories for management modal
            function loadSubcategoriesForManagement(categoryId) {
                // Make AJAX call to load subcategories for the selected category
                $.ajax({
                    url: '/admin/categories/' + categoryId + '/subcategories',
                    method: 'GET',
                    success: function(response) {
                        let html = '';
                        if (response.data && response.data.length > 0) {
                            response.data.forEach(function(subcategory) {
                                html += `
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" id="manage_subcategory_${subcategory.id}" value="${subcategory.id}">
                                        <label class="form-check-label" for="manage_subcategory_${subcategory.id}">
                                            ${subcategory.name}
                                        </label>
                                    </div>
                                `;
                            });
                        } else {
                            html = '<p class="text-muted">No subcategories available</p>';
                        }
                        
                        $('#subcategories-list').html(html);
                    },
                    error: function() {
                        $('#subcategories-list').html('<p class="text-danger">Error loading subcategories</p>');
                    }
                });
            }
            
            // Update main category selection area with new category
            function updateMainCategorySelection(category) {
                // Check if the category already exists in the main selection area
                if ($('#category_' + category.id).length === 0) {
                    const categoryHtml = `
                        <div class="form-check mb-2 category-item" data-category-id="${category.id}">
                            <input class="form-check-input category-checkbox" type="checkbox" id="category_${category.id}" value="${category.id}" name="product_categories[${category.id}][category_id]">
                            <label class="form-check-label fw-bold" for="category_${category.id}">
                                ${category.name}
                            </label>
                            <div class="subcategory-container ms-4 mt-2 d-none" id="subcategory_container_${category.id}"></div>
                        </div>
                    `;
                    
                    // Add the new category to the main selection area
                    $('#category-selection').append(categoryHtml);
                    
                    // Reattach event handlers
                    $('.category-checkbox').off('change').on('change', function() {
                        const categoryId = $(this).val();
                        const $subcategoryContainer = $('#subcategory_container_' + categoryId);
                        
                        if ($(this).is(':checked')) {
                            // Show subcategories when category is selected
                            $subcategoryContainer.removeClass('d-none');
                        } else {
                            // Hide and deselect subcategories when category is deselected
                            $subcategoryContainer.addClass('d-none');
                            $subcategoryContainer.find('.subcategory-checkbox').prop('checked', false);
                        }
                    });
                }
            }
            
            // Update main subcategory selection area with new subcategory
            function updateMainSubcategorySelection(subcategory) {
                // Check if the subcategory already exists in the main selection area
                if ($('#subcategory_' + subcategory.id).length === 0) {
                    const subcategoryHtml = `
                        <div class="form-check mb-1">
                            <input class="form-check-input subcategory-checkbox" type="checkbox" id="subcategory_${subcategory.id}" value="${subcategory.id}" name="product_categories[${subcategory.category_id}][subcategory_ids][]" data-category-id="${subcategory.category_id}">
                            <label class="form-check-label" for="subcategory_${subcategory.id}">
                                ${subcategory.name}
                            </label>
                        </div>
                    `;
                    
                    // Add the new subcategory to the main selection area
                    $('#subcategory_container_' + subcategory.category_id).append(subcategoryHtml);
                }
            }
            
            // Initialize category selection
            initializeCategorySelection();
            
            // Function to initialize gallery sorting
            function initializeGallerySorting() {
                const galleryItems = document.querySelectorAll('#gallery-preview .gallery-item');
                
                galleryItems.forEach(item => {
                    item.addEventListener('dragstart', handleDragStart);
                    item.addEventListener('dragover', handleDragOver);
                    item.addEventListener('dragenter', handleDragEnter);
                    item.addEventListener('dragleave', handleDragLeave);
                    item.addEventListener('drop', handleDrop);
                    item.addEventListener('dragend', handleDragEnd);
                });
            }
            
            // Drag and drop variables
            let dragSrcEl = null;
            
            function handleDragStart(e) {
                dragSrcEl = this;
                e.dataTransfer.effectAllowed = 'move';
                e.dataTransfer.setData('text/html', this.innerHTML);
                this.classList.add('dragging');
            }
            
            function handleDragOver(e) {
                if (e.preventDefault) {
                    e.preventDefault();
                }
                e.dataTransfer.dropEffect = 'move';
                return false;
            }
            
            function handleDragEnter(e) {
                this.classList.add('drag-over');
            }
            
            function handleDragLeave(e) {
                this.classList.remove('drag-over');
            }
            
            function handleDrop(e) {
                if (e.stopPropagation) {
                    e.stopPropagation();
                }
                
                if (dragSrcEl !== this) {
                    // Get the data-id values
                    const srcId = dragSrcEl.getAttribute('data-id');
                    const targetId = this.getAttribute('data-id');
                    
                    // Swap the positions in the DOM
                    const tempSrc = dragSrcEl.innerHTML;
                    dragSrcEl.innerHTML = this.innerHTML;
                    this.innerHTML = tempSrc;
                    
                    // Update the data-id attributes
                    dragSrcEl.setAttribute('data-id', targetId);
                    this.setAttribute('data-id', srcId);
                    
                    // Reattach event listeners to the swapped elements
                    const newSrcItem = dragSrcEl;
                    const newTargetItem = this;
                    
                    // Remove old event listeners
                    newSrcItem.removeEventListener('dragstart', handleDragStart);
                    newSrcItem.removeEventListener('dragover', handleDragOver);
                    newSrcItem.removeEventListener('dragenter', handleDragEnter);
                    newSrcItem.removeEventListener('dragleave', handleDragLeave);
                    newSrcItem.removeEventListener('drop', handleDrop);
                    newSrcItem.removeEventListener('dragend', handleDragEnd);
                    
                    newTargetItem.removeEventListener('dragstart', handleDragStart);
                    newTargetItem.removeEventListener('dragover', handleDragOver);
                    newTargetItem.removeEventListener('dragenter', handleDragEnter);
                    newTargetItem.removeEventListener('dragleave', handleDragLeave);
                    newTargetItem.removeEventListener('drop', handleDrop);
                    newTargetItem.removeEventListener('dragend', handleDragEnd);
                    
                    // Add new event listeners
                    newSrcItem.addEventListener('dragstart', handleDragStart);
                    newSrcItem.addEventListener('dragover', handleDragOver);
                    newSrcItem.addEventListener('dragenter', handleDragEnter);
                    newSrcItem.addEventListener('dragleave', handleDragLeave);
                    newSrcItem.addEventListener('drop', handleDrop);
                    newSrcItem.addEventListener('dragend', handleDragEnd);
                    
                    newTargetItem.addEventListener('dragstart', handleDragStart);
                    newTargetItem.addEventListener('dragover', handleDragOver);
                    newTargetItem.addEventListener('dragenter', handleDragEnter);
                    newTargetItem.addEventListener('dragleave', handleDragLeave);
                    newTargetItem.addEventListener('drop', handleDrop);
                    newTargetItem.addEventListener('dragend', handleDragEnd);
                    
                    // Update the gallery order in the hidden input
                    updateGalleryOrder();
                }
                
                return false;
            }
            
            function handleDragEnd(e) {
                this.classList.remove('dragging');
                document.querySelectorAll('.gallery-item').forEach(item => {
                    item.classList.remove('drag-over');
                });
            }
            
            // Function to update the gallery order in the hidden input
            function updateGalleryOrder() {
                const galleryItems = document.querySelectorAll('#gallery-preview .gallery-item');
                const newOrder = [];
                
                galleryItems.forEach(item => {
                    const mediaId = parseInt(item.getAttribute('data-id'));
                    newOrder.push(mediaId);
                });
                
                // Update the hidden input
                $('#product_gallery').val(JSON.stringify(newOrder));
            }
            
            // Initialize gallery sorting on page load if there are existing items
            if ($('#gallery-preview .gallery-item').length > 0) {
                initializeGallerySorting();
            }
            
            // ========================================
            // DRAG AND DROP FILE UPLOAD FUNCTIONALITY
            // ========================================
            
            // Helper function to handle file upload for product images
            // Make it globally accessible for use in edit pages
            window.handleProductImageUpload = function(file, targetType) {
                // Validate file type - only images for product photos
                const validImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
                if (!validImageTypes.includes(file.type)) {
                    alert('Please upload a valid image file (JPEG, PNG, GIF, WEBP).');
                    return;
                }
                
                // Validate file size - 25MB max
                const maxSize = 25 * 1024 * 1024;
                if (file.size > maxSize) {
                    alert('File size must be less than 25MB.');
                    return;
                }
                
                const formData = new FormData();
                formData.append('file', file);
                formData.append('name', file.name);
                
                // Show upload indicator
                let $uploadIndicator;
                if (targetType === 'main_photo') {
                    $uploadIndicator = $(`
                        <div class="upload-progress-indicator">
                            <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                            <span>Uploading...</span>
                        </div>
                    `);
                    $('#main-photo-preview').append($uploadIndicator);
                } else {
                    $uploadIndicator = $(`
                        <div class="position-relative gallery-item uploading-item" style="opacity: 0.6;">
                            <div class="bg-light d-flex align-items-center justify-content-center" style="height: 80px; width: 80px;">
                                <div class="spinner-border spinner-border-sm text-primary" role="status"></div>
                            </div>
                        </div>
                    `);
                    $('#gallery-preview').append($uploadIndicator);
                }
                
                // Send AJAX request to upload media
                $.ajaxSetup({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    }
                });
                
                $.ajax({
                    url: '/admin/media',
                    method: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(data) {
                        $uploadIndicator.remove();
                        
                        if (data.success && data.media) {
                            if (targetType === 'main_photo') {
                                // Set main photo
                                $('#main_photo_id').val(data.media.id);
                                $('#main-photo-preview').html(`
                                    <div class="position-relative">
                                        <img src="${data.media.url}" class="img-fluid mb-2" alt="${data.media.name}" style="max-height: 200px; object-fit: contain;">
                                        <div class="mt-2">
                                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill me-2" id="change-main-photo">
                                                <i class="fas fa-sync-alt me-1"></i> Change
                                            </button>
                                            <button type="button" class="btn btn-outline-danger btn-sm rounded-pill" id="remove-main-photo">
                                                <i class="fas fa-trash me-1"></i> Remove
                                            </button>
                                        </div>
                                    </div>
                                `);
                            } else {
                                // Add to gallery
                                const $galleryPreview = $('#gallery-preview');
                                let galleryItems = JSON.parse($('#product_gallery').val() || '[]');
                                
                                // Add new media ID to array
                                galleryItems.push(data.media.id);
                                $('#product_gallery').val(JSON.stringify(galleryItems));
                                
                                // Create gallery item element
                                const $imgContainer = $(`
                                    <div class="position-relative gallery-item" data-id="${data.media.id}" draggable="true">
                                        <div class="bg-light d-flex align-items-center justify-content-center" style="height: 80px; width: 80px;">
                                            <img src="${data.media.url}" class="img-fluid" alt="Gallery image" style="max-height: 100%; max-width: 100%; object-fit: cover;" onerror="this.parentElement.innerHTML='<i class=\\'fas fa-image text-muted\\'></i>'">
                                        </div>
                                        <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 rounded-circle p-1 remove-gallery-item" data-id="${data.media.id}">
                                            <i class="fas fa-times"></i>
                                        </button>
                                        <input type="hidden" name="product_gallery[]" value="${data.media.id}">
                                    </div>
                                `);
                                
                                $galleryPreview.append($imgContainer);
                                
                                // Reinitialize gallery sorting
                                initializeGallerySorting();
                            }
                        } else {
                            alert('Error uploading file. Please try again.');
                        }
                    },
                    error: function(xhr) {
                        $uploadIndicator.remove();
                        let errorMsg = 'Error uploading file. Please try again.';
                        if (xhr.responseJSON && xhr.responseJSON.message) {
                            errorMsg = xhr.responseJSON.message;
                        }
                        alert(errorMsg);
                    }
                });
            }
            
            // Prevent default drag behaviors on the whole document
            $(document).on('dragover dragenter', function(e) {
                e.preventDefault();
                e.stopPropagation();
            });
            
            // Main Photo Upload Area - Drag and Drop
            function initializeMainPhotoDragDrop() {
                const $mainPhotoArea = $('#main-photo-upload-area, #main-photo-preview');
                
                $mainPhotoArea.off('dragover dragenter dragleave drop');
                
                $mainPhotoArea.on('dragover dragenter', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).addClass('drag-highlight');
                });
                
                $mainPhotoArea.on('dragleave', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).removeClass('drag-highlight');
                });
                
                $mainPhotoArea.on('drop', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).removeClass('drag-highlight');
                    
                    const files = e.originalEvent.dataTransfer.files;
                    if (files.length > 0) {
                        // Only upload the first file for main photo
                        handleProductImageUpload(files[0], 'main_photo');
                    }
                });
                
                // Click to upload for main photo area (only on upload area, not on existing image)
                $('#main-photo-upload-area').off('click').on('click', function(e) {
                    // Don't trigger if clicking on buttons inside
                    if ($(e.target).is('button') || $(e.target).closest('button').length) {
                        return;
                    }
                    
                    const fileInput = $('<input type="file" accept="image/*" style="display: none;">');
                    $('body').append(fileInput);
                    
                    fileInput.on('change', function() {
                        if (this.files.length > 0) {
                            handleProductImageUpload(this.files[0], 'main_photo');
                        }
                        fileInput.remove();
                    });
                    
                    fileInput.click();
                });
            }
            
            // Gallery Upload Area - Drag and Drop
            function initializeGalleryDragDrop() {
                const $galleryArea = $('#gallery-upload-area');
                
                $galleryArea.off('dragover dragenter dragleave drop click');
                
                $galleryArea.on('dragover dragenter', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).addClass('drag-highlight');
                });
                
                $galleryArea.on('dragleave', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).removeClass('drag-highlight');
                });
                
                $galleryArea.on('drop', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).removeClass('drag-highlight');
                    
                    const files = e.originalEvent.dataTransfer.files;
                    if (files.length > 0) {
                        // Upload all dropped files to gallery
                        for (let i = 0; i < files.length; i++) {
                            handleProductImageUpload(files[i], 'gallery');
                        }
                    }
                });
                
                // Click to upload for gallery area
                $galleryArea.on('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    const fileInput = $('<input type="file" accept="image/*" multiple style="display: none;">');
                    $('body').append(fileInput);
                    
                    fileInput.on('change', function() {
                        if (this.files.length > 0) {
                            for (let i = 0; i < this.files.length; i++) {
                                handleProductImageUpload(this.files[i], 'gallery');
                            }
                        }
                        fileInput.remove();
                    });
                    
                    fileInput.click();
                });
            }
            
            // Initialize drag and drop on page load
            initializeMainPhotoDragDrop();
            initializeGalleryDragDrop();
            
            // Re-initialize when DOM changes (e.g., after removing main photo)
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    if (mutation.type === 'childList') {
                        // Check if main photo area needs re-initialization
                        if ($('#main-photo-upload-area').length) {
                            initializeMainPhotoDragDrop();
                        }
                    }
                });
            });
            
            // Observe main photo preview for changes
            const mainPhotoPreview = document.getElementById('main-photo-preview');
            if (mainPhotoPreview) {
                observer.observe(mainPhotoPreview, { childList: true, subtree: true });
            }
            
            // ========================================
            // END DRAG AND DROP FILE UPLOAD
            // ========================================
            
            // Add event handler for change main photo button
            $(document).on('click', '#change-main-photo', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                const fileInput = $('<input type="file" accept="image/*" style="display: none;">');
                $('body').append(fileInput);
                
                fileInput.on('change', function() {
                    if (this.files.length > 0) {
                        window.handleProductImageUpload(this.files[0], 'main_photo');
                    }
                    fileInput.remove();
                });
                
                fileInput.click();
            });
            
            // Add event handler for remove main photo button
            $(document).on('click', '#remove-main-photo', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                if (confirm('Are you sure you want to remove the main photo?')) {
                    // Clear the main photo ID
                    $('#main_photo_id').val('');
                    
                    // Replace with upload area
                    $('#main-photo-preview').html(`
                        <div class="upload-area" id="main-photo-upload-area" style="min-height: 200px; border: 2px dashed #ccc; border-radius: 10px; display: flex; align-items: center; justify-content: center; cursor: pointer;">
                            <div class="text-center">
                                <i class="fas fa-cloud-upload-alt fa-2x text-muted mb-2"></i>
                                <p class="text-muted mb-0">Drag & drop an image here or click to select</p>
                            </div>
                        </div>
                    `);
                }
            });
            
            // Add event handler for existing gallery item remove buttons
            // This fixes the issue where remove buttons for existing gallery items don't work
            $(document).on('click', '.remove-gallery-item', function() {
                const mediaId = parseInt($(this).data('id'));
                
                // Get current gallery items
                let galleryItems = JSON.parse($('#product_gallery').val() || '[]');
                
                // Remove the item from the array
                const index = galleryItems.indexOf(mediaId);
                if (index > -1) {
                    galleryItems.splice(index, 1);
                }
                
                // Update the hidden input
                $('#product_gallery').val(JSON.stringify(galleryItems));
                
                // Remove the element
                $(this).closest('.gallery-item').remove();
            });
            
            // Validate selling price <= MRP
            $('#selling_price').on('input', function() {
                const mrp = parseFloat($('#mrp').val()) || 0;
                const sellingPrice = parseFloat($(this).val()) || 0;
                
                if (mrp > 0 && sellingPrice > mrp) {
                    this.setCustomValidity('Selling price must be less than or equal to MRP.');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            $('#mrp').on('input', function() {
                const mrp = parseFloat($(this).val()) || 0;
                const sellingPrice = parseFloat($('#selling_price').val()) || 0;
                
                if (mrp > 0 && sellingPrice > mrp) {
                    $('#selling_price')[0].setCustomValidity('Selling price must be less than or equal to MRP.');
                } else {
                    $('#selling_price')[0].setCustomValidity('');
                }
            });
        });
    });
})();