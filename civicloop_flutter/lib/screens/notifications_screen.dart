import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import 'issue_detail_screen.dart';

/// Full screen view for user notifications, used in role-based navigation.
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onNotificationsUpdated;

  const NotificationsScreen({super.key, this.onNotificationsUpdated});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<CivicNotification>? _notifications;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await client.issue.getNotifications(limit: 50);
      if (mounted) {
        setState(() {
          _notifications = list;
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

  Future<void> _markAllRead() async {
    try {
      await client.issue.markAllNotificationsRead();
      await _loadNotifications();
      widget.onNotificationsUpdated?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read: $e')),
        );
      }
    }
  }

  Future<void> _openNotification(CivicNotification item) async {
    if (!item.isRead && item.id != null) {
      try {
        await client.issue.markNotificationRead(item.id!);
        _loadNotifications();
        widget.onNotificationsUpdated?.call();
      } catch (_) {}
    }

    if (mounted) {
      try {
        final issue = await client.issue.getIssueById(item.issueId);
        if (issue != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IssueDetailScreen(issue: issue),
            ),
          );
        }
      } catch (_) {}
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Icons.assignment_ind;
      case 'case_resolved':
        return Icons.task_alt;
      case 'case_closed':
        return Icons.check_circle;
      case 'case_reopened':
        return Icons.replay;
      case 'case_rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Colors.indigo;
      case 'case_resolved':
        return Colors.green;
      case 'case_closed':
        return Colors.grey.shade700;
      case 'case_reopened':
        return Colors.deepOrange;
      case 'case_rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unreadCount = _notifications?.where((n) => !n.isRead).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_outlined, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllRead,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading && _notifications == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load notifications: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loadNotifications,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : (_notifications ?? []).isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updates on your assigned tasks, status changes, and announcements will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.separated(
                itemCount: _notifications!.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _notifications![index];
                  final color = _getNotificationColor(item.type);
                  final icon = _getNotificationIcon(item.type);

                  return ListTile(
                    tileColor: item.isRead
                        ? null
                        : colors.primaryContainer.withAlpha(20),
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha(30),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          item.message,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Case #${item.issueId}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${item.createdAt.toLocal().toString().split(".")[0]}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: !item.isRead
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary,
                            ),
                          )
                        : null,
                    onTap: () => _openNotification(item),
                  );
                },
              ),
            ),
    );
  }
}
