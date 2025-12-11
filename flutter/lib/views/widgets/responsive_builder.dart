import 'package:flutter/material.dart';

/// Screen size breakpoints
class ScreenBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop }

/// Responsive Builder Widget
/// Builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= ScreenBreakpoints.mobile) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= ScreenBreakpoints.desktop) {
      return DeviceType.desktop;
    }
    if (width >= ScreenBreakpoints.mobile) {
      return DeviceType.tablet;
    }
    return DeviceType.mobile;
  }

  /// Check if mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ScreenBreakpoints.mobile;
  }

  /// Check if tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ScreenBreakpoints.mobile && width < ScreenBreakpoints.desktop;
  }

  /// Check if desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ScreenBreakpoints.desktop;
  }
}

/// Responsive Value
/// Returns different values based on screen size
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T get(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// Responsive Grid
/// Creates a grid with responsive column count
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveValue<int>(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    ).get(context);

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive Padding
/// Applies different padding based on screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveValue<EdgeInsetsGeometry>(
      mobile: mobilePadding,
      tablet: tabletPadding,
      desktop: desktopPadding,
    ).get(context);

    return Padding(padding: padding, child: child);
  }
}

/// Responsive Constraint
/// Constrains width based on screen size
class ResponsiveConstraint extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveConstraint({
    super.key,
    required this.child,
    this.maxWidth,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    if (maxWidth == null) return child;

    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: child,
    );

    if (centerContent) {
      return Center(child: constrained);
    }

    return constrained;
  }
}

/// Responsive Row/Column
/// Switches between Row and Column based on screen size
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final bool rowWhenWide;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.rowWhenWide = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveBuilder.isMobile(context);
    final useRow = rowWhenWide ? isWide : !isWide;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(
          width: useRow ? spacing : 0,
          height: useRow ? 0 : spacing,
        ));
      }
    }

    if (useRow) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: spacedChildren,
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}
