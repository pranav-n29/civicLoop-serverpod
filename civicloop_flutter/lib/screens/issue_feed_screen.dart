import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import 'issue_detail_screen.dart';

/// Screen displaying the public civic issue feed with filtering and search.
class IssueFeedScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCreate;

  const IssueFeedScreen({super.key, this.onNavigateToCreate});

  @override
  State<IssueFeedScreen> createState() => _IssueFeedScreenState();
}

class _IssueFeedScreenState extends State<IssueFeedScreen> {
  List<Issue>? _issues;
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final _searchController = TextEditingController();

  static const List<String> _categories = [
    'All',
    'Roads & Infrastructure',
    'Sanitation',
    'Lighting',
    'Water & Utilities',
    'Parks & Recreation',
    'Public Safety',
    'Traffic & Transit',
    'Code Enforcement',
    'Other',
  ];

  static const List<String> _statuses = [
    'All',
    'Open',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIssues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await client.issue.getIssues();
      if (mounted) {
        setState(() {
          _issues = list;
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

  List<Issue> get _filteredIssues {
    if (_issues == null) return [];

    return _issues!.where((issue) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = issue.title.toLowerCase().contains(query);
        final matchesDesc = issue.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // Category filter
      if (_selectedCategory != 'All') {
        if (issue.category.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatus != 'All') {
        final normStatus = _selectedStatus.toLowerCase().replaceAll(' ', '_');
        if (issue.status.toLowerCase() != normStatus) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange.shade700;
      case 'in_progress':
        return Colors.blue.shade700;
      case 'resolved':
        return Colors.green.shade700;
      case 'closed':
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'open':
        return 'Open';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentUserId = client.auth.authInfo?.authUserId.toString();

    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search civic issues by keyword...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withAlpha(120),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
              const SizedBox(height: 8),

              // Horizontal Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        visualDensity: VisualDensity.compact,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : 'All';
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Status Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.map((status) {
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        visualDensity: VisualDensity.compact,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : 'All';
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Issue List or State Displays
        Expanded(
          child: _isLoading && _issues == null
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 52,
                          color: colors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to connect to backend',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.error,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Connection'),
                          onPressed: _loadIssues,
                        ),
                      ],
                    ),
                  ),
                )
              : _filteredIssues.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadIssues,
                  child: ListView(
                    padding: const EdgeInsets.all(32),
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.inbox_outlined,
                        size: 56,
                        color: colors.onSurfaceVariant.withAlpha(120),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Issues Found',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty ||
                                _selectedCategory != 'All' ||
                                _selectedStatus != 'All'
                            ? 'Try adjusting your search query or filter chips.'
                            : 'There are currently no civic issues in the database.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      if (widget.onNavigateToCreate != null)
                        Center(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Report an Issue'),
                            onPressed: widget.onNavigateToCreate,
                          ),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadIssues,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredIssues.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final issue = _filteredIssues[index];
                      final statusColor = _getStatusColor(issue.status);
                      final isUserOwner =
                          currentUserId != null &&
                          issue.userId == currentUserId;

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colors.outlineVariant.withAlpha(80),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IssueDetailScreen(
                                  issue: issue,
                                  onIssueUpdated: _loadIssues,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Status, Category, Photo indicator, Time
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
                                        border: Border.all(
                                          color: statusColor,
                                        ),
                                      ),
                                      child: Text(
                                        _formatStatus(issue.status),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        issue.category,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    if (issue.photoPath != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Icon(
                                          Icons.photo_camera,
                                          size: 16,
                                          color: colors.primary,
                                        ),
                                      ),
                                    Text(
                                      issue.createdAt
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Title
                                Text(
                                  issue.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Description preview
                                Text(
                                  issue.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Privacy attribution footer
                                Row(
                                  children: [
                                    Icon(
                                      issue.userId != null
                                          ? (isUserOwner
                                                ? Icons.person
                                                : Icons.admin_panel_settings)
                                          : Icons.lock_outline,
                                      size: 14,
                                      color: issue.userId != null
                                          ? (isUserOwner
                                                ? Colors.teal.shade700
                                                : colors.primary)
                                          : colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        issue.userId != null
                                            ? (isUserOwner
                                                  ? 'Reported by You'
                                                  : 'Reporter: ${issue.userId}')
                                            : 'Citizen Report (Identity Protected)',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: issue.userId != null
                                              ? (isUserOwner
                                                    ? Colors.teal.shade800
                                                    : colors.primary)
                                              : colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
