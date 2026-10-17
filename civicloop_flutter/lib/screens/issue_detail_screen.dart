import 'dart:typed_data';

import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import '../utils/claim_storage.dart';
import '../utils/custom_image_picker.dart';
import '../utils/sample_photos.dart';

/// Screen displaying the complete details of a single civic issue.
class IssueDetailScreen extends StatefulWidget {
  final Issue issue;
  final VoidCallback? onIssueUpdated;

  const IssueDetailScreen({
    super.key,
    required this.issue,
    this.onIssueUpdated,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late Issue _issue;
  bool _isLoading = false;
  bool _isAttachingPhoto = false;

  // Initial Problem Photo
  Uint8List? _photoBytes;
  bool _isLoadingPhoto = false;
  String? _photoError;

  // Completion Evidence Photo
  Uint8List? _completionPhotoBytes;
  bool _isLoadingCompletionPhoto = false;

  // Audit History
  List<CivicIssueAudit>? _auditHistory;
  bool _isLoadingAudit = false;

  // User Role Profile
  StaffUserInfo? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _issue = widget.issue;
    _loadAllDetails();
  }

  Future<void> _loadAllDetails() async {
    await Future.wait([
      _loadPhoto(),
      _loadCompletionPhoto(),
      _loadAuditHistory(),
      _loadUserProfile(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    if (!client.auth.isAuthenticated) {
      if (mounted) setState(() => _currentUserProfile = null);
      return;
    }
    try {
      final profile = await client.issue.getCurrentUserProfile();
      if (mounted) setState(() => _currentUserProfile = profile);
    } catch (_) {}
  }

  Future<void> _refreshIssue() async {
    if (_issue.id == null) return;
    setState(() => _isLoading = true);
    try {
      final token = ClaimStorage.getClaimToken(_issue.id!);
      final updated = await client.issue.getIssueById(
        _issue.id!,
        claimToken: token,
      );
      if (updated != null && mounted) {
        setState(() {
          _issue = updated;
        });
        await _loadAllDetails();
        widget.onIssueUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPhoto() async {
    if (_issue.id == null || _issue.photoPath == null) {
      setState(() {
        _photoBytes = null;
        _isLoadingPhoto = false;
      });
      return;
    }

    setState(() {
      _isLoadingPhoto = true;
      _photoError = null;
    });

    try {
      final byteData = await client.issue.getIssuePhoto(_issue.id!);
      if (mounted) {
        setState(() {
          if (byteData != null) {
            _photoBytes = byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            );
          } else {
            _photoBytes = null;
          }
          _isLoadingPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _photoError = 'Could not load photo: $e';
          _isLoadingPhoto = false;
        });
      }
    }
  }

  Future<void> _loadCompletionPhoto() async {
    if (_issue.id == null || _issue.completionPhotoPath == null) {
      setState(() {
        _completionPhotoBytes = null;
        _isLoadingCompletionPhoto = false;
      });
      return;
    }

    setState(() => _isLoadingCompletionPhoto = true);
    try {
      final byteData = await client.issue.getCompletionPhoto(_issue.id!);
      if (mounted) {
        setState(() {
          if (byteData != null) {
            _completionPhotoBytes = byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            );
          } else {
            _completionPhotoBytes = null;
          }
          _isLoadingCompletionPhoto = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCompletionPhoto = false);
    }
  }

  Future<void> _loadAuditHistory() async {
    if (_issue.id == null) return;
    setState(() => _isLoadingAudit = true);
    try {
      final token = ClaimStorage.getClaimToken(_issue.id!);
      final list = await client.issue.getIssueAuditHistory(
        _issue.id!,
        claimToken: token,
      );
      if (mounted) {
        setState(() {
          _auditHistory = list;
          _isLoadingAudit = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAudit = false);
    }
  }

  Future<void> _attachSamplePhoto(SamplePhoto sample) async {
    if (_issue.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    setState(() => _isAttachingPhoto = true);

    try {
      final updated = await client.issue.attachIssuePhoto(
        _issue.id!,
        sample.fileName,
        sample.byteData,
        uploadToken: _issue.uploadToken,
      );
      if (mounted) {
        setState(() => _issue = updated);
        await _loadPhoto();
        widget.onIssueUpdated?.call();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Attached "${sample.name}" to issue #${_issue.id}.'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Photo attachment failed: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAttachingPhoto = false);
    }
  }

  // CITIZEN ACTIONS: Confirm Closure
  Future<void> _confirmCitizenClosure() async {
    final feedbackController = TextEditingController();
    final token = ClaimStorage.getClaimToken(_issue.id!);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Issue Resolved & Close'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'By confirming, you agree that municipal repairs have adequately resolved the reported problem.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Citizen Feedback / Notes (Optional)',
                  hintText:
                      'e.g. Great job, pothole is completely smoothed out!',
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
                backgroundColor: Colors.green.shade800,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm Fixed & Close'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final updated = await client.issue.confirmCitizenClosure(
          _issue.id!,
          claimToken: token,
          feedbackNotes: feedbackController.text.trim().isEmpty
              ? null
              : feedbackController.text.trim(),
        );
        setState(() => _issue = updated);
        await _loadAllDetails();
        widget.onIssueUpdated?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you! Case is now officially CLOSED.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to confirm closure: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // CITIZEN ACTIONS: Dispute / Reopen
  Future<void> _disputeAndReopen() async {
    final reasonController = TextEditingController();
    final token = ClaimStorage.getClaimToken(_issue.id!);

    final disputed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Dispute Resolution & Reopen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'If the problem was not adequately fixed or has recurred, state the reason to reopen the case for city crews.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Dispute / Reopen Reason *',
                  hintText:
                      'e.g. Pothole still present, water leak restarted, only partially repaired...',
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
                backgroundColor: Colors.deepOrange.shade800,
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Dispute reason is required.'),
                    ),
                  );
                  return;
                }
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Reopen Case'),
            ),
          ],
        );
      },
    );

    if (disputed == true && mounted) {
      try {
        final reason = reasonController.text.trim();
        final updated = await client.issue.reopenIssue(
          _issue.id!,
          reason,
          claimToken: token,
        );
        setState(() => _issue = updated);
        await _loadAllDetails();
        widget.onIssueUpdated?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Case REOPENED! Municipal team has been alerted.'),
              backgroundColor: Colors.deepOrange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reopen issue: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // EMPLOYEE ACTIONS: Resolve Issue Dialog
  Future<void> _handleEmployeeResolve() async {
    final notesController = TextEditingController();
    Uint8List? photoBytes;
    String? photoFileName;

    final resolved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Resolve Case #${_issue.id}'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Provide detailed completion notes and optional photographic proof.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Completion Notes *',
                          hintText:
                              'Repairs completed, tested, and cleaned up...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (photoBytes != null) ...[
                        Text(
                          'Photo: $photoFileName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton(
                          onPressed: () => setDialogState(() {
                            photoBytes = null;
                            photoFileName = null;
                          }),
                          child: const Text('Remove Photo'),
                        ),
                      ] else ...[
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Pick Image'),
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
                            ...PhotoUtils.samplePhotos.take(1).map((s) {
                              return ActionChip(
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
                  onPressed: () async {
                    final notes = notesController.text.trim();
                    if (notes.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Notes are required.')),
                      );
                      return;
                    }
                    try {
                      ByteData? byteData;
                      if (photoBytes != null) {
                        byteData = PhotoUtils.toByteData(photoBytes!);
                      }
                      await client.issue.resolveIssue(
                        _issue.id!,
                        notes,
                        completionPhotoData: byteData,
                        completionPhotoFileName: photoFileName,
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop(true);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Resolve'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resolved == true) {
      _refreshIssue();
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

  bool get _isCitizenReporter {
    if (client.auth.isAuthenticated &&
        _issue.userId != null &&
        client.auth.authInfo?.authUserId.toString() == _issue.userId) {
      return true;
    }
    if (_issue.id != null && ClaimStorage.hasClaimToken(_issue.id!)) {
      return true;
    }
    return false;
  }

  bool get _isAssignedWorker =>
      _issue.assignedEmployeeId != null &&
      (_currentUserProfile?.userId == _issue.assignedEmployeeId ||
          client.auth.authInfo?.authUserId.toString() ==
              _issue.assignedEmployeeId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _getStatusColor(_issue.status);
    final priorityColor = _getPriorityColor(_issue.priority);

    return Scaffold(
      appBar: AppBar(
        title: Text('Case #${_issue.id ?? ""} Details'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh details',
            onPressed: _isLoading ? null : _refreshIssue,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status, Priority & Category Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _issue.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Priority badge
                if (_issue.priority != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: priorityColor),
                    ),
                    child: Text(
                      'PRIORITY: ${_issue.priority!.toUpperCase()}',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),

                // Category Chip
                Chip(
                  label: Text(_issue.category),
                  avatar: const Icon(Icons.category, size: 16),
                  visualDensity: VisualDensity.compact,
                ),

                // Department Chip
                if (_issue.department != null)
                  Chip(
                    label: Text(_issue.department!),
                    avatar: const Icon(Icons.domain, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),

                Text(
                  _issue.createdAt.toLocal().toString().split('.')[0],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _issue.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Description card
            Card(
              elevation: 0,
              color: colors.surfaceContainerHighest.withAlpha(120),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Description',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      _issue.description,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assignment & Due Date Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.badge, size: 20, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Assigned Field Technician: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      _issue.assignedEmployeeName ??
                                      _issue.assignedEmployeeId ??
                                      'Unassigned',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _issue.assignedEmployeeId != null
                                        ? Colors.indigo
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_issue.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Target Completion Date: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: _issue.dueDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Coordinates (if set)
            if (_issue.latitude != null || _issue.longitude != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS: Lat ${_issue.latitude?.toStringAsFixed(4) ?? "-"}, Long ${_issue.longitude?.toStringAsFixed(4) ?? "-"}',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Rejection Banner if rejected
            if (_issue.status == 'rejected' &&
                _issue.rejectionReason != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red.shade900),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Case Rejected by Municipality',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reason: ${_issue.rejectionReason}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dispute / Reopened Banner if reopened
            if (_issue.status == 'reopened' && _issue.reopenReason != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepOrange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.replay, color: Colors.deepOrange.shade900),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Case Reopened by Citizen',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Citizen Feedback: ${_issue.reopenReason}',
                      style: TextStyle(color: Colors.deepOrange.shade900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Progress Notes card (if any)
            if (_issue.progressNotes != null &&
                _issue.progressNotes!.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.construction,
                            size: 18,
                            color: Colors.blue.shade800,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Field Crew Progress Notes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _issue.progressNotes!,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Initial Problem Photo
            Text(
              'Attached Citizen Photo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingPhoto) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_photoBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.memory(
                    _photoBytes!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Image decode error: $error'),
                    ),
                  ),
                ),
              ),
            ] else if (_photoError != null) ...[
              Text(_photoError!, style: TextStyle(color: colors.error)),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No initial photo attached to report.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    if (_isCitizenReporter) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'You reported this issue. Select a sample photo to attach:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_isAttachingPhoto)
                        const LinearProgressIndicator()
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: PhotoUtils.samplePhotos.map((sample) {
                            return ActionChip(
                              avatar: const Icon(Icons.add_a_photo, size: 14),
                              label: Text(sample.name),
                              onPressed: () => _attachSamplePhoto(sample),
                            );
                          }).toList(),
                        ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // COMPLETION EVIDENCE CARD (when resolved or closed)
            if (_issue.status == 'resolved' || _issue.status == 'closed') ...[
              Card(
                elevation: 0,
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade400, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Resolution Evidence & Work Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Staff Completion Notes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _issue.completionNotes ??
                            'Work reported completed by field staff.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Completion Photo Preview
                      if (_isLoadingCompletionPhoto) ...[
                        const CircularProgressIndicator(),
                      ] else if (_completionPhotoBytes != null) ...[
                        Text(
                          'Completion Photo Evidence:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 240),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Image.memory(
                              _completionPhotoBytes!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // CITIZEN VERIFICATION ACTION PANEL (when resolved)
            if (_issue.status == 'resolved' && _isCitizenReporter) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rate_review, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Citizen Verification Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Municipal crews have marked this case as RESOLVED. Please review the completion evidence above and confirm if the issue is fixed, or dispute it to reopen.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 420;
                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.deepOrange.shade800,
                                  side: BorderSide(
                                    color: Colors.deepOrange.shade800,
                                  ),
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                icon: const Icon(Icons.replay),
                                label: const Text('Dispute & Reopen'),
                                onPressed: _disputeAndReopen,
                              ),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Confirm Fixed (Close)'),
                                onPressed: _confirmCitizenClosure,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.deepOrange.shade800,
                                  side: BorderSide(
                                    color: Colors.deepOrange.shade800,
                                  ),
                                ),
                                icon: const Icon(Icons.replay),
                                label: const Text('Dispute & Reopen'),
                                onPressed: _disputeAndReopen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Confirm Fixed (Close)'),
                                onPressed: _confirmCitizenClosure,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // EMPLOYEE ACTION BUTTONS (if assigned worker)
            if (_isAssignedWorker && _issue.status == 'in_progress') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade300),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 400;
                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.engineering, color: Colors.teal),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You are assigned to this case. Ready to submit completion evidence?',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              minimumSize: const Size.fromHeight(42),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                            ),
                            onPressed: _handleEmployeeResolve,
                            label: const Text('Resolve Case'),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        const Icon(Icons.engineering, color: Colors.teal),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'You are assigned to this case. Ready to submit completion evidence?',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                          ),
                          onPressed: _handleEmployeeResolve,
                          child: const Text('Resolve Case'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // CHRONOLOGICAL AUDIT TIMELINE
            Text(
              'Audit Trail & Lifecycle History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingAudit) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if ((_auditHistory ?? []).isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No audit logs recorded for this case yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withAlpha(60),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.outlineVariant.withAlpha(80),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _auditHistory!.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _auditHistory![index];
                    final isCitizen = item.actorRole.toLowerCase() == 'citizen';
                    final isAdmin = item.actorRole.toLowerCase() == 'admin';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? Colors.indigo.shade100
                                  : (isCitizen
                                        ? Colors.teal.shade100
                                        : Colors.blue.shade100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.actorRole.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isAdmin
                                    ? Colors.indigo.shade900
                                    : (isCitizen
                                          ? Colors.teal.shade900
                                          : Colors.blue.shade900),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 2,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: item.action.replaceAll('_', ' '),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          if (item.previousStatus != null &&
                                              item.newStatus != null)
                                            TextSpan(
                                              text:
                                                  ' (${item.previousStatus} → ${item.newStatus})',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.normal,
                                                color: colors.onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      item.timestamp.toLocal().toString().split(
                                        '.',
                                      )[0],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.notes != null &&
                                    item.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.notes!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
