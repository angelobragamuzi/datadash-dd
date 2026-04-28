import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.illustrationAsset,
    this.illustrationHeight = 120,
    this.action,
    this.withCard = false,
    this.maxWidth = 420,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String title;
  final String subtitle;
  final String? illustrationAsset;
  final double illustrationHeight;
  final Widget? action;
  final bool withCard;
  final double maxWidth;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (illustrationAsset != null) ...[
          SizedBox(
            height: illustrationHeight,
            child: SvgPicture.asset(illustrationAsset!, fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: subtitleStyle ?? Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 14), action!],
      ],
    );

    if (!withCard) {
      return SizedBox(
        width: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: content,
            ),
          ),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: content,
    );
  }
}
