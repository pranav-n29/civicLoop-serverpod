import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'civic_card.dart';

class CivicPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  const CivicPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        : Text(label);
    return SizedBox(
      width: double.infinity,
      child: icon == null || loading
          ? FilledButton(onPressed: loading ? null : onPressed, child: child)
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: child,
            ),
    );
  }
}

class CivicSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const CivicSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          );
    return SizedBox(width: double.infinity, child: button);
  }
}

class CivicStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const CivicStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory CivicStatusChip.success(String label) => CivicStatusChip(
    label: label,
    color: CivicColors.success,
    icon: Icons.check_circle_outline_rounded,
  );

  factory CivicStatusChip.warning(String label) => CivicStatusChip(
    label: label,
    color: CivicColors.warning,
    icon: Icons.schedule_rounded,
  );

  factory CivicStatusChip.critical(String label) => CivicStatusChip(
    label: label,
    color: CivicColors.critical,
    icon: Icons.priority_high_rounded,
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(CivicRadii.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class CivicSeverityIndicator extends StatelessWidget {
  final String severity;

  const CivicSeverityIndicator({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final normalized = severity.toLowerCase();
    final color = normalized == 'high'
        ? CivicColors.critical
        : normalized == 'medium'
        ? CivicColors.warning
        : CivicColors.success;
    return CivicStatusChip(label: severity, color: color);
  }
}

class CivicSectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CivicSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
      if (actionLabel != null)
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel!,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
    ],
  );
}

class CivicLoadingState extends StatelessWidget {
  final String message;

  const CivicLoadingState({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class CivicEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CivicEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => CivicCard(
    child: Column(
      children: [
        Icon(icon, color: CivicColors.blue, size: 36),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 14),
          CivicSecondaryButton(
            label: actionLabel!,
            onPressed: onAction,
          ),
        ],
      ],
    ),
  );
}

class CivicErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CivicErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => CivicCard(
    color: CivicColors.criticalTint,
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: CivicColors.critical),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message, style: const TextStyle(color: CivicColors.navy)),
        ),
        if (onRetry != null)
          IconButton(
            onPressed: onRetry,
            tooltip: 'Retry',
            icon: const Icon(Icons.refresh_rounded),
          ),
      ],
    ),
  );
}
