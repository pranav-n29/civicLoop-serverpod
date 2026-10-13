import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';

class ResolutionVerificationScreen extends StatefulWidget {
  final DemoIssue issue;
  final MockIssueService service;
  ResolutionVerificationScreen({
    super.key,
    required this.issue,
    MockIssueService? service,
  }) : service = service ?? MockIssueService();

  @override
  State<ResolutionVerificationScreen> createState() =>
      _ResolutionVerificationScreenState();
}

class _ResolutionVerificationScreenState
    extends State<ResolutionVerificationScreen> {
  bool _submitting = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    if (!widget.issue.eligibleForVerification) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verify resolution')),
        body: const CivicEmptyState(
          icon: Icons.lock_outline,
          title: 'Verification is not available',
          message: 'This issue has not reached a verifiable resolved state.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Verify resolution')),
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
                  widget.issue.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(widget.issue.description),
                if (widget.issue.resolutionNote != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Responder note',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.issue.resolutionNote!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          CivicCard(
            color: CivicColors.blueTint,
            child: const Text(
              'Please confirm whether the issue is resolved. Selecting “No” will reopen this demo issue for review.',
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 14),
            CivicCard(child: Text(_result!)),
          ],
          const SizedBox(height: 18),
          CivicPrimaryButton(
            label: 'Yes, issue resolved',
            icon: Icons.check_circle_outline,
            loading: _submitting,
            onPressed: _submitting ? null : () => _confirm(true),
          ),
          const SizedBox(height: 10),
          CivicSecondaryButton(
            label: 'No, still an issue',
            icon: Icons.refresh_rounded,
            onPressed: _submitting ? null : () => _confirm(false),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(bool resolved) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm your response'),
        content: Text(
          resolved
              ? 'Confirm that this issue is resolved?'
              : 'Report that this is still an issue and reopen it for review?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => _submitting = true);
    try {
      final updated = await widget.service.submitVerification(
        issueId: widget.issue.id,
        resolved: resolved,
      );
      if (!mounted) return;
      setState(
        () {
          _result = resolved
              ? 'Thanks. Your demo verification was recorded locally.'
              : 'The demo issue was reopened locally for review.';
        },
      );
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context, updated);
    } catch (error) {
      if (mounted) {
        setState(() => _result = 'Could not save demo response: $error');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
