// Dynamic Bottom Navigation Widget
// 
// A reusable bottom navigation bar with:
// - Badge support for cart count
// - Customizable items
// - Animated transitions
// - Responsive (hides on tablet/desktop)
// 
// TODO: Customize colors in AppTheme

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final int? badgeCount;
  
  const NavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
  });
}

class DynamicBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double elevation;
  final bool showLabels;
  
  const DynamicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.elevation = 8,
    this.showLabels = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              
              return _NavItemWidget(
                item: item,
                isSelected: isSelected,
                selectedColor: selectedColor ?? AppTheme.primaryColor,
                unselectedColor: unselectedColor ?? AppTheme.textSecondary,
                showLabel: showLabels,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final VoidCallback onTap;
  
  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: _Badge(count: item.badgeCount!),
                  ),
              ],
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(item.label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  
  const _Badge({required this.count});
  
  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Navigation Drawer for tablet/desktop
class DynamicNavigationDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final String? headerTitle;
  final String? headerSubtitle;
  final Widget? headerImage;
  final Widget? header;
  
  const DynamicNavigationDrawer({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.headerTitle,
    this.headerSubtitle,
    this.headerImage,
    this.header,
  });
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Custom header takes priority
          if (header != null)
            header!
          else if (headerTitle != null || headerImage != null)
            UserAccountsDrawerHeader(
              accountName: headerTitle != null 
                  ? Text(headerTitle!) 
                  : null,
              accountEmail: headerSubtitle != null 
                  ? Text(headerSubtitle!) 
                  : null,
              currentAccountPicture: headerImage,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == currentIndex;
                
                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textSecondary,
                      ),
                      if (item.badgeCount != null && item.badgeCount! > 0)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: _Badge(count: item.badgeCount!),
                        ),
                    ],
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.pop(context);
                    onTap(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation Rail for desktop
class DynamicNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final bool extended;
  final Widget? leading;
  final Widget? trailing;
  
  const DynamicNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.extended = false,
    this.leading,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      extended: extended,
      leading: leading,
      trailing: trailing,
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: AppTheme.primaryColor),
      selectedLabelTextStyle: const TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w600,
      ),
      unselectedIconTheme: IconThemeData(color: AppTheme.textSecondary),
      unselectedLabelTextStyle: TextStyle(
        color: AppTheme.textSecondary,
      ),
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: _Badge(count: item.badgeCount!),
                ),
            ],
          ),
          selectedIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.activeIcon ?? item.icon),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: _Badge(count: item.badgeCount!),
                ),
            ],
          ),
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}
