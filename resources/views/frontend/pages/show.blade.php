@extends('frontend.layouts.app')

@section('title', $page->title)

@section('content')
<div class="container my-5">
    <div class="row">
        <div class="col-12">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}">Home</a></li>
                    <li class="breadcrumb-item"><a href="{{ route('frontend.pages.index') }}">Pages</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{ $page->title }}</li>
                </ol>
            </nav>
            
            <h1 class="mb-0">{{ $page->title }}</h1>
            {!! $page->content !!}
        </div>
    </div>
</div>
@endsection