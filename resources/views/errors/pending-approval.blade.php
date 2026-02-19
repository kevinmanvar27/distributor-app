@extends('frontend.layouts.app')

@section('title', 'Account Pending Approval')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Account Pending Approval') }}</div>

                <div class="card-body">
                    <div class="alert-theme p-4" style="background-color: rgba(var(--theme-color-rgb, 255, 107, 0), 0.1); border-left: 4px solid var(--theme-color);">
                        <h4 class="alert-heading mb-3" style="color: var(--heading-text-color);">
                            <i class="fas fa-exclamation-triangle me-2" style="color: var(--theme-color);"></i>
                            {{ __('Account Pending Approval') }}
                        </h4>
                        <p style="color: var(--general-text-color);">{{ $message ?? 'Your account is pending approval. Please wait for admin approval before accessing the site.' }}</p>
                        <hr style="border-color: var(--theme-color); opacity: 0.3;">
                        <p class="mb-0" style="color: var(--general-text-color);">{{ __('If you believe this is an error, please contact the site administrator.') }}</p>
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="{{ route('frontend.logout') }}" class="btn btn-secondary">
                            {{ __('Logout') }}
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection