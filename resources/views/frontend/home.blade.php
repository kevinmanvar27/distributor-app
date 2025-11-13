@extends('frontend.layouts.app')

@section('title', 'Home - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="card shadow-sm border-0 mt-5">
                <div class="card-body text-center py-5">
                    <h1 class="display-4 fw-bold mb-4 heading-text" style="color: {{ setting('theme_color', '#007bff') }};">
                        Home Page
                    </h1>
                    <p class="lead mb-4 general-text">
                        @auth
                            Welcome to the frontend application, {{ Auth::user()->name }}!
                        @else
                            Welcome to the frontend application!
                        @endauth
                    </p>
                    @auth
                    <div class="d-flex justify-content-center gap-3">
                        <form method="POST" action="{{ route('frontend.logout') }}">
                            @csrf
                            <button type="submit" class="btn btn-theme rounded-pill px-4">
                                <i class="fas fa-sign-out-alt me-2"></i>Logout
                            </button>
                        </form>
                    </div>
                    @endauth
                </div>
            </div>
        </div>
    </div>
    
    <!-- Categories Section -->
    <div class="row mt-5">
        <div class="col-12">
            <h2 class="mb-4 heading-text" style="color: {{ setting('theme_color', '#007bff') }};">Categories</h2>
        </div>
        
        @foreach($categories as $category)
        <div class="col-md-4 col-lg-3 mb-4">
            <div class="card h-100 shadow-sm">
                @if($category->image)
                    <img src="{{ $category->image->url }}" class="card-img-top" alt="{{ $category->name }}" style="height: 200px; object-fit: cover;">
                @else
                    <div class="bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                        <i class="fas fa-image fa-3x text-muted"></i>
                    </div>
                @endif
                <div class="card-body d-flex flex-column">
                    <h5 class="card-title">{{ $category->name }}</h5>
                    <p class="card-text flex-grow-1">{{ $category->description ?? 'No description available' }}</p>
                </div>
            </div>
        </div>
        @endforeach
    </div>
    
    <!-- Products Section -->
    <div class="row mt-5">
        <div class="col-12">
            <h2 class="mb-4 heading-text" style="color: {{ setting('theme_color', '#007bff') }};">Products</h2>
        </div>
        
        @foreach($products as $product)
        <div class="col-md-4 col-lg-3 mb-4">
            <div class="card h-100 shadow-sm">
                @if($product->mainPhoto)
                    <img src="{{ $product->mainPhoto->url }}" class="card-img-top" alt="{{ $product->name }}" style="height: 200px; object-fit: cover;">
                @else
                    <div class="bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                        <i class="fas fa-image fa-3x text-muted"></i>
                    </div>
                @endif
                <div class="card-body d-flex flex-column">
                    <h5 class="card-title">{{ $product->name }}</h5>
                    <p class="card-text flex-grow-1">{{ $product->description ?? 'No description available' }}</p>
                    <div class="mt-auto">
                        <p class="fw-bold text-success">₹{{ $product->selling_price }}</p>
                        <a href="#" class="btn btn-theme w-100">Buy Now</a>
                    </div>
                </div>
            </div>
        </div>
        @endforeach
    </div>
</div>
@endsection