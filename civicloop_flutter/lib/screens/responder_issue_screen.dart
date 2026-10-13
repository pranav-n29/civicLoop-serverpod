import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_workflow_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';

class ResponderIssueScreen extends StatefulWidget {
  final DemoIssue issue;
  final MockWorkflowService service;
  const ResponderIssueScreen({
    super.key,
    required this.issue,
    required this.service,
  });

  @override
  State<ResponderIssueScreen> createState() => _ResponderIssueScreenState();
}

class _ResponderIssueScreenState extends State<ResponderIssueScreen> {
  late DemoIssue _issue;
  final _noteController = TextEditingController();
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _issue = widget.issue;
    _noteController.text = _issue.resolutionNote ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Assigned issue')),
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
                const SizedBox(height: 12),
                Text('Location: ${_issue.location}'),
              ],
              const SizedBox(height: 12),
              Text(
                'Assigned to ${_issue.assignedResponder ?? 'demo responder'}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_issue.status == CivicIssueStatus.assigned)
          CivicPrimaryButton(
            label: 'Start work',
            icon: Icons.play_arrow_rounded,
            loading: _working,
            onPressed: _working
                ? null
                : () => _run(() => widget.service.startWork(_issue.id)),
          ),
        if (_issue.status == CivicIssueStatus.inProgress) ...[
          Text(
            'Resolution update',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Resolution notes',
              hintText: 'Describe the work completed...',
            ),
          ),
          const SizedBox(height: 10),
          CivicCard(
            color: CivicColors.background,
            child: Row(
              children: [
                const Icon(
                  Icons.photo_camera_outlined,
                  color: CivicColors.secondaryText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Photo evidence interface is demo-only; no image service is connected.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Photo upload is not connected in this demo.',
                      ),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CivicPrimaryButton(
            label: 'Submit for verification',
            icon: Icons.verified_outlined,
            loading: _working,
            onPressed: _working ? null : _submit,
          ),
        ],
        if (_issue.status == CivicIssueStatus.resolved)
          const CivicCard(
            color: CivicColors.successTint,
            child: Text(
              'Resolution submitted. The citizen can now verify or dispute it.',
            ),
          ),
      ],
    ),
  );

  Future<void> _submit() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a resolution note before submitting.'),
        ),
      );
      return;
    }
    await _run(
      () => widget.service.submitResolution(
        _issue.id,
        _noteController.text.trim(),
      ),
    );
  }

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
