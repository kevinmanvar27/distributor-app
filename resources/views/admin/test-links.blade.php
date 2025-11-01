@extends('admin.layouts.app')

@section('content')
<div class="container-fluid">
    <div class="row">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
            @include('admin.layouts.header', ['title' => 'Link Color Test'])
            
            <div class="container mt-4">
                <div class="card">
                    <div class="card-header">
                        <h5>Link Color Test</h5>
                    </div>
                    <div class="card-body">
                        <p>This page tests the link color settings:</p>
                        
                        <ul>
                            <li><a href="#">This is a regular link</a></li>
                            <li><a href="#">This is another link</a></li>
                            <li><a href="#">Hover over these links to see the hover color</a></li>
                        </ul>
                        
                        <p>You can also test with Bootstrap link classes:</p>
                        
                        <ul>
                            <li><a href="#" class="btn btn-link">Button link</a></li>
                            <li><a href="#" class="text-primary">Primary text link</a></li>
                        </ul>
                        
                        <div class="mt-4">
                            <a href="{{ route('admin.settings') }}" class="btn btn-theme">Back to Settings</a>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>
@endsection