import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';
import 'issue_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final MockIssueService service;
  const MyReportsScreen({super.key, required this.service});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late Future<List<DemoIssue>> _future;
  String _query = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _future = widget.service.getIssues();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My reports')),
    body: FutureBuilder<List<DemoIssue>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CivicLoadingState(message: 'Loading demo reports...');
        }
        if (snapshot.hasError) {
          return CivicErrorState(
            message: 'We could not load your demo reports.',
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
            CivicCard(
              color: CivicColors.blueTint,
              child: Text(
                'Demo reports only • authentication and report persistence are not connected.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Count(
                  label: 'Active',
                  count: issues
                      .where((i) => i.status != CivicIssueStatus.resolved)
                      .length,
                ),
                _Count(
                  label: 'In progress',
                  count: issues
                      .where((i) => i.status == CivicIssueStatus.inProgress)
                      .length,
                ),
                _Count(
                  label: 'Resolved',
                  count: issues
                      .where((i) => i.status == CivicIssueStatus.resolved)
                      .length,
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search reports',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final filter in ['All', 'Active', 'Resolved'])
                  ChoiceChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (visible.isEmpty)
              const CivicEmptyState(
                icon: Icons.assignment_outlined,
                title: 'No matching reports',
                message: 'Try another search or filter.',
              )
            else
              ...visible.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CivicCard(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IssueDetailsScreen(
                            issue: issue,
                            service: widget.service,
                          ),
                        ),
                      );
                      if (mounted) {
                        setState(() => _future = widget.service.getIssues());
                      }
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(issue.icon, color: issue.color),
                      title: Text(issue.title),
                      subtitle: Text('${issue.category} • ${issue.severity}'),
                      trailing: CivicStatusChip(
                        label: issue.status.label,
                        color: issue.status == CivicIssueStatus.resolved
                            ? CivicColors.success
                            : CivicColors.blue,
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

  bool _matches(DemoIssue issue) {
    final query = _query.toLowerCase();
    final textMatch =
        query.isEmpty ||
        issue.title.toLowerCase().contains(query) ||
        issue.category.toLowerCase().contains(query);
    final filterMatch =
        _filter == 'All' ||
        (_filter == 'Resolved' && issue.status == CivicIssueStatus.resolved) ||
        (_filter == 'Active' && issue.status != CivicIssueStatus.resolved);
    return textMatch && filterMatch;
  }
}

class _Count extends StatelessWidget {
  final String label;
  final int count;
  const _Count({required this.label, required this.count});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text('$count', style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
