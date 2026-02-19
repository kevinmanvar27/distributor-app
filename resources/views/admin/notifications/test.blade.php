@extends('admin.layouts.app')

@section('title', 'Firebase Test - ' . config('app.name', 'Laravel'))

@section('content')
<div class="container-fluid py-4">
    <div class="row">
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-vial me-2"></i>Firebase Configuration Test</h5>
                </div>
                <div class="card-body">
                    {{-- Firebase Configuration Status --}}
                    <div class="row mb-4">
                        <div class="col-md-12">
                            <h6 class="text-muted mb-3">Configuration Status</h6>
                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Setting</th>
                                            <th>Status</th>
                                            <th>Value</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><strong>Firebase Project ID</strong></td>
                                            <td>
                                                @if(setting('firebase_project_id'))
                                                    <span class="badge bg-success"><i class="fas fa-check"></i> Configured</span>
                                                @else
                                                    <span class="badge bg-danger"><i class="fas fa-times"></i> Missing</span>
                                                @endif
                                            </td>
                                            <td><code>{{ setting('firebase_project_id') ?: 'Not set' }}</code></td>
                                        </tr>
                                        <tr>
                                            <td><strong>Firebase Client Email</strong></td>
                                            <td>
                                                @if(setting('firebase_client_email'))
                                                    <span class="badge bg-success"><i class="fas fa-check"></i> Configured</span>
                                                @else
                                                    <span class="badge bg-danger"><i class="fas fa-times"></i> Missing</span>
                                                @endif
                                            </td>
                                            <td><code>{{ setting('firebase_client_email') ?: 'Not set' }}</code></td>
                                        </tr>
                                        <tr>
                                            <td><strong>Firebase Private Key</strong></td>
                                            <td>
                                                @if(setting('firebase_private_key'))
                                                    <span class="badge bg-success"><i class="fas fa-check"></i> Configured</span>
                                                @else
                                                    <span class="badge bg-danger"><i class="fas fa-times"></i> Missing</span>
                                                @endif
                                            </td>
                                            <td>
                                                @if(setting('firebase_private_key'))
                                                    <code>{{ substr(setting('firebase_private_key'), 0, 50) }}...</code>
                                                @else
                                                    <code>Not set</code>
                                                @endif
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    {{-- Overall Status --}}
                    <div class="row mb-4">
                        <div class="col-md-12">
                            @php
                                $isConfigured = setting('firebase_project_id') && 
                                               setting('firebase_client_email') && 
                                               setting('firebase_private_key');
                            @endphp
                            
                            @if($isConfigured)
                                <div class="alert-theme alert-success">
                                    <i class="fas fa-check-circle me-2"></i>
                                    <strong>Firebase is properly configured!</strong> You can now send push notifications.
                                </div>
                            @else
                                <div class="alert-theme alert-warning">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    <strong>Firebase is not fully configured.</strong> Please configure the missing settings in the database.
                                </div>
                            @endif
                        </div>
                    </div>

                    {{-- Test Notification Form --}}
                    @if($isConfigured)
                    <div class="row">
                        <div class="col-md-12">
                            <h6 class="text-muted mb-3">Send Test Notification</h6>
                            <form id="testNotificationForm">
                                @csrf
                                <div class="mb-3">
                                    <label for="device_token" class="form-label">Device Token</label>
                                    <input type="text" class="form-control" id="device_token" name="device_token" 
                                           placeholder="Enter FCM device token" required>
                                    <small class="form-text text-muted">
                                        Enter a valid FCM device token to test push notifications
                                    </small>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="title" class="form-label">Title</label>
                                    <input type="text" class="form-control" id="title" name="title" 
                                           value="Test Notification" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="body" class="form-label">Body</label>
                                    <textarea class="form-control" id="body" name="body" rows="3" required>This is a test notification from your admin panel.</textarea>
                                </div>
                                
                                <button type="submit" class="btn btn-primary" id="sendTestBtn">
                                    <i class="fas fa-paper-plane me-2"></i>Send Test Notification
                                </button>
                            </form>
                            
                            <div id="testResult" class="mt-3" style="display: none;"></div>
                        </div>
                    </div>
                    @endif

                    {{-- Configuration Instructions --}}
                    @if(!$isConfigured)
                    <div class="row">
                        <div class="col-md-12">
                            <h6 class="text-muted mb-3">Configuration Instructions</h6>
                            <div class="alert-theme alert-info">
                                <h6><i class="fas fa-info-circle me-2"></i>How to Configure Firebase:</h6>
                                <ol class="mb-0">
                                    <li>Go to <a href="https://console.firebase.google.com" target="_blank">Firebase Console</a></li>
                                    <li>Select your project → Project Settings → Service Accounts</li>
                                    <li>Click "Generate New Private Key" and download the JSON file</li>
                                    <li>Insert the following values into your <code>settings</code> table:
                                        <ul>
                                            <li><code>firebase_project_id</code> → project_id from JSON</li>
                                            <li><code>firebase_client_email</code> → client_email from JSON</li>
                                            <li><code>firebase_private_key</code> → private_key from JSON</li>
                                        </ul>
                                    </li>
                                </ol>
                                
                                <h6 class="mt-3">SQL Example:</h6>
                                <pre class="bg-dark text-white p-3 rounded"><code>INSERT INTO settings (key, value, type, created_at, updated_at) VALUES
