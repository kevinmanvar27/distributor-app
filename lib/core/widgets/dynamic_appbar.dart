// Dynamic AppBar Widget
// 
// A reusable app bar component with:
// - Customizable title (text or widget)
// - Leading and trailing actions
// - Optional search functionality
// - Transparent/colored variants
// 
// TODO: Customize default colors in AppTheme

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final bool isTransparent;
  
  const DynamicAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.onBackPressed,
    this.bottom,
    this.isTransparent = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final bgColor = isTransparent 
        ? Colors.transparent 
        : (backgroundColor ?? AppTheme.primaryColor);
    final fgColor = foregroundColor ?? 
        (isTransparent ? AppTheme.textPrimary : Colors.white);
    
    return AppBar(
      title: titleWidget ?? (title != null 
          ? Text(
              title!,
              style: TextStyle(
                color: fgColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            )
          : null),
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      leading: leading ?? (showBackButton && canPop
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: fgColor),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null),
      actions: actions,
      bottom: bottom,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// AppBar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final List<Widget>? actions;
  final bool autoFocus;
  
  const SearchAppBar({
    super.key,
    required this.title,
    this.hintText = 'Search...',
    this.onSearch,
    this.onClear,
    this.actions,
    this.autoFocus = false,
  });
  
  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching && widget.autoFocus) {
        _focusNode.requestFocus();
      } else {
        _searchController.clear();
        widget.onClear?.call();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: widget.autoFocus,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onSearch,
            )
          : Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Close search' : 'Search',
        ),
        if (!_isSearching && widget.actions != null) ...widget.actions!,
      ],
    );
  }
}

/// Sliver AppBar variant for scrollable content
class DynamicSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  
  const DynamicSliverAppBar({
    super.key,
    required this.title,
    this.flexibleSpace,
    this.actions,
    this.expandedHeight = 200,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: flexibleSpace,
        centerTitle: true,
      ),
      actions: actions,
    );
  }
}
