import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_workflow_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';
import 'admin_issue_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final MockWorkflowService service;
  const AdminDashboardScreen({super.key, required this.service});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<DemoIssue>> _future;
  String _query = '';
  String _status = 'All';
  String _severity = 'All';

  @override
  void initState() {
    super.initState();
    _future = widget.service.getIssues();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Admin dashboard'),
      actions: [
        IconButton(
          tooltip: 'Demo role',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demo admin workspace')),
          ),
          icon: const Icon(Icons.admin_panel_settings_outlined),
        ),
      ],
    ),
    body: FutureBuilder<List<DemoIssue>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CivicLoadingState(message: 'Loading issue queue...');
        }
        if (snapshot.hasError) {
          return CivicErrorState(
            message: 'Unable to load the demo queue.',
            onRetry: () => setState(() => _future = widget.service.getIssues()),
          );
        }
        final issues = snapshot.data ?? const <DemoIssue>[];
        final visible = issues.where(_matches).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            CivicSpacing.page,
            8,
            CivicSpacing.page,
            28,
          ),
          children: [
            const CivicCard(
              color: CivicColors.warningTint,
              child: Text(
                'DEMO ADMIN WORKSPACE • assignments and status changes are local only.',
              ),
            ),
            const SizedBox(height: 14),
            _Metrics(issues: issues),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search title or description',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filter('Status', _status, [
                  'All',
                  'Reported',
                  'Under Review',
                  'Assigned',
                  'In Progress',
                  'Resolved',
                ], (v) => setState(() => _status = v)),
                _filter('Severity', _severity, [
                  'All',
                  'High',
                  'Medium',
                  'Low',
                ], (v) => setState(() => _severity = v)),
              ],
            ),
            const SizedBox(height: 18),
            CivicSectionHeading(
              title: 'Prioritized queue',
              subtitle: '${visible.length} visible issues',
            ),
            const SizedBox(height: 10),
            if (visible.isEmpty)
              const CivicEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No issues match',
                message: 'Adjust the search or filters to see more reports.',
              )
            else
              ...visible.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CivicCard(
                    onTap: () async {
                      final updated = await Navigator.push<DemoIssue>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminIssueReviewScreen(
                            issue: issue,
                            service: widget.service,
                          ),
                        ),
                      );
                      if (updated != null) {
                        setState(() => _future = widget.service.getIssues());
                      }
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(issue.icon, color: issue.color),
                      title: Text(issue.title),
                      subtitle: Text(
                        '${issue.category} • ${issue.location ?? 'Location unavailable'}',
                      ),
                      trailing: CivicStatusChip(
                        label: issue.status.label,
                        color: issue.color,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );

  Widget _filter(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) => DropdownButton<String>(
    value: value,
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
    items: values
        .map(
          (value) =>
              DropdownMenuItem(value: value, child: Text('$label: $value')),
        )
        .toList(),
  );

  bool _matches(DemoIssue issue) {
    final query = _query.toLowerCase();
    return (query.isEmpty ||
            issue.title.toLowerCase().contains(query) ||
            issue.description.toLowerCase().contains(query)) &&
        (_status == 'All' || issue.status.label == _status) &&
        (_severity == 'All' || issue.severity == _severity);
  }
}

class _Metrics extends StatelessWidget {
  final List<DemoIssue> issues;
  const _Metrics({required this.issues});

  @override
  Widget build(BuildContext context) {
    int count(CivicIssueStatus status) =>
        issues.where((issue) => issue.status == status).length;
    final values = [
      ('New reports', count(CivicIssueStatus.reported)),
      ('Awaiting review', count(CivicIssueStatus.underReview)),
      ('Unassigned', issues.where((i) => i.assignedResponder == null).length),
      ('In progress', count(CivicIssueStatus.inProgress)),
      ('Resolved', count(CivicIssueStatus.resolved)),
    ];
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => CivicCard(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 105,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${values[index].$2}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  values[index].$1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