('firebase_project_id', 'your-project-id', 'text', NOW(), NOW()),
('firebase_client_email', 'your-service-account-email', 'text', NOW(), NOW()),
('firebase_private_key', 'your-private-key', 'textarea', NOW(), NOW())
ON DUPLICATE KEY UPDATE value = VALUES(value), updated_at = NOW();</code></pre>
                            </div>
                        </div>
                    </div>
                    @endif

                    {{-- Database Statistics --}}
                    <div class="row mt-4">
                        <div class="col-md-12">
                            <h6 class="text-muted mb-3">Database Statistics</h6>
                            <div class="row">
                                <div class="col-md-3">
                                    <div class="card bg-primary text-white">
                                        <div class="card-body text-center">
                                            <h3>{{ \App\Models\User::whereNotNull('device_token')->count() }}</h3>
                                            <small>Users with Device Tokens</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card bg-success text-white">
                                        <div class="card-body text-center">
                                            <h3>{{ \App\Models\ScheduledNotification::where('status', 'pending')->count() }}</h3>
                                            <small>Pending Scheduled</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card bg-info text-white">
                                        <div class="card-body text-center">
                                            <h3>{{ \App\Models\ScheduledNotification::where('status', 'sent')->count() }}</h3>
                                            <small>Sent Scheduled</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card bg-warning text-white">
                                        <div class="card-body text-center">
                                            <h3>{{ \App\Models\Notification::count() }}</h3>
                                            <small>Total Notifications</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Quick Links --}}
                    <div class="row mt-4">
                        <div class="col-md-12">
                            <h6 class="text-muted mb-3">Quick Links</h6>
                            <a href="{{ route('admin.firebase.notifications') }}" class="btn btn-outline-primary me-2">
                                <i class="fas fa-bell me-2"></i>Send Notifications
                            </a>
                            <a href="{{ route('admin.settings') }}" class="btn btn-outline-secondary">
                                <i class="fas fa-cog me-2"></i>Settings
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@if($isConfigured)
<script>
document.getElementById('testNotificationForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const btn = document.getElementById('sendTestBtn');
    const resultDiv = document.getElementById('testResult');
    const originalBtnText = btn.innerHTML;
    
    // Show loading state
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Sending...';
    resultDiv.style.display = 'none';
    
    try {
        const formData = new FormData(this);
        const response = await fetch('{{ route("admin.firebase.notifications.test") }}', {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('input[name="_token"]').value,
                'Accept': 'application/json'
            },
            body: formData
        });
        
        const data = await response.json();
        
        // Show result
        resultDiv.style.display = 'block';
        if (data.success) {
            resultDiv.innerHTML = `
                <div class="alert-theme alert-success">
                    <i class="fas fa-check-circle me-2"></i>
                    <strong>Success!</strong> ${data.message}
                </div>
            `;
        } else {
            resultDiv.innerHTML = `
                <div class="alert-theme alert-danger">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    <strong>Error!</strong> ${data.message}
                </div>
            `;
        }
    } catch (error) {
        resultDiv.style.display = 'block';
        resultDiv.innerHTML = `
            <div class="alert-theme alert-danger">
                <i class="fas fa-exclamation-circle me-2"></i>
                <strong>Error!</strong> ${error.message}
            </div>
        `;
    } finally {
        // Reset button
        btn.disabled = false;
        btn.innerHTML = originalBtnText;
    }
});
</script>
@endif
@endsection
