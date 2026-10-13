import 'package:flutter/material.dart';

import 'existing_issue_screen.dart';
import '../models/demo_issue.dart';
import '../services/mock_issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';

const _navy = CivicColors.navy;
const _blue = CivicColors.blue;
const _muted = CivicColors.secondaryText;

class AiAnalysisScreen extends StatefulWidget {
  final String category;
  final String severity;
  final String description;
  final MockIssueService service;
  final DemoIssue? createdIssue;

  const AiAnalysisScreen({
    super.key,
    required this.category,
    required this.severity,
    required this.description,
    required this.service,
    this.createdIssue,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  late String _category;
  late String _severity;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _severity = widget.severity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.background,
      appBar: AppBar(
        backgroundColor: CivicColors.background,
        foregroundColor: _navy,
        elevation: 0,
        title: const Text('Review analysis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CivicColors.blueTint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _blue,
              size: 29,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Here’s what we found.',
            style: TextStyle(
              color: _navy,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review the suggested details before continuing. '
            'AI suggestions may be incorrect.',
            style: TextStyle(
              color: _muted,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 26),
          CivicCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      color: _blue,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'SUGGESTED CLASSIFICATION',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    CivicSeverityIndicator(severity: _severity.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  _category,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: CivicColors.border),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: _muted,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Suggested by the demo flow — not a real AI result yet.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          CivicSecondaryButton(
            onPressed: _editClassification,
            icon: Icons.tune_rounded,
            label: 'Edit classification',
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demo analysis refreshed deterministically.'),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry demo analysis'),
          ),
          const SizedBox(height: 12),
          CivicSecondaryButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.edit_outlined,
            label: 'Go back and edit report',
          ),
          const SizedBox(height: 12),
          CivicPrimaryButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ExistingIssueScreen(
                    category: _category,
                    description: widget.description,
                    service: widget.service,
                  ),
                ),
              );
            },
            icon: Icons.arrow_forward_rounded,
            label: 'Find related issues',
          ),
        ],
      ),
    );
  }

  Future<void> _editClassification() async {
    var category = _category;
    var severity = _severity;
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Correct the demo suggestion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Roads', child: Text('Roads')),
                  DropdownMenuItem(
                    value: 'Streetlights',
                    child: Text('Streetlights'),
                  ),
                  DropdownMenuItem(value: 'Water', child: Text('Water')),
                  DropdownMenuItem(value: 'Waste', child: Text('Waste')),
                  DropdownMenuItem(value: 'Drainage', child: Text('Drainage')),
                  DropdownMenuItem(
                    value: 'Public Safety',
                    child: Text('Public Safety'),
                  ),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => category = value);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => severity = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, (category, severity)),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _category = result.$1;
        _severity = result.$2;
      });
      if (widget.createdIssue != null) {
        await widget.service.updateClassification(
          issueId: widget.createdIssue!.id,
          category: result.$1,
          severity: result.$2,
        );
      }
    }
  }
}
