import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_issue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';
import 'issue_details_screen.dart';

class NearbyIssuesScreen extends StatefulWidget {
  final MockIssueService service;
  const NearbyIssuesScreen({super.key, required this.service});

  @override
  State<NearbyIssuesScreen> createState() => _NearbyIssuesScreenState();
}

class _NearbyIssuesScreenState extends State<NearbyIssuesScreen> {
  late Future<List<DemoIssue>> _future;
  String _category = 'All';
  String _severity = 'All';
  String _status = 'All';

  @override
  void initState() {
    super.initState();
    _future = widget.service.getIssues();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nearby issues')),
    body: FutureBuilder<List<DemoIssue>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CivicLoadingState(
            message: 'Loading nearby demo issues...',
          );
        }
        if (snapshot.hasError) {
          return CivicErrorState(
            message: 'Nearby issues are unavailable.',
            onRetry: () => setState(() => _future = widget.service.getIssues()),
          );
        }
        final issues = (snapshot.data ?? const <DemoIssue>[])
            .where(_matches)
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            CivicSpacing.page,
            8,
            CivicSpacing.page,
            28,
          ),
          children: [
            const CivicCard(
              color: CivicColors.blueTint,
              child: Text(
                'Map preview • live maps, coordinates, and real-time proximity are not connected.',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: CivicColors.background,
                borderRadius: BorderRadius.circular(CivicRadii.card),
                border: Border.all(color: CivicColors.border),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: CivicColors.secondaryText,
                      size: 30,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Map placeholder',
                      style: TextStyle(color: CivicColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _drop('Category', _category, [
                  'All',
                  'Roads',
                  'Streetlights',
                  'Water',
                  'Waste',
                  'Drainage',
                  'Public Safety',
                ], (v) => setState(() => _category = v)),
                _drop('Severity', _severity, [
                  'All',
                  'Low',
                  'Medium',
                  'High',
                  'Critical',
                ], (v) => setState(() => _severity = v)),
                _drop('Status', _status, [
                  'All',
                  'Reported',
                  'Under Review',
                  'Assigned',
                  'In Progress',
                  'Resolved',
                ], (v) => setState(() => _status = v)),
              ],
            ),
            const SizedBox(height: 14),
            if (issues.isEmpty)
              const CivicEmptyState(
                icon: Icons.explore_off_outlined,
                title: 'No nearby demo issues',
                message: 'Try changing the filters.',
              )
            else
              ...issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CivicCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IssueDetailsScreen(
                          issue: issue,
                          service: widget.service,
                        ),
                      ),
                    ),
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

  Widget _drop(
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
          (item) => DropdownMenuItem(value: item, child: Text('$label: $item')),
        )
        .toList(),
  );

  bool _matches(DemoIssue issue) =>
      (_category == 'All' || issue.category == _category) &&
      (_severity == 'All' || issue.severity == _severity) &&
      (_status == 'All' || issue.status.label == _status);
}
