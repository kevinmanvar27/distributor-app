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
        body {
            background-color: #f8f9fa !important;
            color: #333333 !important;
            font-family: Arial, sans-serif !important;
            font-size: 16px !important;
        }
        
        /* Text color styles */
        .navbar-brand, .navbar-nav .nav-link {
            color: #333333 !important;
        }
        
        .sidebar-text {
            color: #333333 !important;
        }
        
        .heading-text {
            color: #333333 !important;
        }
        
        .label-text {
            color: #333333 !important;
        }
        
        .general-text {
            color: #333333 !important;
        }
        
        /* Button styles */
        .btn-theme {
            background-color: {{ setting('theme_color', '#007bff') }} !important;
            border-color: {{ setting('theme_color', '#007bff') }} !important;
            color: white !important;
        }
        
        .btn-theme:hover {
            background-color: {{ setting('link_hover_color', '#0056b3') }} !important;
            border-color: {{ setting('link_hover_color', '#0056b3') }} !important;
        }
        
        /* Link styles */
        a {
            color: {{ setting('link_color', '#007bff') }} !important;
        }
        
        a:hover {
            color: {{ setting('link_hover_color', '#0056b3') }} !important;
        }
        
        /* Font size styles for headings with higher specificity */
        h1, .h1 {
            font-size: 36px !important;
        }
        
        h2, .h2 {
            font-size: 30px !important;
        }
        
        h3, .h3 {
            font-size: 24px !important;
        }
        
        h4, .h4 {
            font-size: 20px !important;
        }
        
        h5, .h5 {
            font-size: 18px !important;
        }
        
        h6, .h6 {
            font-size: 16px !important;
        }
        
        p, .lead {
            font-size: 16px !important;
        }
        
        /* Responsive font sizes with higher specificity */
        @media (max-width: 992px) {
            h1, .h1 {
                font-size: 32px !important;
            }
            
            h2, .h2 {
                font-size: 28px !important;
            }
            
            h3, .h3 {
                font-size: 22px !important;
            }
            
            h4, .h4 {
                font-size: 18px !important;
            }
            
            h5, .h5 {
                font-size: 16px !important;
            }
            
            h6, .h6 {
                font-size: 14px !important;
            }
            
            body, p, .lead {
                font-size: 14px !important;
            }
        }
        
        @media (max-width: 768px) {
            h1, .h1 {
                font-size: 28px !important;
            }
            
            h2, .h2 {
                font-size: 24px !important;
            }
            
            h3, .h3 {
                font-size: 20px !important;
            }
            
            h4, .h4 {
                font-size: 16px !important;
            }
            
            h5, .h5 {
                font-size: 14px !important;
            }
            
            h6, .h6 {
                font-size: 12px !important;
            }
            
            body, p, .lead {
                font-size: 12px !important;
            }
        }
        
        /* Header and Footer Styles */
        .site-header {
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,.05);
        }
        
        .site-footer {
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
            padding: 2rem 0;
            margin-top: auto;
        }
        
        .footer-logo {
            max-height: 40px;
        }
    </style>
    
    @yield('styles')
</head>
<body class="d-flex flex-column min-vh-100">
    <!-- Header -->
    <header class="site-header py-3">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    @if(setting('header_logo'))
                        <img src="{{ asset('storage/' . setting('header_logo')) }}" alt="{{ setting('site_title', 'Frontend App') }}" class="rounded" height="50">
                    @else
                        <h1 class="h4 mb-0 fw-bold heading-text">{{ setting('site_title', 'Frontend App') }}</h1>
                    @endif
                </div>
                
                <nav class="d-none d-md-block">
                    <ul class="navbar-nav flex-row">
                        <li class="nav-item me-3">
                            <a class="nav-link" href="/">Home</a>
                        </li>
                        <!-- Add more navigation items as needed -->
                    </ul>
                </nav>
                
                <div>
                    @auth
                        <div class="dropdown">
                            <button class="btn btn-sm btn-theme dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                {{ Auth::user()->name }}
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="{{ route('frontend.profile') }}">Profile</a></li>
                                <li>
                                    <form method="POST" action="{{ route('frontend.logout') }}">
                                        @csrf
                                        <button type="submit" class="dropdown-item">Logout</button>
                                    </form>
                                </li>
                            </ul>
                        </div>
                    @else
                        <a href="{{ route('frontend.login') }}" class="btn btn-sm btn-theme">Login</a>
                    @endauth
                </div>
            </div>
        </div>
    </header>
    
    <div id="app" class="flex-grow-1">
        @yield('content')
    </div>
    
    <!-- Footer -->
    <footer class="site-footer">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-6 mb-3 mb-md-0">
                    <div class="d-flex align-items-center">
                        @if(setting('footer_logo'))
                            <img src="{{ asset('storage/' . setting('footer_logo')) }}" alt="{{ setting('site_title', 'Frontend App') }}" class="rounded footer-logo">
                        @else
                            <span class="general-text">
                                {{ setting('footer_text', '© ' . date('Y') . ' ' . config('app.name', 'Laravel') . '. All rights reserved.') }}
                            </span>
                        @endif
                    </div>
                </div>
                <div class="col-md-6">
                    <ul class="nav justify-content-md-end">
                        @if(setting('facebook_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('facebook_url') }}" target="_blank" data-bs-toggle="tooltip" title="Facebook">
                                <i class="fab fa-facebook-f"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('twitter_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('twitter_url') }}" target="_blank" data-bs-toggle="tooltip" title="Twitter">
                                <i class="fab fa-twitter"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('instagram_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('instagram_url') }}" target="_blank" data-bs-toggle="tooltip" title="Instagram">
                                <i class="fab fa-instagram"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('linkedin_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('linkedin_url') }}" target="_blank" data-bs-toggle="tooltip" title="LinkedIn">
                                <i class="fab fa-linkedin-in"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('youtube_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('youtube_url') }}" target="_blank" data-bs-toggle="tooltip" title="YouTube">
                                <i class="fab fa-youtube"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('whatsapp_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('whatsapp_url') }}" target="_blank" data-bs-toggle="tooltip" title="WhatsApp">
                                <i class="fab fa-whatsapp"></i>
                            </a>
                        </li>
                        @endif
                    </ul>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    @yield('scripts')
</body>
</html>