import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_workflow_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';

class AdminIssueReviewScreen extends StatefulWidget {
  final DemoIssue issue;
  final MockWorkflowService service;
  const AdminIssueReviewScreen({
    super.key,
    required this.issue,
    required this.service,
  });

  @override
  State<AdminIssueReviewScreen> createState() => _AdminIssueReviewScreenState();
}

class _AdminIssueReviewScreenState extends State<AdminIssueReviewScreen> {
  late DemoIssue _issue;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _issue = widget.issue;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review issue')),
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
              Text(
                _issue.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  CivicStatusChip(
                    label: _issue.category,
                    color: CivicColors.blue,
                  ),
                  CivicSeverityIndicator(severity: _issue.severity),
                  CivicStatusChip(
                    label: _issue.status.label,
                    color: _issue.color,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(_issue.description),
              if (_issue.location != null) ...[
                const SizedBox(height: 14),
                Text('Location: ${_issue.location}'),
              ],
              const SizedBox(height: 14),
              const Text(
                'Evidence',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                _issue.hasResolutionEvidence
                    ? (_issue.resolutionNote ??
                          'Resolution evidence available.')
                    : 'No evidence attached to this demo report.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_issue.status == CivicIssueStatus.reported)
          CivicPrimaryButton(
            label: 'Mark under review',
            icon: Icons.visibility_outlined,
            loading: _working,
            onPressed: _working
                ? null
                : () => _run(() => widget.service.reviewIssue(_issue.id)),
          ),
        if (_issue.status == CivicIssueStatus.underReview) ...[
          Text(
            'Assign responder',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...MockWorkflowService.responders.map(
            (responder) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CivicSecondaryButton(
                label: responder,
                icon: Icons.person_add_alt_1_outlined,
                onPressed: _working
                    ? null
                    : () => _run(
                        () => widget.service.assignIssue(_issue.id, responder),
                      ),
              ),
            ),
          ),
        ],
        if (_issue.assignedResponder != null)
          CivicCard(
            color: CivicColors.blueTint,
            child: Text('Assigned to ${_issue.assignedResponder}.'),
          ),
        if (_issue.status == CivicIssueStatus.inProgress ||
            _issue.status == CivicIssueStatus.resolved)
          CivicCard(
            color: CivicColors.background,
            child: Text(
              _issue.status == CivicIssueStatus.resolved
                  ? 'Resolution submitted. Citizen verification is the next step.'
                  : 'Responder is working this issue.',
            ),
          ),
      ],
    ),
  );

  Future<void> _run(Future<DemoIssue> Function() action) async {
    setState(() => _working = true);
    try {
      final updated = await action();
      if (mounted) setState(() => _issue = updated);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demo action failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
