import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';
import 'resolution_verification_screen.dart';

class IssueDetailsScreen extends StatelessWidget {
  final DemoIssue issue;
  final ValueChanged<DemoIssue>? onChanged;
  final MockIssueService service;

  IssueDetailsScreen({
    super.key,
    required this.issue,
    this.onChanged,
    MockIssueService? service,
  }) : service = service ?? MockIssueService();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Issue details')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        CivicSpacing.page,
        8,
        CivicSpacing.page,
        28,
      ),
      children: [
        CivicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: issue.color.withValues(alpha: .12),
                    child: Icon(issue.icon, color: issue.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      issue.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                issue.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CivicStatusChip(
                    label: issue.category,
                    color: CivicColors.blue,
                  ),
                  CivicSeverityIndicator(severity: issue.severity),
                  CivicStatusChip(
                    label: issue.status.label,
                    color: _statusColor(issue.status),
                  ),
                ],
              ),
              if (issue.location != null)
                _DetailLine(
                  icon: Icons.location_on_outlined,
                  text: issue.location!,
                ),
              if (issue.reportedAt != null)
                _DetailLine(
                  icon: Icons.calendar_today_outlined,
                  text: 'Reported ${_formatDate(context, issue.reportedAt!)}',
                ),
              if (issue.updatedAt != null)
                _DetailLine(
                  icon: Icons.update_rounded,
                  text: 'Updated ${_formatDate(context, issue.updatedAt!)}',
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CivicCard(
          child: Row(
            children: [
              const Icon(Icons.groups_outlined, color: CivicColors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${issue.supportCount} neighbors support this issue',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final updated = await service.supportIssue(issue.id);
                  if (context.mounted) {
                    onChanged?.call(updated);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo support recorded locally.'),
                      ),
                    );
                  }
                },
                child: const Text('Support'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CivicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activity', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ..._timeline(issue.status),
            ],
          ),
        ),
        if (issue.eligibleForVerification) ...[
          const SizedBox(height: 14),
          CivicCard(
            color: CivicColors.successTint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CivicStatusChip.success('Ready for verification'),
                const SizedBox(height: 8),
                const Text(
                  'Has the city resolved this issue?',
                  style: TextStyle(
                    color: CivicColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                CivicPrimaryButton(
                  label: 'Verify resolution',
                  icon: Icons.verified_outlined,
                  onPressed: () async {
                    final updated = await Navigator.push<DemoIssue>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResolutionVerificationScreen(
                          issue: issue,
                          service: service,
                        ),
                      ),
                    );
                    if (updated != null) onChanged?.call(updated);
                  },
                ),
              ],
            ),
          ),
        ],
        if (issue.hasResolutionEvidence) ...[
          const SizedBox(height: 14),
          CivicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolution evidence',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  issue.resolutionNote ??
                      'Evidence is available for this demo issue.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (issue.resolvedAt != null)
                  Text(
                    'Completed ${_formatDate(context, issue.resolvedAt!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        CivicCard(
          color: CivicColors.background,
          child: Text(
            'Demo issue details. Photos, timestamps, and location are shown only when supplied by the available data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );

  List<Widget> _timeline(CivicIssueStatus current) {
    const stages = [
      CivicIssueStatus.reported,
      CivicIssueStatus.underReview,
      CivicIssueStatus.assigned,
      CivicIssueStatus.inProgress,
      CivicIssueStatus.resolved,
    ];
    final currentIndex = stages.indexOf(current);
    return [
      for (var index = 0; index < stages.length; index++)
        _TimelineRow(
          label: stages[index].label,
          complete: currentIndex >= index,
          current: currentIndex == index,
          last: index == stages.length - 1,
        ),
    ];
  }

  Color _statusColor(CivicIssueStatus status) => switch (status) {
    CivicIssueStatus.resolved => CivicColors.success,
    CivicIssueStatus.reopened ||
    CivicIssueStatus.rejected => CivicColors.critical,
    CivicIssueStatus.inProgress ||
    CivicIssueStatus.assigned => CivicColors.blue,
    _ => CivicColors.warning,
  };

  String _formatDate(BuildContext context, DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date.toLocal());
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      children: [
        Icon(icon, size: 16, color: CivicColors.secondaryText),
        const SizedBox(width: 7),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final bool complete;
  final bool current;
  final bool last;
  const _TimelineRow({
    required this.label,
    required this.complete,
    required this.current,
    required this.last,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: Row(
      children: [
        SizedBox(
          width: 26,
          child: Column(
            children: [
              Icon(
                complete
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 20,
                color: complete
                    ? (current ? CivicColors.blue : CivicColors.success)
                    : CivicColors.border,
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    color: complete ? CivicColors.blueTint : CivicColors.border,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            color: complete ? CivicColors.navy : CivicColors.secondaryText,
            fontWeight: current ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        if (current) ...[
          const SizedBox(width: 8),
          const CivicStatusChip(label: 'Current', color: CivicColors.blue),
        ],
      ],
    ),
  );
}
