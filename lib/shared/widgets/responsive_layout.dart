import 'package:flutter/material.dart';

/// Breakpoints for responsive layout.
class Breakpoints {
  Breakpoints._();
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Wraps content with responsive constraints and padding.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxWidth = _maxContentWidth(width);
        final padding = _horizontalPadding(width);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: child,
            ),
          ),
        );
      },
    );
  }

  double _maxContentWidth(double screenWidth) {
    if (screenWidth >= Breakpoints.desktop) return 900;
    if (screenWidth >= Breakpoints.tablet) return 700;
    return double.infinity;
  }

  double _horizontalPadding(double screenWidth) {
    if (screenWidth >= Breakpoints.desktop) return 24;
    if (screenWidth >= Breakpoints.tablet) return 16;
    return 0;
  }

  /// Returns the current device category.
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) return DeviceType.desktop;
    if (width >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

enum DeviceType { mobile, tablet, desktop }
