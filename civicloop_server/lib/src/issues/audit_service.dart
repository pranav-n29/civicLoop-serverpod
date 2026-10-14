import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'role_service.dart';

/// Service managing persistent audit logging for civic issues.
class AuditService {
  final RoleService roleService;
  const AuditService({this.roleService = const RoleService()});

  /// Records an audit log entry for [issueId].
  ///
  /// Derives [actorId] and [actorRole] from the authenticated session if not provided.
  Future<CivicIssueAudit> recordAudit(
    Session session, {
    required int issueId,
    required String action,
    String? previousStatus,
    String? newStatus,
    String? notes,
    String? actorId,
    String? actorRole,
    String? actorName,
  }) async {
    final effectiveActorId = actorId ??
        session.authenticated?.userIdentifier ??
        'anonymous';

    final effectiveActorRole = actorRole ??
        (session.authenticated != null
            ? await roleService.getRole(session, effectiveActorId)
            : 'anonymous');

    final auditEntry = CivicIssueAudit(
      issueId: issueId,
      actorId: effectiveActorId,
      actorRole: effectiveActorRole,
      actorName: actorName,
      action: action.trim(),
      previousStatus: previousStatus,
      newStatus: newStatus,
      notes: notes?.trim(),
      timestamp: DateTime.now(),
    );

    return await CivicIssueAudit.db.insertRow(session, auditEntry);
  }

  /// Retrieves the complete chronological audit history for [issueId].
  Future<List<CivicIssueAudit>> getHistory(
    Session session,
    int issueId,
  ) async {
    if (issueId <= 0) return [];
    return await CivicIssueAudit.db.find(
      session,
      where: (t) => t.issueId.equals(issueId),
      orderByList: (t) => [t.timestamp.asc()],
    );
  }
}
