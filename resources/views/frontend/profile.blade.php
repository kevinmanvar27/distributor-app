@extends('frontend.layouts.app')

@section('title', 'Profile - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-0">
                    <h2 class="h4 mb-0 fw-bold heading-text">User Profile</h2>
                </div>
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-3 text-center">
                            @if($user->avatar)
                                <img src="{{ asset('storage/' . $user->avatar) }}" alt="{{ $user->name }}" class="img-fluid rounded-circle mb-3" style="width: 120px; height: 120px; object-fit: cover;">
                            @else
                                <div class="bg-theme rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 120px; height: 120px; background-color: {{ setting('theme_color', '#007bff') }};">
                                    <i class="fas fa-user text-white" style="font-size: 3rem;"></i>
                                </div>
                            @endif
                            <h3 class="h5 fw-bold mb-0">{{ $user->name }}</h3>
                            <p class="text-muted mb-0">{{ $user->email }}</p>
                        </div>
                        <div class="col-md-9">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-medium label-text">Full Name</label>
                                    <p class="general-text">{{ $user->name }}</p>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-medium label-text">Email Address</label>
                                    <p class="general-text">{{ $user->email }}</p>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-medium label-text">Mobile Number</label>
                                    <p class="general-text">{{ $user->mobile ?? 'Not provided' }}</p>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-medium label-text">Date of Birth</label>
                                    <p class="general-text">{{ $user->date_of_birth ? date('d M, Y', strtotime($user->date_of_birth)) : 'Not provided' }}</p>
                                </div>
                                <div class="col-md-12 mb-3">
                                    <label class="form-label fw-medium label-text">Address</label>
                                    <p class="general-text">{{ $user->address ?? 'Not provided' }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-end">
                        <a href="{{ route('frontend.home') }}" class="btn btn-theme rounded-pill px-4">
                            <i class="fas fa-arrow-left me-2"></i>Back to Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection