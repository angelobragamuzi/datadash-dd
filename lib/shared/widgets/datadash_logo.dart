import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class DataDashLogo extends StatelessWidget {
  const DataDashLogo({
    super.key,
    this.size = 120,
    this.pulse = 0,
    this.withGlow = false,
  });

  final double size;
  final double pulse;
  final bool withGlow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brandStart = scheme.brightness == Brightness.dark
        ? AppColors.darkTitleText
        : AppColors.primaryDark;
    final brandMid = scheme.brightness == Brightness.dark
        ? AppColors.primaryLight
        : scheme.primary;
    final brandEnd = scheme.brightness == Brightness.dark
        ? AppColors.accentLight
        : scheme.tertiary;
    final fontSize = size * 0.43;
    final strokeWidth = (size * 0.025).clamp(1.6, 3.4);
    final accentWidth = (size * 1.85).clamp(72.0, 360.0);
    final pulseFactor = (0.55 + (pulse * 0.30)).clamp(0.45, 0.9);
    final glowColor = scheme.primary.withValues(alpha: withGlow ? 0.24 : 0.08);

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: withGlow ? size * 0.24 : size * 0.12,
            spreadRadius: withGlow ? size * 0.02 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [brandStart, brandMid, brandEnd],
                stops: const [0.0, 0.74, 1.0],
              ).createShader(bounds);
            },
            child: Text(
              'DataDash',
              style: GoogleFonts.orbitron(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: fontSize * 0.045,
                height: 0.96,
              ),
            ),
          ),
          SizedBox(height: size * 0.08),
          SizedBox(
            width: accentWidth,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: strokeWidth,
                  decoration: BoxDecoration(
                    color: scheme.outline.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pulseFactor,
                  child: Container(
                    height: strokeWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.tertiary],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: strokeWidth * 1.9,
                    height: strokeWidth * 1.9,
                    decoration: BoxDecoration(
                      color: scheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
