import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart';
import 'audit_service.dart';
import 'claim_service.dart';
import 'notification_service.dart';
import 'role_service.dart';

/// Centralized state machine service managing issue status transitions,
/// role authorization, notifications, and audit logging.
class IssueLifecycleService {
  final RoleService roleService;
  final AuditService auditService;
  final NotificationService notificationService;
  final ClaimService claimService;

  const IssueLifecycleService({
    this.roleService = const RoleService(),
    this.auditService = const AuditService(),
    this.notificationService = const NotificationService(),
    this.claimService = const ClaimService(),
  });

  /// Status constants
  static const String statusOpen = 'open';
  static const String statusAssigned = 'assigned';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';
  static const String statusReopened = 'reopened';
  static const String statusRejected = 'rejected';

  static const Set<String> validStatuses = {
    statusOpen,
    statusAssigned,
    statusInProgress,
    statusResolved,
    statusClosed,
    statusReopened,
    statusRejected,
  };

  /// Verifies that caller owns [issue] (either as authenticated user or via [claimToken]).
  bool verifyCitizenOwnership(
    Session session,
    Issue issue, {
    String? claimToken,
  }) {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId != null &&
        issue.userId != null &&
        issue.userId == currentUserId) {
      return true;
    }
    if (claimService.verifyClaim(session, issue, claimToken)) {
      return true;
    }
    return false;
  }

  /// Admin assigns or reassigns an issue to an eligible employee.
  Future<Issue> assignIssue(
    Session session,
    int issueId,
    String employeeUserId, {
    DateTime? dueDate,
    String? priority,
    String? department,
    String? notes,
  }) async {
    final callerIsAdmin = await roleService.isAdmin(session);
    if (!callerIsAdmin) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can assign cases to employees.',
      );
    }

    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    // Allowed source states: open, assigned, in_progress, reopened
    if (issue.status != statusOpen &&
        issue.status != statusAssigned &&
        issue.status != statusInProgress &&
        issue.status != statusReopened) {
      throw StateError(
        'Cannot assign case #${issue.id} in "${issue.status}" status.',
      );
    }

    final trimmedEmployee = employeeUserId.trim();
    if (trimmedEmployee.isEmpty) {
      throw ArgumentError.value(
        employeeUserId,
        'employeeUserId',
        'Employee user ID cannot be empty.',
      );
    }

    // Verify target employee exists and is active
    final employeeRole = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedEmployee) | t.email.equals(trimmedEmployee),
    );
    if (employeeRole != null && !employeeRole.isActive) {
      throw ArgumentError.value(
        employeeUserId,
        'employeeUserId',
        'Target employee account is disabled and cannot receive assignments.',
      );
    }

    final employeeName = employeeRole?.fullName ?? trimmedEmployee;
    final effectiveDept = department?.trim() ?? employeeRole?.department ?? issue.department;
    final previousStatus = issue.status;
    final now = DateTime.now();

    final updated = issue.copyWith(
      status: statusAssigned,
      assignedEmployeeId: trimmedEmployee,
      assignedEmployeeName: employeeName,
      assignedAt: now,
      dueDate: dueDate ?? issue.dueDate,
      priority: priority?.trim() ?? issue.priority,
      department: effectiveDept,
    );
    final saved = await Issue.db.updateRow(session, updated);

    // Record audit
    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: previousStatus == statusAssigned ? 'reassigned' : 'assigned',
      previousStatus: previousStatus,
      newStatus: statusAssigned,
      notes: notes ?? 'Assigned to $employeeName ($trimmedEmployee).',
    );

    // Notify employee
    await notificationService.createNotification(
      session,
      recipientId: trimmedEmployee,
      issueId: issueId,
      type: 'assignment',
      title: 'New Case Assigned (#$issueId)',
      message: 'You were assigned to "${issue.title}". Department: ${effectiveDept ?? "General"}.',
    );

    // Notify citizen if registered
    if (issue.userId != null && issue.userId!.isNotEmpty) {
      await notificationService.createNotification(
        session,
        recipientId: issue.userId!,
        issueId: issueId,
        type: 'case_update',
        title: 'Report #${issue.id} Assigned',
        message: 'Your report "${issue.title}" has been assigned for repair.',
      );
    }

    return saved;
  }

  /// Helper to check if caller is the assigned employee (by ID or email) or an administrator.
  Future<bool> _isAssignedEmployeeOrAdmin(Session session, Issue issue) async {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId == null || currentUserId.trim().isEmpty) return false;
    final trimmedId = currentUserId.trim();
    if (issue.assignedEmployeeId == trimmedId) return true;
    if (await roleService.isAdmin(session)) return true;

    // Check if the assigned ID matches the user's registered email
    try {
      final uuid = UuidValue.fromString(trimmedId);
      final emailAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(uuid),
      );
      if (emailAcc != null && issue.assignedEmployeeId == emailAcc.email) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Assigned employee marks work as in-progress.
  Future<Issue> startWork(
    Session session,
    int issueId, {
    String? notes,
  }) async {
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    final authorized = await _isAssignedEmployeeOrAdmin(session, issue);
    if (!authorized) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only the assigned employee can start work on this case.',
      );
    }

    if (issue.status != statusAssigned) {
      throw StateError(
        'Cannot start work on case #${issue.id} in "${issue.status}" status (must be "assigned").',
      );
    }

    final updated = issue.copyWith(
      status: statusInProgress,
      progressNotes: notes?.trim() ?? issue.progressNotes,
    );
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: 'work_started',
      previousStatus: statusAssigned,
      newStatus: statusInProgress,
      notes: notes ?? 'Employee started work.',
    );

    if (issue.userId != null && issue.userId!.isNotEmpty) {
      await notificationService.createNotification(
        session,
        recipientId: issue.userId!,
        issueId: issueId,
        type: 'case_update',
        title: 'Work In Progress (#$issueId)',
        message: 'Staff has started work on your report "${issue.title}".',
      );
    }

    return saved;
  }

  /// Assigned employee adds a progress note.
  Future<Issue> addProgressNote(
    Session session,
    int issueId,
    String note,
  ) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(note, 'note', 'Progress note cannot be empty.');
    }

    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    final authorized = await _isAssignedEmployeeOrAdmin(session, issue);
    if (!authorized) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only the assigned employee can add progress notes.',
      );
    }

    final timestamp = DateTime.now().toIso8601String().substring(0, 16).replaceAll('T', ' ');
    final appended = (issue.progressNotes != null && issue.progressNotes!.isNotEmpty)
        ? '${issue.progressNotes}\n[$timestamp] $trimmed'
        : '[$timestamp] $trimmed';

    final updated = issue.copyWith(progressNotes: appended);
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: 'progress_note_added',
      previousStatus: issue.status,
      newStatus: issue.status,
      notes: trimmed,
    );

    return saved;
  }

  /// Assigned employee submits resolution, completion notes, and optional completion photo.
  Future<Issue> resolveIssue(
    Session session,
    int issueId,
    String completionNotes, {
    String? completionPhotoPath,
  }) async {
    final trimmedNotes = completionNotes.trim();
    if (trimmedNotes.isEmpty) {
      throw ArgumentError.value(
        completionNotes,
        'completionNotes',
        'Completion notes are required to resolve an issue.',
      );
    }

    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    final authorized = await _isAssignedEmployeeOrAdmin(session, issue);
    if (!authorized) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only the assigned employee can mark a case as resolved.',
      );
    }

    if (issue.status != statusInProgress) {
      throw StateError(
        'Cannot resolve case #${issue.id} from "${issue.status}" status (must be "in_progress").',
      );
    }

    final now = DateTime.now();
    final updated = issue.copyWith(
      status: statusResolved,
      completionNotes: trimmedNotes,
      completionPhotoPath: completionPhotoPath ?? issue.completionPhotoPath,
      resolvedAt: now,
    );
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: 'resolved',
      previousStatus: statusInProgress,
      newStatus: statusResolved,
      notes: trimmedNotes,
    );

    // Notify citizen to inspect and confirm
    if (issue.userId != null && issue.userId!.isNotEmpty) {
      await notificationService.createNotification(
        session,
        recipientId: issue.userId!,
        issueId: issueId,
        type: 'case_resolved',
        title: 'Report #${issue.id} Marked Resolved',
        message: 'Work is completed on "${issue.title}". Please verify and confirm closure.',
      );
    }

    return saved;
  }

  /// Citizen (owner or verified anonymous claim) confirms fix and closes the case.
  Future<Issue> confirmCitizenClosure(
    Session session,
    int issueId, {
    String? claimToken,
    String? feedbackNotes,
  }) async {
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    final isOwner = verifyCitizenOwnership(session, issue, claimToken: claimToken);
    if (!isOwner) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only the citizen who reported this issue can confirm closure.',
      );
    }

    if (issue.status != statusResolved) {
      throw StateError(
        'Cannot close case #${issue.id} from "${issue.status}" status (must be "resolved").',
      );
    }

    final now = DateTime.now();
    final updated = issue.copyWith(
      status: statusClosed,
      closedAt: now,
    );
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: 'closed_by_citizen',
      previousStatus: statusResolved,
      newStatus: statusClosed,
      notes: feedbackNotes?.trim() ?? 'Citizen confirmed resolution.',
    );

    // Notify employee
    if (issue.assignedEmployeeId != null) {
      await notificationService.createNotification(
        session,
        recipientId: issue.assignedEmployeeId!,
        issueId: issueId,
        type: 'case_closed',
        title: 'Case #${issue.id} Closed',
        message: 'Citizen confirmed resolution for case "${issue.title}".',
      );
    }

    return saved;
  }

  /// Citizen (owner or verified anonymous claim) disputes resolution and reopens case.
  Future<Issue> reopenIssue(
    Session session,
    int issueId,
    String reason, {
    String? claimToken,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'A reason is required to dispute resolution and reopen a case.',
      );
    }

    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    final isOwner = verifyCitizenOwnership(session, issue, claimToken: claimToken);
    if (!isOwner) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only the citizen who reported this issue can reopen it.',
      );
    }

    if (issue.status != statusResolved && issue.status != statusClosed) {
      throw StateError(
        'Cannot reopen case #${issue.id} from "${issue.status}" status (must be "resolved" or "closed").',
      );
    }

    final now = DateTime.now();
    final updated = issue.copyWith(
      status: statusReopened,
      reopenReason: trimmedReason,
      reopenedAt: now,
    );
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: 'reopened_by_citizen',
      previousStatus: issue.status,
      newStatus: statusReopened,
      notes: trimmedReason,
    );

    // Notify assigned employee if still assigned
    if (issue.assignedEmployeeId != null) {
      await notificationService.createNotification(
        session,
        recipientId: issue.assignedEmployeeId!,
        issueId: issueId,
        type: 'case_reopened',
        title: 'Case #${issue.id} Reopened by Citizen',
        message: 'Citizen reopened "${issue.title}": $trimmedReason',
      );
    }

    return saved;
  }

  /// Administrator rejects an invalid or duplicate report with required reason.
  Future<Issue> rejectIssue(
    Session session,
    int issueId,
    String reason,
  ) async {
    final callerIsAdmin = await roleService.isAdmin(session);
    if (!callerIsAdmin) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can reject reports.',
      );
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'A reason is required to reject a report.',
      );
    }

    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }

    if (issue.status != statusOpen && issue.status != statusReopened) {
      throw StateError(
        'Cannot reject case #${issue.id} from "${issue.status}" status (must be "open" or "reopened").',
      );
    }

    final now = DateTime.now();
    final updated = issue.copyWith(
      status: statusRejected,
      rejectionReason: trimmedReason,
      rejectedAt: now,
    );
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: issueId,
      action: 'rejected_by_admin',
      previousStatus: issue.status,
      newStatus: statusRejected,
      notes: trimmedReason,
    );

    if (issue.userId != null && issue.userId!.isNotEmpty) {
      await notificationService.createNotification(
        session,
        recipientId: issue.userId!,
        issueId: issueId,
        type: 'case_rejected',
        title: 'Report #${issue.id} Rejected',
        message: 'Your report "${issue.title}" was rejected: $trimmedReason',
      );
    }

    return saved;
  }
}
