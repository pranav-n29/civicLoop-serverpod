import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import 'issue_detail_screen.dart';

/// Full-featured Admin Dashboard for municipal oversight and staff assignment.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Stats
  AdminDashboardStats? _stats;

  // Issues
  List<Issue>? _issues;
  bool _isLoadingIssues = false;
  String? _issuesError;

  // Staff
  List<StaffUserInfo>? _staffList;
  bool _isLoadingStaff = false;

  // Filters
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  String _selectedDepartment = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const List<String> _departments = [
    'All',
    'Public Works',
    'Transportation',
    'Sanitation',
    'Water & Utilities',
    'Parks & Recreation',
    'Public Safety',
    'General',
  ];

  static const List<String> _priorities = [
    'All',
    'low',
    'medium',
    'high',
    'critical',
  ];

  static const List<String> _statuses = [
    'All',
    'open',
    'assigned',
    'in_progress',
    'resolved',
    'closed',
    'reopened',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadStats(),
      _loadIssues(),
      _loadStaff(),
    ]);
  }

  Future<void> _loadStats() async {
    try {
      final stats = await client.issue.getAdminStats();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadIssues() async {
    setState(() {
      _isLoadingIssues = true;
      _issuesError = null;
    });

    try {
      final statusParam = _selectedStatus == 'All' ? null : _selectedStatus;
      final priorityParam = _selectedPriority == 'All'
          ? null
          : _selectedPriority;
      final deptParam = _selectedDepartment == 'All'
          ? null
          : _selectedDepartment;
      final searchParam = _searchQuery.isEmpty ? null : _searchQuery;

      final list = await client.issue.getAdminIssues(
        status: statusParam,
        priority: priorityParam,
        department: deptParam,
        search: searchParam,
      );

      if (mounted) {
        setState(() {
          _issues = list;
          _isLoadingIssues = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _issuesError = '$e';
          _isLoadingIssues = false;
        });
      }
    }
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoadingStaff = true);
    try {
      final staff = await client.issue.getStaffUsers();
      if (mounted) {
        setState(() {
          _staffList = staff;
          _isLoadingStaff = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStaff = false);
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

  Future<void> _openAssignDialog(Issue issue) async {
    final staffList = _staffList ?? await client.issue.getStaffUsers();
    if (!mounted) return;

    String? selectedStaffId =
        issue.assignedEmployeeId ??
        (staffList.isNotEmpty ? staffList.first.userId : null);
    String selectedPriority = issue.priority ?? 'medium';
    String selectedDept = issue.department ?? 'Public Works';
    final notesController = TextEditingController();
    DateTime? selectedDueDate = issue.dueDate;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Assign Case #${issue.id}'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStaffId,
                        decoration: const InputDecoration(
                          labelText: 'Select Staff Member *',
                          border: OutlineInputBorder(),
                        ),
                        items: staffList.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.userId,
                            child: Text(
                              '${s.fullName ?? s.userId} (${s.department ?? "General"}) - ${s.activeAssignedCasesCount} active',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() => selectedStaffId = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDept,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.where((d) => d != 'All').map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedDept = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority Level',
                          border: OutlineInputBorder(),
                        ),
                        items: _priorities.where((p) => p != 'All').map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedPriority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDueDate == null
                                  ? 'No deadline set'
                                  : 'Due: ${selectedDueDate?.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month, size: 16),
                            label: const Text('Set Due Date'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 3),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDueDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Assignment Instructions / Notes',
                          border: OutlineInputBorder(),
                        ),
                      ),
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
                  onPressed: selectedStaffId == null
                      ? null
                      : () async {
                          try {
                            await client.issue.assignIssue(
                              issue.id!,
                              selectedStaffId!,
                              dueDate: selectedDueDate,
                              priority: selectedPriority,
                              department: selectedDept,
                              notes: notesController.text.trim().isEmpty
                                  ? null
                                  : notesController.text.trim(),
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop(true);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to assign: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: const Text('Confirm Assignment'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue assigned successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAll();
    }
  }

  Future<void> _openRejectDialog(Issue issue) async {
    final reasonController = TextEditingController();

    final rejected = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Reject Issue #${issue.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A clear rejection reason is mandatory and will be visible in the case history.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason *',
                  hintText:
                      'e.g. Duplicate report, private property, insufficient location details...',
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
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade800,
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Rejection reason is required.'),
                    ),
                  );
                  return;
                }
                try {
                  await client.issue.rejectIssue(issue.id!, reason);
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error rejecting: $e')),
                    );
                  }
                }
              },
              child: const Text('Reject Issue'),
            ),
          ],
        );
      },
    );

    if (rejected == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue rejected.'),
          backgroundColor: Colors.red,
        ),
      );
      _loadAll();
    }
  }

  Future<void> _openProvisionStaffDialog() async {
    final userIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'employee';
    String selectedDept = 'Public Works';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Provision New Staff Member'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: userIdController,
                        decoration: const InputDecoration(
                          labelText: 'Staff User ID / Auth ID *',
                          hintText: 'e.g. worker-sarah, john.doe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'e.g. Sarah Connor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'sarah@official.civicloop',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'employee',
                            child: Text('Field Employee (Handles Cases)'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Administrator (Full Access)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedRole = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDept,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.where((d) => d != 'All').map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedDept = val);
                          }
                        },
                      ),
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
                  onPressed: () async {
                    final uid = userIdController.text.trim();
                    if (uid.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Staff User ID is required.'),
                        ),
                      );
                      return;
                    }
                    try {
                      await client.issue.provisionStaff(
                        uid,
                        selectedRole,
                        department: selectedDept,
                        fullName: nameController.text.trim().isEmpty
                            ? null
                            : nameController.text.trim(),
                        email: emailController.text.trim().isEmpty
                            ? null
                            : emailController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop(true);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Provisioning failed: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Provision Staff'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff member provisioned successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadStaff();
    }
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: color.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.indigo),
            SizedBox(width: 8),
            Text(
              'Municipal Command Center',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh All',
            onPressed: _loadAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Case Operations'),
            Tab(icon: Icon(Icons.people_outline), text: 'Staff & Workloads'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Statistics Bar
          if (_stats != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colors.surfaceContainerHighest.withAlpha(70),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatCard(
                      label: 'Total',
                      count: _stats!.totalReports,
                      color: Colors.blueGrey,
                      icon: Icons.all_inbox,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'Open',
                      count: _stats!.openReports,
                      color: Colors.orange.shade800,
                      icon: Icons.pending_actions,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'Assigned',
                      count: _stats!.assignedReports,
                      color: Colors.indigo,
                      icon: Icons.assignment_ind,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'In Progress',
                      count: _stats!.inProgressReports,
                      color: Colors.blue.shade700,
                      icon: Icons.construction,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'Resolved',
                      count: _stats!.resolvedReports,
                      color: Colors.green.shade700,
                      icon: Icons.task_alt,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'Closed',
                      count: _stats!.closedReports,
                      color: Colors.grey.shade700,
                      icon: Icons.done_all,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'Reopened',
                      count: _stats!.reopenedReports,
                      color: Colors.deepOrange.shade800,
                      icon: Icons.replay,
                    ),
                    const SizedBox(width: 6),
                    _buildStatCard(
                      label: 'Overdue',
                      count: _stats!.overdueReports,
                      color: Colors.red.shade900,
                      icon: Icons.alarm,
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Case Operations
                _buildCaseOperationsTab(theme, colors),

                // TAB 2: Staff & Workloads
                _buildStaffTab(theme, colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseOperationsTab(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        // Filter & Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colors.surface,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search case title, description, citizen...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  _loadIssues();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onSubmitted: (val) {
                        setState(() => _searchQuery = val.trim());
                        _loadIssues();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Apply'),
                    onPressed: _loadIssues,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Status dropdown
                    const Text('Status: ', style: TextStyle(fontSize: 12)),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      isDense: true,
                      items: _statuses.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatus = val);
                          _loadIssues();
                        }
                      },
                    ),
                    const SizedBox(width: 16),

                    // Priority dropdown
                    const Text('Priority: ', style: TextStyle(fontSize: 12)),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      isDense: true,
                      items: _priorities.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPriority = val);
                          _loadIssues();
                        }
                      },
                    ),
                    const SizedBox(width: 16),

                    // Department dropdown
                    const Text('Department: ', style: TextStyle(fontSize: 12)),
                    DropdownButton<String>(
                      value: _selectedDepartment,
                      isDense: true,
                      items: _departments.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDepartment = val);
                          _loadIssues();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Issue List
        Expanded(
          child: _isLoadingIssues && _issues == null
              ? const Center(child: CircularProgressIndicator())
              : _issuesError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colors.error),
                      const SizedBox(height: 8),
                      Text('Failed to load issues: $_issuesError'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadIssues,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : (_issues ?? []).isEmpty
              ? const Center(
                  child: Text(
                    'No civic cases match current filters.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadIssues,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _issues!.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final issue = _issues![index];
                      final statusColor = _getStatusColor(issue.status);
                      final priorityColor = _getPriorityColor(issue.priority);
                      final isOverdue =
                          issue.dueDate != null &&
                          issue.dueDate!.isBefore(DateTime.now()) &&
                          issue.status != 'resolved' &&
                          issue.status != 'closed' &&
                          issue.status != 'rejected';

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isOverdue
                                ? Colors.red
                                : colors.outlineVariant.withAlpha(80),
                            width: isOverdue ? 1.5 : 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Badges
                              Row(
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
                                  const SizedBox(width: 6),
                                  if (issue.priority != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
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
                                  const SizedBox(width: 6),
                                  Chip(
                                    label: Text(
                                      issue.department ?? 'General',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Spacer(),
                                  if (isOverdue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning,
                                            size: 14,
                                            color: Colors.red.shade900,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'OVERDUE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Title & Description
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
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Assignment info
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_pin,
                                    size: 16,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    issue.assignedEmployeeName != null
                                        ? 'Assigned to: ${issue.assignedEmployeeName}'
                                        : (issue.assignedEmployeeId != null
                                              ? 'Assigned to: ${issue.assignedEmployeeId}'
                                              : 'Unassigned'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: issue.assignedEmployeeId != null
                                          ? Colors.indigo
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (issue.dueDate != null) ...[
                                    const SizedBox(width: 12),
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
                                        fontSize: 12,
                                        color: isOverdue
                                            ? Colors.red.shade800
                                            : Colors.grey.shade700,
                                        fontWeight: isOverdue
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Rejection or Reopened notes
                              if (issue.status == 'rejected' &&
                                  issue.rejectionReason != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Rejection Reason: ${issue.rejectionReason}',
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                              if (issue.status == 'reopened' &&
                                  issue.reopenReason != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Citizen Dispute: ${issue.reopenReason}',
                                    style: TextStyle(
                                      color: Colors.deepOrange.shade900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              IssueDetailScreen(
                                                issue: issue,
                                                onIssueUpdated: _loadAll,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text('View Details'),
                                  ),
                                  const SizedBox(width: 8),
                                  if (issue.status != 'closed' &&
                                      issue.status != 'rejected') ...[
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red.shade800,
                                      ),
                                      onPressed: () => _openRejectDialog(issue),
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  FilledButton.icon(
                                    icon: const Icon(
                                      Icons.assignment,
                                      size: 16,
                                    ),
                                    label: Text(
                                      issue.assignedEmployeeId == null
                                          ? 'Assign Staff'
                                          : 'Reassign',
                                    ),
                                    onPressed: () => _openAssignDialog(issue),
                                  ),
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
    );
  }

  Widget _buildStaffTab(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Municipal Staff Directory',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Provision Staff'),
                onPressed: _openProvisionStaffDialog,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _isLoadingStaff && _staffList == null
              ? const Center(child: CircularProgressIndicator())
              : (_staffList ?? []).isEmpty
              ? const Center(
                  child: Text('No staff members registered in directory.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _staffList!.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final staff = _staffList![index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: colors.outlineVariant.withAlpha(80),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: staff.role == 'admin'
                              ? Colors.indigo.shade100
                              : Colors.teal.shade100,
                          child: Icon(
                            staff.role == 'admin'
                                ? Icons.security
                                : Icons.engineering,
                            color: staff.role == 'admin'
                                ? Colors.indigo.shade800
                                : Colors.teal.shade800,
                          ),
                        ),
                        title: Text(
                          staff.fullName ?? staff.userId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'User: ${staff.userId} • Dept: ${staff.department ?? "General"}\nRole: ${staff.role.toUpperCase()}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: staff.activeAssignedCasesCount > 0
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${staff.activeAssignedCasesCount} Active Tasks',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: staff.activeAssignedCasesCount > 0
                                      ? Colors.blue.shade900
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: staff.isActive,
                              onChanged: (val) async {
                                try {
                                  await client.issue.setStaffActiveStatus(
                                    staff.userId,
                                    val,
                                  );
                                  _loadStaff();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Status update failed: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
