import 'dart:typed_data';

import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import '../utils/custom_image_picker.dart';
import '../utils/sample_photos.dart';
import 'issue_detail_screen.dart';

/// Employee Field Tasks Dashboard for municipal workers.
class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  List<Issue>? _assignedIssues;
  bool _isLoading = false;
  String? _errorMessage;
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAssignedIssues();
  }

  Future<void> _loadAssignedIssues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final issues = await client.issue.getEmployeeAssignedIssues();
      if (mounted) {
        setState(() {
          _assignedIssues = issues;
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
    if (_assignedIssues == null) return [];
    if (_statusFilter == 'All') return _assignedIssues!;
    return _assignedIssues!.where((i) {
      return i.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.indigo.shade600;
      case 'in_progress':
        return Colors.blue.shade700;
      case 'resolved':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
        return Colors.red.shade800;
      case 'high':
        return Colors.deepOrange.shade700;
      case 'medium':
        return Colors.amber.shade800;
      case 'low':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _handleStartWork(Issue issue) async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Start Work on Case #${issue.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Starting work transitions case #${issue.id} to "IN_PROGRESS" and notifies the reporting citizen.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Initial Dispatch Note (Optional)',
                  hintText: 'e.g. Crew arrived on site, materials prepped...',
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
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm Start Work'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final notes = noteController.text.trim();
        await client.issue.startWork(
          issue.id!,
          notes: notes.isEmpty ? null : notes,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work started! Case is now IN_PROGRESS.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        _loadAssignedIssues();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start work: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleAddProgressNote(Issue issue) async {
    final noteController = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add Progress Note (#${issue.id})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Field Progress Note *',
                  hintText:
                      'e.g. Asphalt poured, curing required for 4 hours...',
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
                final note = noteController.text.trim();
                if (note.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Note cannot be empty.')),
                  );
                  return;
                }
                try {
                  await client.issue.addProgressNote(issue.id!, note);
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed to add note: $e')),
                    );
                  }
                }
              },
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );

    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress note added to case timeline.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAssignedIssues();
    }
  }

  Future<void> _handleResolveIssue(Issue issue) async {
    final notesController = TextEditingController();
    Uint8List? photoBytes;
    String? photoFileName;

    final resolved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Resolve Case #${issue.id}'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detailed completion notes are required for citizen verification.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Completion / Resolution Notes *',
                          hintText:
                              'Describe the repair performed, materials used, and final condition...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Proof of Completion Photo (Recommended):',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Completion photo preview
                      if (photoBytes != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green.shade50,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Photo attached: ${photoFileName ?? "image.png"}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setDialogState(() {
                                    photoBytes = null;
                                    photoFileName = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ] else ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Pick Image File'),
                              onPressed: () async {
                                final picked =
                                    await CustomImagePicker.pickImage();
                                if (picked != null) {
                                  setDialogState(() {
                                    photoBytes = picked.bytes;
                                    photoFileName = picked.fileName;
                                  });
                                }
                              },
                            ),
                            ...PhotoUtils.samplePhotos.take(2).map((s) {
                              return ActionChip(
                                avatar: const Icon(Icons.photo, size: 16),
                                label: Text(s.name),
                                onPressed: () {
                                  setDialogState(() {
                                    photoBytes = s.bytes;
                                    photoFileName = s.fileName;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  onPressed: () async {
                    final notes = notesController.text.trim();
                    if (notes.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Completion notes are required.'),
                        ),
                      );
                      return;
                    }
                    try {
                      ByteData? byteData;
                      if (photoBytes != null) {
                        byteData = PhotoUtils.toByteData(photoBytes!);
                      }

                      await client.issue.resolveIssue(
                        issue.id!,
                        notes,
                        completionPhotoData: byteData,
                        completionPhotoFileName: photoFileName,
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop(true);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Failed to resolve: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Complete & Resolve'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resolved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Case marked RESOLVED! Citizen notified for verification.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadAssignedIssues();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentUserId = client.auth.authInfo?.authUserId.toString();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.engineering, color: Colors.teal),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                MediaQuery.sizeOf(context).width < 380
                    ? 'Task Board'
                    : 'Field Worker Task Board',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tasks',
            onPressed: _loadAssignedIssues,
          ),
        ],
      ),
      body: Column(
        children: [
          // Worker Profile Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colors.primaryContainer.withAlpha(50),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary,
                  radius: 18,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worker: ${currentUserId ?? "Active Field Technician"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Assigned Field Tasks: ${_assignedIssues?.length ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'EMPLOYEE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'assigned', 'in_progress', 'resolved'].map((
                  status,
                ) {
                  final isSelected =
                      _statusFilter.toLowerCase() == status.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        status == 'All' ? 'All Tasks' : status.toUpperCase(),
                      ),
                      selected: isSelected,
                      visualDensity: VisualDensity.compact,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? status : 'All';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Issues List
          Expanded(
            child: _isLoading && _assignedIssues == null
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colors.error,
                        ),
                        const SizedBox(height: 8),
                        Text('Failed to load tasks: $_errorMessage'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loadAssignedIssues,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredIssues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          size: 56,
                          color: Colors.teal.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Assigned Tasks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You have no pending tasks in this category.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAssignedIssues,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredIssues.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final issue = _filteredIssues[index];
                        final statusColor = _getStatusColor(issue.status);
                        final priorityColor = _getPriorityColor(issue.priority);
                        final isOverdue =
                            issue.dueDate != null &&
                            issue.dueDate!.isBefore(DateTime.now()) &&
                            issue.status != 'resolved' &&
                            issue.status != 'closed';

                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isOverdue
                                  ? Colors.red
                                  : colors.outlineVariant.withAlpha(80),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Badges
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(30),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        issue.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    if (issue.priority != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: priorityColor.withAlpha(25),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: priorityColor,
                                          ),
                                        ),
                                        child: Text(
                                          issue.priority!.toUpperCase(),
                                          style: TextStyle(
                                            color: priorityColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    if (issue.dueDate != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOverdue
                                              ? Colors.red.shade50
                                              : colors.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.event,
                                              size: 14,
                                              color: isOverdue
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Due: ${issue.dueDate!.toLocal().toString().split(' ')[0]}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isOverdue
                                                    ? Colors.red.shade900
                                                    : Colors.grey.shade700,
                                                fontWeight: isOverdue
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Title & Category
                                Text(
                                  '#${issue.id} - ${issue.title}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Category: ${issue.category} • Dept: ${issue.department ?? "General"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Description
                                Text(
                                  issue.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 8),

                                // Progress notes preview if present
                                if (issue.progressNotes != null &&
                                    issue.progressNotes!.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerHighest
                                          .withAlpha(80),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Latest Progress Notes:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          issue.progressNotes!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Action buttons
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.end,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                IssueDetailScreen(
                                                  issue: issue,
                                                  onIssueUpdated:
                                                      _loadAssignedIssues,
                                                ),
                                          ),
                                        );
                                      },
                                      child: const Text('Details'),
                                    ),
                                    if (issue.status == 'assigned')
                                      FilledButton.icon(
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          size: 16,
                                        ),
                                        label: const Text('Start Work'),
                                        onPressed: () =>
                                            _handleStartWork(issue),
                                      )
                                    else if (issue.status == 'in_progress') ...[
                                      OutlinedButton.icon(
                                        icon: const Icon(
                                          Icons.note_add,
                                          size: 16,
                                        ),
                                        label: const Text('Add Note'),
                                        onPressed: () =>
                                            _handleAddProgressNote(issue),
                                      ),
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade700,
                                        ),
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                        ),
                                        label: const Text('Resolve'),
                                        onPressed: () =>
                                            _handleResolveIssue(issue),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
