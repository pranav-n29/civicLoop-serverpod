import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';
import 'issue_details_screen.dart';

class ExistingIssueScreen extends StatefulWidget {
  final String category;
  final String description;
  final MockIssueService service;

  ExistingIssueScreen({
    super.key,
    required this.category,
    required this.description,
    MockIssueService? service,
  }) : service = service ?? MockIssueService();

  @override
  State<ExistingIssueScreen> createState() => _ExistingIssueScreenState();
}

class _ExistingIssueScreenState extends State<ExistingIssueScreen> {
  late DemoIssue _issue;
  bool _supported = false;

  @override
  void initState() {
    super.initState();
    _issue = defaultDemoIssues().first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Related issues')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          CivicSpacing.page,
          8,
          CivicSpacing.page,
          CivicSpacing.section,
        ),
        children: [
          const Icon(Icons.hub_outlined, color: CivicColors.blue, size: 46),
          const SizedBox(height: 16),
          Text(
            'We found a nearby match.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Supporting an existing issue helps the city prioritize community impact.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          CivicCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IssueDetailsScreen(
                  issue: _issue,
                  service: widget.service,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: CivicColors.warningTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: CivicColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _issue.title,
                        style: TextStyle(
                          color: CivicColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    CivicStatusChip.warning('Active'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${_issue.category} • ${_issue.location ?? 'Location unavailable'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _issue.description,
                  style: TextStyle(
                    color: CivicColors.navy,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                const CivicStatusChip(
                  label: 'Demo match',
                  color: CivicColors.blue,
                  icon: Icons.info_outline_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CivicCard(
            color: CivicColors.background,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: CivicColors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your ${widget.category.toLowerCase()} report was compared with the local demo issue. Matching is simulated until a Serverpod issue service is available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          CivicPrimaryButton(
            label: _supported ? 'Issue supported' : 'Support this issue',
            icon: _supported
                ? Icons.check_rounded
                : Icons.thumb_up_alt_outlined,
            onPressed: _supported
                ? null
                : () async {
                    final updated = await widget.service.supportIssue(
                      _issue.id,
                    );
                    if (mounted) {
                      setState(() {
                        _issue = updated;
                        _supported = true;
                      });
                    }
                  },
          ),
          const SizedBox(height: 10),
          CivicSecondaryButton(
            label: 'Submit as a new report',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => Navigator.pop(context),
          ),
          if (_supported) ...[
            const SizedBox(height: 12),
            CivicCard(
              color: CivicColors.successTint,
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: CivicColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo support recorded locally. It is not saved to the server.',
                      style: TextStyle(color: CivicColors.navy, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
