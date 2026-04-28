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
    return ShaderMask(
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
    );
  }
}
