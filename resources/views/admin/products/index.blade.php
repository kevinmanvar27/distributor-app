@extends('admin.layouts.app')

@section('title', 'Products')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Product Management'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
                                <div>
                                    <h4 class="card-title mb-0 fw-bold">Product Management</h4>
                                    <p class="mb-0 text-muted">Manage all products</p>
                                </div>
                                @can('create', App\Models\Product::class)
                                <a href="{{ route('admin.products.create') }}" class="btn btn-primary rounded-pill px-4">
                                    <i class="fas fa-plus me-2"></i> Add New Product
                                </a>
                                @endcan
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>ID</th>
                                                <th>Product</th>
                                                <th>MRP</th>
                                                <th>Selling Price</th>
                                                <th>Stock Status</th>
                                                <th>Status</th>
                                                <th>Created</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @forelse($products as $product)
                                                <tr>
                                                    <td class="fw-bold">{{ $product->id }}</td>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            @if($product->mainPhoto)
                                                                <img src="{{ $product->mainPhoto->url }}" 
                                                                     class="rounded me-3" width="40" height="40" alt="{{ $product->name }}">
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
                                                    <td>₹{{ number_format($product->mrp, 2) }}</td>
                                                    <td>₹{{ number_format($product->selling_price ?? 0, 2) }}</td>
                                                    <td>
                                                        @if($product->in_stock)
                                                            <span class="badge bg-success-subtle text-success-emphasis rounded-pill px-3 py-2">
                                                                In Stock ({{ $product->stock_quantity }})
                                                            </span>
                                                        @else
                                                            <span class="badge bg-danger-subtle text-danger-emphasis rounded-pill px-3 py-2">
                                                                Out of Stock
                                                            </span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        @if($product->status === 'published')
                                                            <span class="badge bg-primary-subtle text-primary-emphasis rounded-pill px-3 py-2">
                                                                Published
                                                            </span>
                                                        @else
                                                            <span class="badge bg-secondary-subtle text-secondary-emphasis rounded-pill px-3 py-2">
                                                                Draft
                                                            </span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        @if($product->created_at)
                                                            <span class="text-muted" data-bs-toggle="tooltip" data-bs-title="{{ $product->created_at->format('F j, Y \a\t g:i A') }}">
                                                                {{ $product->created_at->diffForHumans() }}
                                                            </span>
                                                        @else
                                                            <span class="text-muted">N/A</span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        <div class="btn-group btn-group-sm" role="group">
                                                            @can('update', $product)
                                                            <a href="{{ route('admin.products.edit', $product) }}" class="btn btn-outline-primary rounded-start-pill px-3">
                                                                <i class="fas fa-edit"></i>
                                                            </a>
                                                            @endcan
                                                            @can('view', $product)
                                                            <a href="{{ route('admin.products.show', $product) }}" class="btn btn-outline-info px-3">
                                                                <i class="fas fa-eye"></i>
                                                            </a>
                                                            @endcan
                                                            @can('delete', $product)
                                                            <form action="{{ route('admin.products.destroy', $product) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this product? This action cannot be undone.');">
                                                                @csrf
                                                                @method('DELETE')
                                                                <button type="submit" class="btn btn-outline-danger rounded-end-pill px-3">
                                                                    <i class="fas fa-trash"></i>
                                                                </button>
                                                            </form>
                                                            @endcan
                                                        </div>
                                                    </td>
                                                </tr>
                                            @empty
                                                <tr>
                                                    <td colspan="8" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <i class="fas fa-box-open fa-2x mb-3"></i>
                                                            <p class="mb-0">No products found</p>
                                                            <p class="small">Try creating a new product</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endforelse
                                        </tbody>
                                    </table>
                                </div>
                                
                                @if($products->hasPages())
                                    <div class="d-flex justify-content-center mt-4">
                                        {{ $products->links() }}
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>
@endsection