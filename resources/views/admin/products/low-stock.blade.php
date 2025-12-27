@extends('admin.layouts.app')

@section('title', 'Low Stock Products')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Low Stock Products'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
                                <div>
                                    <h4 class="card-title mb-0 fw-bold">
                                        <i class="fas fa-exclamation-triangle text-warning me-2"></i>
                                        Low Stock Products
                                    </h4>
                                    <p class="mb-0 text-muted">Products with stock quantity below their threshold</p>
                                </div>
                                <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary rounded-pill px-4">
                                    <i class="fas fa-arrow-left me-2"></i> Back to Products
                                </a>
                            </div>
                            
                            <div class="card-body">
                                @if($products->isEmpty())
                                    <div class="text-center py-5">
                                        <i class="fas fa-check-circle text-success fa-4x mb-3"></i>
                                        <h5 class="text-muted">All products have sufficient stock!</h5>
                                        <p class="text-muted">No products are currently below their low stock threshold.</p>
                                    </div>
                                @else
                                    <div class="alert alert-warning rounded-3 mb-4">
                                        <i class="fas fa-bell me-2"></i>
                                        <strong>{{ $products->total() }} product(s)</strong> have stock levels below their threshold. Consider restocking soon!
                                    </div>
                                    
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Product</th>
                                                    <th>Current Stock</th>
                                                    <th>Threshold</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                @foreach($products as $product)
                                                    <tr>
                                                        <td class="fw-bold">{{ $product->id }}</td>
                                                        <td>
                                                            <div class="d-flex align-items-center">
                                                                @if($product->mainPhoto)
                                                                    <img src="{{ $product->mainPhoto->url }}" 
                                                                         class="rounded me-3" width="40" height="40" alt="{{ $product->name }}" 
                                                                         loading="lazy">
                                                                @else
                                                                    <div class="bg-light rounded me-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                                                        <i class="fas fa-image text-muted"></i>
                                                                    </div>
                                                                @endif
                                                                <div>
                                                                    <div class="fw-medium">{{ $product->name }}</div>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-danger-subtle text-danger-emphasis rounded-pill px-3 py-2 fs-6">
                                                                {{ $product->stock_quantity }}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-secondary-subtle text-secondary-emphasis rounded-pill px-3 py-2">
                                                                {{ $product->low_quantity_threshold }}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            @php
                                                                $percentage = $product->low_quantity_threshold > 0 
                                                                    ? ($product->stock_quantity / $product->low_quantity_threshold) * 100 
                                                                    : 0;
                                                            @endphp
                                                            <div class="progress" style="height: 8px; width: 100px;">
                                                                <div class="progress-bar {{ $percentage < 50 ? 'bg-danger' : 'bg-warning' }}" 
                                                                     role="progressbar" 
                                                                     style="width: {{ min($percentage, 100) }}%">
                                                                </div>
                                                            </div>
                                                            <small class="text-muted">{{ round($percentage) }}% of threshold</small>
                                                        </td>
                                                        <td>
                                                            @can('update', $product)
                                                            <a href="{{ route('admin.products.edit', $product) }}" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                                                                <i class="fas fa-edit me-1"></i> Update Stock
                                                            </a>
                                                            @endcan
                                                        </td>
                                                    </tr>
                                                @endforeach
                                            </tbody>
                                        </table>
                                    </div>
                                    
                                    <div class="d-flex justify-content-center mt-4">
                                        {{ $products->links() }}
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>
@endsection
