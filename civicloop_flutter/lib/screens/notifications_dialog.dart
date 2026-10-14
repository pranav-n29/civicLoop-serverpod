import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import 'issue_detail_screen.dart';

/// Modal dialog showing user notifications and case updates.
class NotificationsDialog extends StatefulWidget {
  final VoidCallback? onNotificationsUpdated;

  const NotificationsDialog({super.key, this.onNotificationsUpdated});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const NotificationsDialog(),
    );
  }

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
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
      final list = await client.issue.getNotifications(limit: 40);
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
          Navigator.of(context).pop();
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

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Notifications'),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 420,
        child: _isLoading && _notifications == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(
                  'Failed to load notifications: $_errorMessage',
                  style: TextStyle(color: colors.error),
                ),
              )
            : (_notifications ?? []).isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 52,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No notifications yet',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updates on your assigned tasks or reported issues will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.separated(
                  itemCount: _notifications!.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notif = _notifications![index];
                    final icon = _getNotificationIcon(notif.type);
                    final color = _getNotificationColor(notif.type);

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withAlpha(30),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      title: Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: notif.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        notif.createdAt.toLocal().toString().split('.')[0],
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      trailing: !notif.isRead
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () => _openNotification(notif),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
