import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.maxContentWidth = 980,
    this.topAlign = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxContentWidth;
  final bool topAlign;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AppAmbientPainter(
                primary: AppColors.primary,
                accent: AppColors.accent,
                isDark: isDark,
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: topAlign ? Alignment.topCenter : Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class AppPageScrollView extends StatelessWidget {
  const AppPageScrollView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 24),
    this.maxContentWidth = 980,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
      padding: EdgeInsets.zero,
      maxContentWidth: maxContentWidth,
      child: ListView(padding: padding, children: children),
    );
  }
}

class _AppAmbientPainter extends CustomPainter {
  const _AppAmbientPainter({
    required this.primary,
    required this.accent,
    required this.isDark,
  });

  final Color primary;
  final Color accent;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final topCircle = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.12 : 0.07);
    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.10),
      size.width * 0.22,
      topCircle,
    );

    final bottomCircle = Paint()
      ..color = accent.withValues(alpha: isDark ? 0.10 : 0.07);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.90),
      size.width * 0.24,
      bottomCircle,
    );

    final pathPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.18 : 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final topCurve = Path()
      ..moveTo(-24, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.04,
        size.width * 0.62,
        size.height * 0.18,
      )
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.30,
        size.width + 24,
        size.height * 0.14,
      );
    canvas.drawPath(topCurve, pathPaint);

    final midCurve = Path()
      ..moveTo(-24, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.48,
        size.width * 0.40,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.74,
        size.width + 24,
        size.height * 0.60,
      );
    canvas.drawPath(midCurve, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _AppAmbientPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.accent != accent ||
        oldDelegate.isDark != isDark;
  }
}
