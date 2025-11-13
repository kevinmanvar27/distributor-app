@extends('frontend.layouts.app')

@section('title', 'Login - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container">
    <div class="row justify-content-center align-items-center min-vh-100">
        <div class="col-md-8 col-lg-6">
            <div class="card shadow-sm border-0">
                <div class="card-body p-5">
                    <div class="text-center mb-5">
                        @if(setting('header_logo'))
                            <img src="{{ asset('storage/' . setting('header_logo')) }}" alt="{{ setting('site_title', 'Frontend App') }}" class="mb-4 rounded" height="60">
                        @else
                            <div class="bg-theme rounded-circle d-flex align-items-center justify-content-center mx-auto mb-4" style="width: 60px; height: 60px; background-color: {{ setting('theme_color', '#007bff') }};">
                                <i class="fas fa-cube text-white"></i>
                            </div>
                        @endif
                        <h1 class="h2 fw-bold heading-text">Welcome to {{ setting('site_title', 'Frontend App') }}</h1>
                        <p class="general-text mb-0">Please sign in to your account</p>
                    </div>
                    
                    @if ($errors->any())
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <strong>Whoops!</strong> Something went wrong.
                            <ul class="mb-0 mt-2">
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    @endif
                    
                    @if (session('error'))
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            {{ session('error') }}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    @endif
                    
                    <form method="POST" action="{{ route('frontend.login') }}">
                        @csrf
                        
                        <div class="mb-4">
                            <label for="email" class="form-label fw-medium label-text">Email Address</label>
                            <input 
                                id="email" 
                                type="email" 
                                class="form-control form-control-lg @error('email') is-invalid @enderror" 
                                name="email" 
                                value="{{ old('email') }}" 
                                required 
                                autocomplete="email" 
                                autofocus 
                                placeholder="Enter your email">
                            
                            @error('email')
                                <div class="invalid-feedback">
                                    {{ $message }}
                                </div>
                            @enderror
                        </div>
                        
                        <div class="mb-4">
                            <label for="password" class="form-label fw-medium label-text">Password</label>
                            <div class="input-group">
                                <input 
                                    id="password" 
                                    type="password" 
                                    class="form-control form-control-lg @error('password') is-invalid @enderror" 
                                    name="password" 
                                    required 
                                    autocomplete="current-password" 
                                    placeholder="Enter your password">
                                <button class="btn btn-outline-secondary toggle-password" type="button" data-target="password">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            
                            @error('password')
                                <div class="invalid-feedback">
                                    {{ $message }}
                                </div>
                            @enderror
                        </div>
                        
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="remember" id="remember" {{ old('remember') ? 'checked' : '' }}>
                                <label class="form-check-label label-text" for="remember">
                                    Remember Me
                                </label>
                            </div>
                        </div>
                        
                        <div class="d-grid">
                            <button type="submit" class="btn btn-theme rounded-pill px-4">
                                Sign In
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            
            <div class="text-center mt-4">
                <p class="general-text mb-0">
                    &copy; {{ date('Y') }} {{ setting('site_title', 'Frontend App') }}. All rights reserved.
                </p>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
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
    });
</script>
@endsection