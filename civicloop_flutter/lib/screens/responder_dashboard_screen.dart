import 'package:flutter/material.dart';

import '../models/demo_issue.dart';
import '../services/mock_workflow_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../widgets/civic_components.dart';
import 'responder_issue_screen.dart';

class ResponderDashboardScreen extends StatefulWidget {
  final MockWorkflowService service;
  const ResponderDashboardScreen({super.key, required this.service});

  @override
  State<ResponderDashboardScreen> createState() =>
      _ResponderDashboardScreenState();
}

class _ResponderDashboardScreenState extends State<ResponderDashboardScreen> {
  late Future<List<DemoIssue>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.getIssues();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Responder dashboard')),
    body: FutureBuilder<List<DemoIssue>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CivicLoadingState(message: 'Loading assignments...');
        }
        if (snapshot.hasError) {
          return CivicErrorState(
            message: 'Unable to load assigned demo issues.',
            onRetry: () => setState(() => _future = widget.service.getIssues()),
          );
        }
        final issues = (snapshot.data ?? const <DemoIssue>[])
            .where((issue) => issue.assignedResponder != null)
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
              color: CivicColors.warningTint,
              child: Text(
                'DEMO RESPONDER WORKSPACE • assignments and updates are local only.',
              ),
            ),
            const SizedBox(height: 14),
            if (issues.isEmpty)
              const CivicEmptyState(
                icon: Icons.assignment_ind_outlined,
                title: 'No assigned issues',
                message: 'Assigned issues will appear here for the responder.',
              )
            else
              ...issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CivicCard(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResponderIssueScreen(
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
                      subtitle: Text(
                        '${issue.category} • ${issue.severity} priority',
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
}
