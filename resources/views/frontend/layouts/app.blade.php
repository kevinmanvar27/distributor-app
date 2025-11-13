<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    
    <title>{{ setting('site_title', 'Frontend App') }} - {{ setting('tagline', 'Your Frontend Application') }}</title>
    
    <!-- Favicon -->
    @if(setting('favicon'))
        <link rel="icon" type="image/x-icon" href="{{ asset('storage/' . setting('favicon')) }}">
    @else
        <link rel="icon" type="image/x-icon" href="data:image/x-icon;base64,AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAQAAVzABAEAjBQAaDwYAWjUGAGE6CQBrQQ0ATS8dAFAzHgBhPBMARjMcAFE0HgBmQg8ARjMeAFI1HgBhQg4AUzceAGZDDwBpRg4Aa0gOAHBKDgBzTA4Afk0OAHRNDgCETQ4A">
    @endif
    
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <!-- Custom Styles with dynamic settings -->
    <style>
        :root {
            /* Color settings */
            --theme-color: {{ setting('theme_color', '#007bff') }};
            --background-color: {{ setting('background_color', '#f8f9fa') }};
            --font-color: {{ setting('font_color', '#333333') }};
            --font-style: {{ setting('font_style', 'Arial, sans-serif') }};
            --link-color: {{ setting('link_color', '#007bff') }};
            --link-hover-color: {{ setting('link_hover_color', '#0056b3') }};
            --sidebar-text-color: {{ setting('sidebar_text_color', '#333333') }};
            --heading-text-color: {{ setting('heading_text_color', '#333333') }};
            --label-text-color: {{ setting('label_text_color', '#333333') }};
            --general-text-color: {{ setting('general_text_color', '#333333') }};
            
            /* Font size settings for desktop */
            --desktop-h1-size: {{ setting('desktop_h1_size', 36) }}px;
            --desktop-h2-size: {{ setting('desktop_h2_size', 30) }}px;
            --desktop-h3-size: {{ setting('desktop_h3_size', 24) }}px;
            --desktop-h4-size: {{ setting('desktop_h4_size', 20) }}px;
            --desktop-h5-size: {{ setting('desktop_h5_size', 18) }}px;
            --desktop-h6-size: {{ setting('desktop_h6_size', 16) }}px;
            --desktop-body-size: {{ setting('desktop_body_size', 16) }}px;
            
            /* Font size settings for tablet */
            --tablet-h1-size: {{ setting('tablet_h1_size', 32) }}px;
            --tablet-h2-size: {{ setting('tablet_h2_size', 28) }}px;
            --tablet-h3-size: {{ setting('tablet_h3_size', 22) }}px;
            --tablet-h4-size: {{ setting('tablet_h4_size', 18) }}px;
            --tablet-h5-size: {{ setting('tablet_h5_size', 16) }}px;
            --tablet-h6-size: {{ setting('tablet_h6_size', 14) }}px;
            --tablet-body-size: {{ setting('tablet_body_size', 14) }}px;
            
            /* Font size settings for mobile */
            --mobile-h1-size: {{ setting('mobile_h1_size', 28) }}px;
            --mobile-h2-size: {{ setting('mobile_h2_size', 24) }}px;
            --mobile-h3-size: {{ setting('mobile_h3_size', 20) }}px;
            --mobile-h4-size: {{ setting('mobile_h4_size', 16) }}px;
            --mobile-h5-size: {{ setting('mobile_h5_size', 14) }}px;
            --mobile-h6-size: {{ setting('mobile_h6_size', 12) }}px;
            --mobile-body-size: {{ setting('mobile_body_size', 12) }}px;
        }
        
        body {
            background-color: var(--background-color) !important;
            color: var(--font-color) !important;
            font-family: var(--font-style) !important;
            font-size: var(--desktop-body-size) !important;
        }
        
        /* Text color styles */
        .navbar-brand, .navbar-nav .nav-link {
            color: var(--font-color) !important;
        }
        
        .sidebar-text {
            color: var(--sidebar-text-color) !important;
        }
        
        .heading-text {
            color: var(--heading-text-color) !important;
        }
        
        .label-text {
            color: var(--label-text-color) !important;
        }
        
        .general-text {
            color: var(--general-text-color) !important;
        }
        
        /* Button styles */
        .btn-theme {
            background-color: var(--theme-color) !important;
            border-color: var(--theme-color) !important;
            color: white !important;
        }
        
        .btn-theme:hover {
            background-color: var(--link-hover-color) !important;
            border-color: var(--link-hover-color) !important;
        }
        
        /* Link styles */
        a {
            color: var(--link-color) !important;
        }
        
        a:hover {
            color: var(--link-hover-color) !important;
        }
        
        /* Font size styles for headings with higher specificity */
        h1, .h1 {
            font-size: var(--desktop-h1-size) !important;
        }
        
        h2, .h2 {
            font-size: var(--desktop-h2-size) !important;
        }
        
        h3, .h3 {
            font-size: var(--desktop-h3-size) !important;
        }
        
        h4, .h4 {
            font-size: var(--desktop-h4-size) !important;
        }
        
        h5, .h5 {
            font-size: var(--desktop-h5-size) !important;
        }
        
        h6, .h6 {
            font-size: var(--desktop-h6-size) !important;
        }
        
        p, .lead {
            font-size: var(--desktop-body-size) !important;
        }
        
        /* Responsive font sizes with higher specificity */
        @media (max-width: 992px) {
            h1, .h1 {
                font-size: var(--tablet-h1-size) !important;
            }
            
            h2, .h2 {
                font-size: var(--tablet-h2-size) !important;
            }
            
            h3, .h3 {
                font-size: var(--tablet-h3-size) !important;
            }
            
            h4, .h4 {
                font-size: var(--tablet-h4-size) !important;
            }
            
            h5, .h5 {
                font-size: var(--tablet-h5-size) !important;
            }
            
            h6, .h6 {
                font-size: var(--tablet-h6-size) !important;
            }
            
            body, p, .lead {
                font-size: var(--tablet-body-size) !important;
            }
        }
        
        @media (max-width: 768px) {
            h1, .h1 {
                font-size: var(--mobile-h1-size) !important;
            }
            
            h2, .h2 {
                font-size: var(--mobile-h2-size) !important;
            }
            
            h3, .h3 {
                font-size: var(--mobile-h3-size) !important;
            }
            
            h4, .h4 {
                font-size: var(--mobile-h4-size) !important;
            }
            
            h5, .h5 {
                font-size: var(--mobile-h5-size) !important;
            }
            
            h6, .h6 {
                font-size: var(--mobile-h6-size) !important;
            }
            
            body, p, .lead {
                font-size: var(--mobile-body-size) !important;
            }
        }
    </style>
    
    @yield('styles')
</head>
<body>
    <div id="app">
        @yield('content')
    </div>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    @yield('scripts')
</body>
</html>