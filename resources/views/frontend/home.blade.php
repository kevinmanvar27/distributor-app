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
</div>
@endsection