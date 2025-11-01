// Common JavaScript functions for the admin panel

$(document).ready(function() {
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
    
    // Remove main photo
    $('#remove-main-photo').on('click', function() {
        $('#main_photo_id').val('');
        $('#main-photo-preview').html(`
            <i class="fas fa-image fa-2x text-muted mb-2"></i>
            <p class="text-muted mb-2">No image selected</p>
            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#mediaLibraryModal" data-target="main_photo">
                <i class="fas fa-folder-open me-1"></i> Select from Media Library
            </button>
        `);
    });
    
    // Media library functionality
    let selectedMedia = [];
    let targetField = null;
    let currentPage = 1;
    let hasMorePages = false;
    let currentSearch = '';
    let currentFilter = 'all';
    let isDragging = false;
    
    // Handle media library modal show event
    $('#mediaLibraryModal').on('show.bs.modal', function(event) {
        targetField = $(event.relatedTarget).data('target');
        selectedMedia = [];
        $('#select-media-btn').prop('disabled', true);
        
        // Reset to first page
        currentPage = 1;
        currentSearch = '';
        currentFilter = 'all';
        $('#media-search').val('');
        $('#media-filter').val('all');
        
        // Load media items
        loadMediaLibrary();
    });
    
    // Search media with debounce
    let searchTimeout;
    $('#media-search').on('input', function() {
        clearTimeout(searchTimeout);
        currentSearch = $(this).val();
        currentPage = 1;
        
        searchTimeout = setTimeout(function() {
            loadMediaLibrary();
        }, 300); // 300ms debounce
    });
    
    // Filter media
    $('#media-filter').on('change', function() {
        currentFilter = $(this).val();
        currentPage = 1;
        loadMediaLibrary();
    });
    
    // Upload first media button (for empty state)
    $(document).on('click', '#empty-state-upload', function() {
        // Create a hidden file input
        const fileInput = $('<input type="file" accept="image/*,video/*" style="display: none;">');
        $('body').append(fileInput);
        
        fileInput.on('change', function() {
            if (this.files.length > 0) {
                handleFileUpload(this.files[0]);
            }
            fileInput.remove();
        });
        
        fileInput.click();
    });
    
    // Drag and drop functionality for media library
    $('#media-library-items').on('dragover', function(e) {
        e.preventDefault();
        e.stopPropagation();
    });
    
    $('#media-library-items').on('dragenter', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $(this).addClass('drag-over');
    });
    
    $('#media-library-items').on('dragleave', function(e) {
        e.preventDefault();
        e.stopPropagation();
        // Only remove drag-over class if we're actually leaving the element
        if (e.target === this || $(e.target).closest('#media-library-items').length === 0) {
            $(this).removeClass('drag-over');
        }
    });
    
    $('#media-library-items').on('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $(this).removeClass('drag-over');
        
        const files = e.originalEvent.dataTransfer.files;
        if (files.length > 0) {
            handleFileUpload(files[0]);
        }
    });
    
    // Handle file upload
    function handleFileUpload(file) {
        // Validate file type
        const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/x-ms-wmv'];
        if (!validTypes.includes(file.type)) {
            alert('Please upload a valid image or video file (JPEG, PNG, GIF, WEBP, MP4, MOV, AVI, WMV).');
            return;
        }
        
        // Validate file size (10MB max)
        if (file.size > 10 * 1024 * 1024) {
            alert('File size must be less than 10MB.');
            return;
        }
        
        const formData = new FormData();
        formData.append('file', file);
        formData.append('name', file.name);
        
        // Show upload indicator only during actual upload
        const $uploadIndicator = $('<div class="mb-4"><div class="card border-0 shadow-sm h-100"><div class="card-img-top bg-light d-flex align-items-center justify-content-center" style="height: 150px;"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Uploading...</span></div></div></div></div>');
        $('#media-library-items').prepend($uploadIndicator);
        
        // Hide existing content during upload
        $('#media-library-items .mb-4:not(:first-child)').addClass('d-none');
        $('#no-media-message').addClass('d-none');
        
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
            xhr: function() {
                const xhr = new window.XMLHttpRequest();
                xhr.upload.addEventListener("progress", function(evt) {
                    if (evt.lengthComputable) {
                        const percentComplete = evt.loaded / evt.total * 100;
                        // We could update a progress bar here if needed
                    }
                }, false);
                return xhr;
            },
            success: function(data) {
                // Remove upload indicator
                $uploadIndicator.remove();
                
                // Show existing content again
                $('#media-library-items .mb-4').removeClass('d-none');
                
                if (data.success) {
                    // Add the new item to the top of the grid without full refresh
                    if (data.media) {
                        const newItem = `
                            <div class="mb-4">
                                <div class="card border-0 shadow-sm media-item position-relative h-100" data-id="${data.media.id}">
                                    <div class="card-img-top bg-light d-flex align-items-center justify-content-center">
                                        <img src="${data.media.url || ''}" alt="${data.media.name || 'Media item'}" onerror="this.parentElement.innerHTML='<i class=\\'fas fa-image fa-2x text-muted\\'></i>'">
                                    </div>
                                    <div class="selection-indicator">
                                        <i class="fas fa-check"></i>
                                    </div>
                                    <button class="btn btn-danger btn-sm position-absolute top-0 end-0 m-2 remove-media-btn" data-id="${data.media.id}" title="Remove">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </div>
                            </div>
                        `;
                        const $newItem = $(newItem);
                        
                        // Add click event for selection
                        $newItem.find('.media-item').on('click', function(e) {
                            // Prevent click when clicking on remove button
                            if ($(e.target).hasClass('remove-media-btn') || $(e.target).closest('.remove-media-btn').length > 0) {
                                return;
                            }
                            
                            const id = parseInt($(this).data('id'));
                            const index = selectedMedia.indexOf(id);
                            
                            if (index > -1) {
                                // Already selected, so deselect
                                $(this).removeClass('border-primary');
                                selectedMedia.splice(index, 1);
                            } else {
                                // Not selected, so select
                                if (targetField === 'main_photo') {
                                    // For main photo, only allow one selection
                                    $('.media-item').removeClass('border-primary');
                                    selectedMedia = [id];
                                    $(this).addClass('border-primary');
                                } else {
                                    // For gallery, allow multiple selections
                                    selectedMedia.push(id);
                                    $(this).addClass('border-primary');
                                }
                            }
                            
                            // Update select button state
                            $('#select-media-btn').prop('disabled', selectedMedia.length === 0);
                        });
                        
                        // Add click event for remove button
                        $newItem.find('.remove-media-btn').on('click', function(e) {
                            e.stopPropagation();
                            const mediaId = $(this).data('id');
                            removeMedia(mediaId, $(this).closest('.mb-4'));
                        });
                        
                        $('#media-library-items').prepend($newItem);
                        
                        // If this was the first item, hide the no-media message
                        $('#no-media-message').addClass('d-none');
                    }
                } else {
                    console.error('Upload failed:', data.error);
                    // Show error message if needed
                }
            },
            error: function(xhr, status, error) {
                // Remove upload indicator
                $uploadIndicator.remove();
                
                // Show existing content again
                $('#media-library-items .mb-4').removeClass('d-none');
                
                console.error('Upload failed:', error);
                // Show error message if needed
            }
        });
    }
    
    // Upload media form submission
    $('#upload-media-submit').on('click', function() {
        const fileInput = $('#media-file')[0];
        const nameInput = $('#media-name');
        
        if (!fileInput.files.length) {
            alert('Please select a file to upload.');
            return;
        }
        
        const file = fileInput.files[0];
        handleFileUpload(file);
    });
    
    // Load media library function
    function loadMediaLibrary(page = 1) {
        // Show loading indicator
        $('#media-loading').removeClass('d-none');
        $('#no-media-message').addClass('d-none');
        $('#load-more-btn').addClass('d-none');
        
        // Build URL with parameters - explicitly check for valid page number
        if (!page || page < 1) {
            page = 1;
        }
        
        let url = '/admin/media?page=' + page;
        if (currentSearch) {
            url += '&search=' + encodeURIComponent(currentSearch);
        }
        if (currentFilter && currentFilter !== 'all') {
            url += '&type=' + currentFilter;
        }
        
        // Make AJAX request to fetch media items
        $.get(url)
            .done(function(data) {
                $('#media-loading').addClass('d-none');
                
                if (data.data && data.data.length > 0) {
                    renderMediaItems(data.data);
                    
                    // Check if there are more pages
                    hasMorePages = data.next_page_url !== null;
                    
                    // Show load more button if there are more pages
                    if (hasMorePages) {
                        $('#load-more-btn').removeClass('d-none');
                    }
                } else {
                    $('#no-media-message').removeClass('d-none');
                }
            })
            .fail(function(xhr, status, error) {
                $('#media-loading').addClass('d-none');
                $('#no-media-message').removeClass('d-none');
                console.error('Error loading media:', error);
                console.error('Request URL:', url);
            });
    }
    
    // Render media items function with better fallbacks
    function renderMediaItems(mediaItems) {
        const $container = $('#media-library-items');
        
        // If this is the first page, clear the container
        if (currentPage === 1) {
            $container.empty();
        }
        
        mediaItems.forEach(function(item) {
            // Ensure item has required properties
            if (!item || !item.id) {
                return;
            }
            
            const $col = $('<div class="mb-4"></div>');
            $col.html(`
                <div class="card border-0 shadow-sm media-item position-relative h-100" data-id="${item.id}">
                    <div class="card-img-top bg-light d-flex align-items-center justify-content-center">
                        <img src="${item.url || ''}" alt="${item.name || 'Media item'}" onerror="this.parentElement.innerHTML='<i class=\\'fas fa-image fa-2x text-muted\\'></i>'">
                    </div>
                    <div class="selection-indicator">
                        <i class="fas fa-check"></i>
                    </div>
                    <button class="btn btn-danger btn-sm position-absolute top-0 end-0 m-2 remove-media-btn" data-id="${item.id}" title="Remove">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `);
            
            // Add click event for selection
            $col.find('.media-item').on('click', function(e) {
                // Prevent click when clicking on remove button
                if ($(e.target).hasClass('remove-media-btn') || $(e.target).closest('.remove-media-btn').length > 0) {
                    return;
                }
                
                const id = parseInt($(this).data('id'));
                const index = selectedMedia.indexOf(id);
                
                if (index > -1) {
                    // Already selected, so deselect
                    $(this).removeClass('border-primary');
                    selectedMedia.splice(index, 1);
                } else {
                    // Not selected, so select
                    if (targetField === 'main_photo') {
                        // For main photo, only allow one selection
                        $('.media-item').removeClass('border-primary');
                        selectedMedia = [id];
                        $(this).addClass('border-primary');
                    } else {
                        // For gallery, allow multiple selections
                        selectedMedia.push(id);
                        $(this).addClass('border-primary');
                    }
                }
                
                // Update select button state
                $('#select-media-btn').prop('disabled', selectedMedia.length === 0);
            });
            
            // Add click event for remove button
            $col.find('.remove-media-btn').on('click', function(e) {
                e.stopPropagation();
                const mediaId = $(this).data('id');
                removeMedia(mediaId, $(this).closest('.mb-4'));
            });
            
            $container.append($col);
        });
    }
    
    // Function to remove media
    function removeMedia(mediaId, $element) {
        if (!confirm('Are you sure you want to delete this media item?')) {
            return;
        }
        
        $.ajaxSetup({
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            }
        });
        
        $.ajax({
            url: '/admin/media/' + mediaId,
            method: 'DELETE',
            success: function(data) {
                if (data.success) {
                    // Remove the element from the DOM
                    $element.fadeOut(300, function() {
                        $(this).remove();
                        
                        // If no media items left, show empty message
                        if ($('#media-library-items .col-3').length === 0) {
                            $('#no-media-message').removeClass('d-none');
                        }
                        
                        // Remove from selected media if it was selected
                        const index = selectedMedia.indexOf(mediaId);
                        if (index > -1) {
                            selectedMedia.splice(index, 1);
                            $('#select-media-btn').prop('disabled', selectedMedia.length === 0);
                        }
                    });
                } else {
                    alert('Failed to delete media item.');
                }
            },
            error: function(xhr, status, error) {
                console.error('Delete failed:', error);
                alert('Failed to delete media item.');
            }
        });
    }
    
    // Load more button
    $('#load-more-btn').on('click', function() {
        currentPage++;
        loadMediaLibrary(currentPage);
    });
    
    // Select media button
    $('#select-media-btn').on('click', function() {
        if (targetField === 'main_photo') {
            // Handle main photo selection
            if (selectedMedia.length > 0) {
                const mediaId = selectedMedia[0];
                $('#main_photo_id').val(mediaId);
                
                // Get the media URL from the selected item
                const $selectedItem = $(`.media-item[data-id="${mediaId}"]`);
                const mediaUrl = $selectedItem.find('img').attr('src') || '/storage/media/placeholder.jpg';
                
                // Update preview with the actual image
                $('#main-photo-preview').html(`
                    <div class="bg-light d-flex align-items-center justify-content-center mb-2" style="height: 150px;">
                        <img src="${mediaUrl}" class="img-fluid" alt="Selected image" style="max-height: 100%; max-width: 100%; object-fit: cover;" onerror="this.parentElement.innerHTML='<i class=\\'fas fa-image fa-2x text-muted\\'></i>'">
                    </div>
                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#mediaLibraryModal" data-target="main_photo">
                        <i class="fas fa-folder-open me-1"></i> Change Image
                    </button>
                    <button type="button" class="btn btn-outline-danger btn-sm rounded-pill ms-2" id="remove-main-photo">
                        <i class="fas fa-trash me-1"></i> Remove
                    </button>
                `);
                
                // Add remove functionality
                $('#remove-main-photo').on('click', function() {
                    $('#main_photo_id').val('');
                    $('#main-photo-preview').html(`
                        <i class="fas fa-image fa-2x text-muted mb-2"></i>
                        <p class="text-muted mb-2">No image selected</p>
                        <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#mediaLibraryModal" data-target="main_photo">
                            <i class="fas fa-folder-open me-1"></i> Select from Media Library
                        </button>
                    `);
                });
            }
        } else if (targetField === 'gallery') {
            // Handle gallery photos selection
            const $galleryPreview = $('#gallery-preview');
            
            // If we're adding to existing gallery items, we need to merge them
            const existingItems = [];
            $galleryPreview.find('.gallery-item').each(function() {
                existingItems.push(parseInt($(this).data('id')));
            });
            
            // Add new selected items that aren't already in the gallery
            const newItems = selectedMedia.filter(id => !existingItems.includes(id));
            
            // Update the hidden input with all media IDs
            const allItems = [...existingItems, ...newItems];
            $('#product_gallery').val(JSON.stringify(allItems));
            
            // Add new items to the gallery preview
            newItems.forEach(function(mediaId) {
                // Get the media URL from the selected item
                const $selectedItem = $(`.media-item[data-id="${mediaId}"]`);
                const mediaUrl = $selectedItem.find('img').attr('src') || '/storage/media/placeholder.jpg';
                
                const $imgContainer = $('<div class="position-relative gallery-item" data-id="' + mediaId + '" draggable="true"></div>');
                $imgContainer.html(`
                    <div class="bg-light d-flex align-items-center justify-content-center" style="height: 80px; width: 80px;">
                        <img src="${mediaUrl}" class="img-fluid" alt="Gallery image" style="max-height: 100%; max-width: 100%; object-fit: cover;" onerror="this.parentElement.innerHTML='<i class=\\'fas fa-image text-muted\\'></i>'">
                    </div>
                    <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 rounded-circle p-1 remove-gallery-item" data-id="${mediaId}">
                        <i class="fas fa-times"></i>
                    </button>
                    <input type="hidden" name="product_gallery[]" value="${mediaId}">
                `);
                
                $galleryPreview.append($imgContainer);
            });
            
            // Add drag and drop functionality for gallery reordering
            initializeGallerySorting();
            
            // Add remove functionality to gallery items
            $('.remove-gallery-item').on('click', function() {
                const mediaId = parseInt($(this).data('id'));
                
                // Remove from the array
                const index = allItems.indexOf(mediaId);
                if (index > -1) {
                    allItems.splice(index, 1);
                }
                
                // Update the hidden input
                $('#product_gallery').val(JSON.stringify(allItems));
                
                // Remove the element
                $(this).closest('.gallery-item').remove();
            });
        }
        
        // Close the modal
        $('#mediaLibraryModal').modal('hide');
    });
    
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