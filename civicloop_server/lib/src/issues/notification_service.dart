import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Service managing persistent in-app notifications.
class NotificationService {
  const NotificationService();

  /// Creates and persists an in-app notification for [recipientId].
  Future<CivicNotification> createNotification(
    Session session, {
    required String recipientId,
    required int issueId,
    required String type,
    required String title,
    required String message,
  }) async {
    final notification = CivicNotification(
      recipientId: recipientId.trim(),
      issueId: issueId,
      type: type.trim(),
      title: title.trim(),
      message: message.trim(),
      isRead: false,
      createdAt: DateTime.now(),
    );
    return await CivicNotification.db.insertRow(session, notification);
  }

  /// Retrieves notifications for [recipientId], ordered newest first.
  Future<List<CivicNotification>> getNotifications(
    Session session,
    String recipientId, {
    bool? unreadOnly,
    int limit = 50,
  }) async {
    final trimmedId = recipientId.trim();
    if (trimmedId.isEmpty) return [];

    return await CivicNotification.db.find(
      session,
      where: (t) {
        var expr = t.recipientId.equals(trimmedId);
        if (unreadOnly == true) {
          expr = expr & t.isRead.equals(false);
        }
        return expr;
      },
      orderByList: (t) => [t.createdAt.desc()],
      limit: limit,
    );
  }

  /// Marks a specific notification as read if owned by [recipientId].
  Future<bool> markAsRead(
    Session session,
    int notificationId,
    String recipientId,
  ) async {
    final notification = await CivicNotification.db.findById(
      session,
      notificationId,
    );
    if (notification == null ||
        notification.recipientId != recipientId.trim()) {
      return false;
    }
    if (notification.isRead) {
      return true;
    }

    final updated = notification.copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
    await CivicNotification.db.updateRow(session, updated);
    return true;
  }

  /// Marks all unread notifications for [recipientId] as read.
  Future<int> markAllAsRead(
    Session session,
    String recipientId,
  ) async {
    final unread = await CivicNotification.db.find(
      session,
      where: (t) =>
          t.recipientId.equals(recipientId.trim()) & t.isRead.equals(false),
    );

    final now = DateTime.now();
    for (final n in unread) {
      await CivicNotification.db.updateRow(
        session,
        n.copyWith(isRead: true, readAt: now),
      );
    }
    return unread.length;
  }

  /// Returns the count of unread notifications for [recipientId].
  Future<int> getUnreadCount(
    Session session,
    String recipientId,
  ) async {
    return await CivicNotification.db.count(
      session,
      where: (t) =>
          t.recipientId.equals(recipientId.trim()) & t.isRead.equals(false),
    );
  }
}
