@extends('frontend.layouts.app')

@section('title', 'All Pages')

@section('content')
<div class="container my-5">
    <div class="row">
        <div class="col-12">
            <h1 class="mb-4">All Pages</h1>
            
            @if($pages->count() > 0)
                <div class="list-group">
                    @foreach($pages as $page)
                        <a href="{{ route('frontend.page.show', $page->slug) }}" class="list-group-item list-group-item-action">
                            <div class="d-flex w-100 justify-content-between">
                                <h5 class="mb-1">{{ $page->title }}</h5>
                            </div>
                            <small class="text-muted">{{ Str::limit(strip_tags($page->content), 100) }}</small>
                        </a>
                    @endforeach
                </div>
            @else
                <div class="alert alert-info">
                    <p>No pages available at the moment.</p>
                </div>
            @endif
        </div>
    </div>
</div>
@endsection