@extends('frontend.layouts.app')

@section('title', 'Profile - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container py-5">
    <!-- Success Message -->
    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif
    
    <!-- Error Messages -->
    @if($errors->any())
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i>
            <strong>Whoops!</strong> There were some problems with your input.
            <ul class="mb-0 mt-2">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif
    
    <div class="row">
        <!-- Profile Sidebar -->
        <div class="col-lg-4 mb-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-0">
                    <h3 class="h5 mb-0 fw-bold heading-text">Profile</h3>
                </div>
                <div class="card-body text-center">
                    <div class="position-relative d-inline-block">
                        @if($user->avatar)
                            <img src="{{ asset('storage/avatars/' . $user->avatar) }}" alt="{{ $user->name }}" class="img-fluid rounded-circle mb-3" style="width: 150px; height: 150px; object-fit: cover;">
                        @else
                            <div class="bg-theme rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 150px; height: 150px; background-color: {{ setting('theme_color', '#007bff') }};">
                                <i class="fas fa-user text-white" style="font-size: 4rem;"></i>
                            </div>
                        @endif
                        
                        <!-- Avatar Upload Form -->
                        <form id="avatar-form" action="{{ route('frontend.profile.avatar.update') }}" method="POST" enctype="multipart/form-data" class="d-none">
                            @csrf
                            <input type="file" name="avatar" id="avatar-input" accept="image/*">
                        </form>
                        
                        <button type="button" class="btn btn-sm btn-theme rounded-circle position-absolute bottom-0 end-0" id="change-avatar-btn" style="width: 40px; height: 40px;">
                            <i class="fas fa-camera"></i>
                        </button>
                    </div>
                    
                    <h3 class="h5 fw-bold mb-1">{{ $user->name }}</h3>
                    <p class="text-muted mb-3">{{ $user->email }}</p>
                    
                    <!-- Remove Avatar Form -->
                    @if($user->avatar)
                    <form action="{{ route('frontend.profile.avatar.remove') }}" method="POST" class="d-inline">
                        @csrf
                        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill" onclick="return confirm('Are you sure you want to remove your profile picture?')">
                            <i class="fas fa-trash me-1"></i>Remove Photo
                        </button>
                    </form>
                    @endif
                </div>
            </div>
            
            <div class="card shadow-sm border-0 mt-4">
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        <a href="#profile-details" class="list-group-item list-group-item-action active">
                            <i class="fas fa-user me-2"></i>Profile Details
                        </a>
                        <a href="#change-password" class="list-group-item list-group-item-action">
                            <i class="fas fa-key me-2"></i>Change Password
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Profile Content -->
        <div class="col-lg-8">
            <!-- Profile Details Section -->
            <div class="card shadow-sm border-0 mb-4" id="profile-details">
                <div class="card-header bg-white border-0">
                    <h3 class="h5 mb-0 fw-bold heading-text">Profile Details</h3>
                </div>
                <div class="card-body">
                    <form action="{{ route('frontend.profile.update') }}" method="POST">
                        @csrf
                        @method('POST')
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="name" class="form-label fw-medium label-text">Full Name <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="name" name="name" value="{{ old('name', $user->name) }}" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label fw-medium label-text">Email Address <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" id="email" name="email" value="{{ old('email', $user->email) }}" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="mobile_number" class="form-label fw-medium label-text">Mobile Number</label>
                                <input type="text" class="form-control" id="mobile_number" name="mobile_number" value="{{ old('mobile_number', $user->mobile_number) }}">
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="date_of_birth" class="form-label fw-medium label-text">Date of Birth</label>
                                <input type="date" class="form-control" id="date_of_birth" name="date_of_birth" value="{{ old('date_of_birth', $user->date_of_birth ? $user->date_of_birth->format('Y-m-d') : '') }}">
                            </div>
                            
                            <div class="col-12 mb-3">
                                <label for="address" class="form-label fw-medium label-text">Address</label>
                                <textarea class="form-control" id="address" name="address" rows="3">{{ old('address', $user->address) }}</textarea>
                            </div>
                        </div>
                        
                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn btn-theme rounded-pill px-4">
                                <i class="fas fa-save me-2"></i>Update Profile
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Change Password Section -->
            <div class="card shadow-sm border-0" id="change-password">
                <div class="card-header bg-white border-0">
                    <h3 class="h5 mb-0 fw-bold heading-text">Change Password</h3>
                </div>
                <div class="card-body">
                    <form action="{{ route('frontend.profile.password.change') }}" method="POST">
                        @csrf
                        @method('POST')
                        
                        <div class="row">
                            <div class="col-12 mb-3">
                                <label for="current_password" class="form-label fw-medium label-text">Current Password <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="current_password" name="current_password" required>
                                    <button class="btn btn-outline-theme toggle-password" type="button" data-target="current_password">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="password" class="form-label fw-medium label-text">New Password <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="password" name="password" required>
                                    <button class="btn btn-outline-theme toggle-password" type="button" data-target="password">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                                <div class="form-text">Password must be at least 8 characters long.</div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="password_confirmation" class="form-label fw-medium label-text">Confirm New Password <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="password_confirmation" name="password_confirmation" required>
                                    <button class="btn btn-outline-theme toggle-password" type="button" data-target="password_confirmation">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn btn-theme rounded-pill px-4">
                                <i class="fas fa-key me-2"></i>Change Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .list-group-item.active {
        background-color: {{ setting('theme_color', '#007bff') }} !important;
        border-color: {{ setting('theme_color', '#007bff') }} !important;
    }
    
    .btn-theme {
        background-color: {{ setting('theme_color', '#007bff') }} !important;
        border-color: {{ setting('theme_color', '#007bff') }} !important;
        color: white !important;
    }
    
    .btn-theme:hover {
        background-color: {{ setting('link_hover_color', '#0056b3') }} !important;
        border-color: {{ setting('link_hover_color', '#0056b3') }} !important;
    }
    
    .btn-outline-theme {
        border-color: {{ setting('theme_color', '#007bff') }} !important;
        color: {{ setting('theme_color', '#007bff') }} !important;
    }
    
    .btn-outline-theme:hover {
        background-color: {{ setting('theme_color', '#007bff') }} !important;
        border-color: {{ setting('theme_color', '#007bff') }} !important;
        color: white !important;
    }
    
    .toggle-password:focus {
        box-shadow: none !important;
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Handle avatar change
        const changeAvatarBtn = document.getElementById('change-avatar-btn');
        const avatarInput = document.getElementById('avatar-input');
        const avatarForm = document.getElementById('avatar-form');
        
        if (changeAvatarBtn && avatarInput) {
            changeAvatarBtn.addEventListener('click', function() {
                avatarInput.click();
            });
            
            avatarInput.addEventListener('change', function() {
                if (this.files && this.files[0]) {
                    // Validate file type
                    const file = this.files[0];
                    const fileType = file.type;
                    const validTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/gif'];
                    
                    if (!validTypes.includes(fileType)) {
                        alert('Please select a valid image file (JPEG, PNG, JPG, GIF).');
                        return;
                    }
                    
                    // Validate file size (2MB max)
                    const fileSize = file.size / 1024 / 1024; // in MB
                    if (fileSize > 2) {
                        alert('File size exceeds 2MB. Please select a smaller file.');
                        return;
                    }
                    
                    // Submit form
                    avatarForm.submit();
                }
            });
        }
        
        // Password visibility toggle functionality
        const togglePasswordButtons = document.querySelectorAll('.toggle-password');
        togglePasswordButtons.forEach(function(button) {
            button.addEventListener('click', function() {
                const targetId = this.getAttribute('data-target');
                const passwordInput = document.getElementById(targetId);
                const icon = this.querySelector('i');
                
                if (passwordInput.type === 'password') {
                    passwordInput.type = 'text';
                    icon.classList.remove('fa-eye');
                    icon.classList.add('fa-eye-slash');
                } else {
                    passwordInput.type = 'password';
                    icon.classList.remove('fa-eye-slash');
                    icon.classList.add('fa-eye');
                }
            });
        });
        
        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                
                const targetId = this.getAttribute('href');
                const targetElement = document.querySelector(targetId);
                
                if (targetElement) {
                    // Update active state in sidebar
                    document.querySelectorAll('.list-group-item').forEach(item => {
                        item.classList.remove('active');
                    });
                    this.classList.add('active');
                    
                    // Scroll to target element
                    targetElement.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
        
        // Handle section visibility based on URL hash
        function handleSectionVisibility() {
            const hash = window.location.hash;
            if (hash) {
                // Remove active class from all items
                document.querySelectorAll('.list-group-item').forEach(item => {
                    item.classList.remove('active');
                });
                
                // Add active class to clicked item
                const activeLink = document.querySelector(`a[href="${hash}"]`);
                if (activeLink) {
                    activeLink.classList.add('active');
                }
                
                // Scroll to target element
                const targetElement = document.querySelector(hash);
                if (targetElement) {
                    targetElement.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            }
        }
        
        // Call on page load
        handleSectionVisibility();
        
        // Call on hash change
        window.addEventListener('hashchange', handleSectionVisibility);
    });
</script>
@endsection