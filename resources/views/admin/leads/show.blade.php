@extends('admin.layouts.app')

@section('title', 'View Lead')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'View Lead'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-2 gap-md-0">
                                    <div>
                                        <h4 class="card-title mb-0 fw-bold">Lead Details</h4>
                                        <p class="mb-0 text-muted">View lead information</p>
                                    </div>
                                    <div class="d-flex flex-wrap gap-2">
                                        <a href="{{ route('admin.leads.index') }}" class="btn btn-sm btn-md-normal btn-outline-secondary rounded-pill px-3 px-md-4">
                                            <i class="fas fa-arrow-left me-1 me-md-2"></i><span class="d-none d-sm-inline">Back to Leads</span><span class="d-sm-none">Back</span>
                                        </a>
                                        @if(auth()->user()->hasPermission('update_lead'))
                                            <a href="{{ route('admin.leads.edit', $lead) }}" class="btn btn-sm btn-md-normal btn-theme rounded-pill px-3 px-md-4">
                                                <i class="fas fa-edit me-1 me-md-2"></i><span class="d-none d-sm-inline">Edit Lead</span><span class="d-sm-none">Edit</span>
                                            </a>
                                        @endif
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="mb-4">
                                            <h5 class="fw-bold mb-3">Basic Information</h5>
                                            
                                            <div class="mb-3">
                                                <label class="form-label text-muted small mb-1">Name</label>
                                                <p class="fw-medium">{{ $lead->name }}</p>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label text-muted small mb-1">Contact Number</label>
                                                <p class="fw-medium">{{ $lead->contact_number }}</p>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label text-muted small mb-1">Status</label>
                                                <div>
                                                    <span class="badge {{ $lead->status_badge_class }} rounded-pill px-3 py-2">
                                                        {{ $lead->status_label }}
                                                    </span>
                                                </div>
                                            </div>
                                            
                                            @if($lead->note)
                                                <div class="mb-3">
                                                    <label class="form-label text-muted small mb-1">Note</label>
                                                    <p class="text-muted">{{ $lead->note }}</p>
                                                </div>
                                            @endif
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-4">
                                        <div class="card border rounded-3">
                                            <div class="card-header bg-light py-2">
                                                <h6 class="mb-0">Lead Information</h6>
                                            </div>
                                            <div class="card-body">
                                                <div class="mb-3">
                                                    <label class="form-label text-muted small mb-1">Created At</label>
                                                    <p class="mb-0">{{ $lead->created_at->format('M d, Y h:i A') }}</p>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label text-muted small mb-1">Last Updated</label>
                                                    <p class="mb-0">{{ $lead->updated_at->format('M d, Y h:i A') }}</p>
                                                </div>
                                                @if($lead->deleted_at)
                                                    <div class="mb-3">
                                                        <label class="form-label text-muted small mb-1">Deleted At</label>
                                                        <p class="mb-0 text-danger">{{ $lead->deleted_at->format('M d, Y h:i A') }}</p>
                                                    </div>
                                                @endif
                                            </div>
                                        </div>
                                        
                                        @if(auth()->user()->hasPermission('delete_lead'))
                                            <div class="card border border-danger rounded-3 mt-3">
                                                <div class="card-header bg-danger-subtle py-2">
                                                    <h6 class="mb-0 text-danger">Danger Zone</h6>
                                                </div>
                                                <div class="card-body">
                                                    <p class="small text-muted mb-3">Once you delete this lead, it will be moved to trash.</p>
                                                    <form action="{{ route('admin.leads.destroy', $lead) }}" method="POST">
                                                        @csrf
                                                        @method('DELETE')
                                                        <button type="submit" class="btn btn-danger w-100 rounded-pill" onclick="return confirm('Are you sure you want to delete this lead?')">
                                                            <i class="fas fa-trash me-2"></i>Delete Lead
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        @endif
                                    </div>
                                </div>
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
