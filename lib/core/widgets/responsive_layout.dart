import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// Responsive Layout — Decides between Desktop and Mobile layout
// ═══════════════════════════════════════════════════════════════

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  static const double breakpoint = 800;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpoint;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return desktopBody;
        }
        return mobileBody;
      },
    );
  }
}
