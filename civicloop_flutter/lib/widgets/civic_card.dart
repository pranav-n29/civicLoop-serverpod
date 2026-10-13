import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CivicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  const CivicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(CivicSpacing.card),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? CivicColors.card,
        borderRadius: BorderRadius.circular(CivicRadii.card),
        border: Border.all(color: CivicColors.border),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(CivicRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: card),
    );
  }
}
