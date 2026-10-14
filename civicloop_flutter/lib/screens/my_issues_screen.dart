import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import '../utils/claim_storage.dart';
import 'auth_dialog.dart';
import 'issue_detail_screen.dart';

/// Screen displaying the user's submitted civic issues (both authenticated and locally claimed).
class MyIssuesScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCreate;

  const MyIssuesScreen({super.key, this.onNavigateToCreate});

  @override
  State<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  List<Issue>? _issues;
  List<Issue>? _anonymousIssues;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_handleAuthChange);
    _loadAllIssues();
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    if (mounted) {
      _loadAllIssues();
    }
  }

  Future<void> _loadAllIssues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Issue>? myIssues;
      if (client.auth.isAuthenticated) {
        myIssues = await client.issue.getMyIssues();
      }

      // Load claimed anonymous issues from ClaimStorage
      final anonTokens = ClaimStorage.getAllTokens();
      final List<Issue> loadedAnon = [];
      for (final entry in anonTokens.entries) {
        try {
          final issue = await client.issue.getIssueById(
            entry.key,
            claimToken: entry.value,
          );
          if (issue != null) {
            loadedAnon.add(issue);
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _issues = myIssues;
          _anonymousIssues = loadedAnon;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '$e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _lookupAnonymousReport() async {
    final idController = TextEditingController();
    final tokenController = TextEditingController();

    final found = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Look Up Anonymous Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the issue ID and the secret claim token you received upon reporting.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Issue ID *',
                  hintText: 'e.g. 42',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'Claim Token *',
                  hintText: 'Paste 32-character token',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final id = int.tryParse(idController.text.trim());
                final token = tokenController.text.trim();
                if (id == null || token.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Both ID and Claim Token are required.'),
                    ),
                  );
                  return;
                }
                try {
                  final issue = await client.issue.getIssueById(
                    id,
                    claimToken: token,
                  );
                  if (issue != null) {
                    ClaimStorage.saveClaimToken(id, token);
                    if (ctx.mounted) Navigator.of(ctx).pop(true);
                  } else {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Report not found or token invalid.'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Lookup error: $e')),
                    );
                  }
                }
              },
              child: const Text('Track Report'),
            ),
          ],
        );
      },
    );

    if (found == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report linked to this session!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAllIssues();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange.shade700;
      case 'assigned':
        return Colors.indigo.shade600;
      case 'in_progress':
        return Colors.blue.shade700;
      case 'resolved':
        return Colors.green.shade700;
      case 'closed':
        return Colors.grey.shade700;
      case 'reopened':
        return Colors.deepOrange.shade800;
      case 'rejected':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSignedIn = client.auth.isAuthenticated;

    final allReports = [
      ...?_issues,
      ...?_anonymousIssues,
    ];

    if (!isSignedIn && allReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_person_outlined,
                size: 64,
                color: colors.primary.withAlpha(180),
              ),
              const SizedBox(height: 16),
              Text(
                'Personal Reports',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with your citizen account to track personal reports, or look up an anonymous report using its claim token.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In / Register'),
                    onPressed: () => AuthDialog.show(context),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('Enter Claim Token'),
                    onPressed: _lookupAnonymousReport,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading && allReports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && allReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 12),
              Text('Failed to load reports: $_errorMessage'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadAllIssues,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (allReports.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllIssues,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 56,
              color: colors.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              'No Personal Reports Yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Issues you report while signed in or with saved claim tokens will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (widget.onNavigateToCreate != null)
              Center(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.add),
                  label: const Text('Submit Your First Report'),
                  onPressed: widget.onNavigateToCreate,
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllIssues,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: allReports.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final issue = allReports[index];
          final statusColor = _getStatusColor(issue.status);
          final isClaimed =
              issue.id != null && ClaimStorage.hasClaimToken(issue.id!);

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outlineVariant.withAlpha(80)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => IssueDetailScreen(
                      issue: issue,
                      onIssueUpdated: _loadAllIssues,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            issue.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          issue.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (isClaimed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CLAIMED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          issue.createdAt.toLocal().toString().split(' ')[0],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '#${issue.id} - ${issue.title}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
