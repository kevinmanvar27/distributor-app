// Admin Dashboard Scripts

document.addEventListener('DOMContentLoaded', function() {
    // Initialize Bootstrap tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Sidebar toggle functionality
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebar-toggle');
    
    if (sidebar && sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('collapsed');
        });
    }
    
    // Theme switching functionality
    const themeToggle = document.getElementById('theme-toggle');
    const themeIcon = document.getElementById('theme-icon');
    
    // Check for saved theme preference in localStorage or default to light theme
    // Also check for server-side theme setting
    const serverTheme = document.documentElement.getAttribute('data-theme');
    const localStorageTheme = localStorage.getItem('theme');
    
    // Determine the current theme (priority: localStorage > server > default)
    let currentTheme = 'light';
    if (localStorageTheme) {
        currentTheme = localStorageTheme;
    } else if (serverTheme) {
        currentTheme = serverTheme;
    }
    
    // Apply the current theme
    if (currentTheme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
        themeIcon.classList.remove('fa-moon');
        themeIcon.classList.add('fa-sun');
    } else {
        document.documentElement.removeAttribute('data-theme');
        themeIcon.classList.remove('fa-sun');
        themeIcon.classList.add('fa-moon');
    }
    
    // Toggle theme when button is clicked
    if (themeToggle) {
        themeToggle.addEventListener('click', function() {
            const currentTheme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
            
            if (currentTheme === 'dark') {
                // Switch to light theme
                document.documentElement.removeAttribute('data-theme');
                localStorage.setItem('theme', 'light');
                themeIcon.classList.remove('fa-sun');
                themeIcon.classList.add('fa-moon');
                
                // Update server session
                updateServerTheme('light');
            } else {
                // Switch to dark theme
                document.documentElement.setAttribute('data-theme', 'dark');
                localStorage.setItem('theme', 'dark');
                themeIcon.classList.remove('fa-moon');
                themeIcon.classList.add('fa-sun');
                
                // Update server session
                updateServerTheme('dark');
            }
            
            // Dispatch a custom event for theme change
            document.dispatchEvent(new CustomEvent('themeChanged', { detail: currentTheme === 'dark' ? 'light' : 'dark' }));
        });
    }
    
    // Function to update server session with theme preference
    function updateServerTheme(theme) {
        // Get CSRF token from meta tag
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        
        fetch('/admin/theme/switch', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': csrfToken
            },
            body: JSON.stringify({ theme: theme })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Theme updated on server:', data);
        })
        .catch(error => {
            console.error('Error updating theme on server:', error);
        });
    }
    
    // Add active class to current nav item
    const navLinks = document.querySelectorAll('.nav-link');
    const currentPath = window.location.pathname;
    
    navLinks.forEach(link => {
        if (link.getAttribute('href') === currentPath) {
            link.classList.add('active');
        }
    });
    
    // Add any other common admin functionality here
    console.log('Admin dashboard scripts loaded');
});