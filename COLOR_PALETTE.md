# Color Palette Implementation

This document describes the color palette implementation for the Laravel admin panel.

## Color Scheme

### Light Theme
- **Primary**: `#FF6B00` (Orange) - RGBA: `rgba(255, 107, 0, 1)`
- **Secondary**: `#F5F5F5` (Light Gray) - RGBA: `rgba(245, 245, 245, 1)`
- **Background**: `#FFFFFF` (White) - RGBA: `rgba(255, 255, 255, 1)`
- **Surface**: `#FFFFFF` (White) - RGBA: `rgba(255, 255, 255, 1)`
- **Text**: `#333333` (Dark Gray) - RGBA: `rgba(51, 51, 51, 1)`
- **Text Secondary**: `#757575` (Medium Gray) - RGBA: `rgba(117, 117, 117, 1)`
- **Border**: `#E0E0E0` (Light Gray Border) - RGBA: `rgba(224, 224, 224, 1)`
- **Success**: `#4CAF50` (Green) - RGBA: `rgba(76, 175, 80, 1)`
- **Error**: `#F44336` (Red) - RGBA: `rgba(244, 67, 54, 1)`
- **Warning**: `#FF9800` (Orange) - RGBA: `rgba(255, 152, 0, 1)`

### Dark Theme
- **Primary**: `#FF6B00` (Orange) - RGBA: `rgba(255, 107, 0, 1)`
- **Secondary**: `#2A2A2A` (Dark Gray) - RGBA: `rgba(42, 42, 42, 1)`
- **Background**: `#121212` (Very Dark Gray) - RGBA: `rgba(18, 18, 18, 1)`
- **Surface**: `#1E1E1E` (Dark Gray) - RGBA: `rgba(30, 30, 30, 1)`
- **Text**: `#FFFFFF` (White) - RGBA: `rgba(255, 255, 255, 1)`
- **Text Secondary**: `#B0B0B0` (Light Gray) - RGBA: `rgba(176, 176, 176, 1)`
- **Border**: `#333333` (Dark Gray Border) - RGBA: `rgba(51, 51, 51, 1)`
- **Success**: `#4CAF50` (Green) - RGBA: `rgba(76, 175, 80, 1)`
- **Error**: `#F44336` (Red) - RGBA: `rgba(244, 67, 54, 1)`
- **Warning**: `#FF9800` (Orange) - RGBA: `rgba(255, 152, 0, 1)`

### Grayscale System
- **Gray 50**: `#FAFAFA` (Lightest Gray) - RGBA: `rgba(250, 250, 250, 1)`
- **Gray 100**: `#F5F5F5` - RGBA: `rgba(245, 245, 245, 1)`
- **Gray 200**: `#EEEEEE` - RGBA: `rgba(238, 238, 238, 1)`
- **Gray 300**: `#E0E0E0` - RGBA: `rgba(224, 224, 224, 1)`
- **Gray 400**: `#BDBDBD` - RGBA: `rgba(189, 189, 189, 1)`
- **Gray 500**: `#9E9E9E` - RGBA: `rgba(158, 158, 158, 1)`
- **Gray 600**: `#757575` - RGBA: `rgba(117, 117, 117, 1)`
- **Gray 700**: `#616161` - RGBA: `rgba(97, 97, 97, 1)`
- **Gray 800**: `#424242` - RGBA: `rgba(66, 66, 66, 1)`
- **Gray 900**: `#212121` (Darkest Gray) - RGBA: `rgba(33, 33, 33, 1)`

## Implementation Files

The color palette has been implemented in the following files:

1. **CSS**: [public/assets/css/admin.css](file:///Applications/XAMPP/xamppfiles/htdocs/hardware/public/assets/css/admin.css)
2. **JavaScript**: [public/assets/js/admin.js](file:///Applications/XAMPP/xamppfiles/htdocs/hardware/public/assets/js/admin.js)
3. **Blade Template**: [resources/views/admin/color-palette.blade.php](file:///Applications/XAMPP/xamppfiles/htdocs/hardware/resources/views/admin/color-palette.blade.php)
4. **Routes**: [routes/web.php](file:///Applications/XAMPP/xamppfiles/htdocs/hardware/routes/web.php)
5. **Sidebar**: [resources/views/admin/layouts/sidebar.blade.php](file:///Applications/XAMPP/xamppfiles/htdocs/hardware/resources/views/admin/layouts/sidebar.blade.php)

## Demo

A standalone HTML demo is available at [public/color-palette-demo.html](file:///Applications/XAMPP/xamppfiles/htdocs/hardware/public/color-palette-demo.html)

To view the demo, open the file directly in a browser or access it via:
`http://localhost/hardware/color-palette-demo.html`

## Features

- Full light/dark theme support with toggle switch
- All colors converted to RGBA format as per project specifications
- Consistent color application across UI components
- Theme persistence using localStorage
- Grayscale system for consistent UI hierarchy

## Usage

The color palette is automatically applied throughout the admin panel via CSS variables. To switch between themes, use the theme toggle button in the header.