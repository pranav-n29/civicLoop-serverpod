import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart';
import 'audit_service.dart';
import 'claim_service.dart';
import 'issue_lifecycle_service.dart';
import 'notification_service.dart';
import 'role_service.dart';

/// Endpoint for creating, listing, retrieving, and managing civic issues,
/// lifecycle state transitions, role-based workflows, audit history, and notifications.
class IssueEndpoint extends Endpoint {
  final RoleService roleService;
  final NotificationService notificationService;
  final AuditService auditService;
  final ClaimService claimService;
  final IssueLifecycleService lifecycleService;

  IssueEndpoint({
    this.roleService = const RoleService(),
    this.notificationService = const NotificationService(),
    this.auditService = const AuditService(),
    this.claimService = const ClaimService(),
    this.lifecycleService = const IssueLifecycleService(),
  });

  /// Creates a new civic issue.
  ///
  /// Validates required text fields, ignores any client-supplied ID, status,
  /// or createdAt timestamp, sets [createdAt] to current server time and
  /// [status] to 'open', and persists the record to the database.
  /// Generates and returns an upload authorization token for photo upload.
  /// For anonymous reports, generates a secure claim token and stores its SHA-256 hash.
  Future<Issue> createIssue(Session session, Issue issue) async {
    final title = issue.title.trim();
    final description = issue.description.trim();
    final category = issue.category.trim();

    if (title.isEmpty) {
      throw ArgumentError.value(issue.title, 'title', 'Title cannot be empty.');
    }
    if (description.isEmpty) {
      throw ArgumentError.value(
        issue.description,
        'description',
        'Description cannot be empty.',
      );
    }
    if (category.isEmpty) {
      throw ArgumentError.value(
        issue.category,
        'category',
        'Category cannot be empty.',
      );
    }
    if (issue.latitude != null &&
        (issue.latitude! < -90.0 || issue.latitude! > 90.0)) {
      throw ArgumentError.value(
        issue.latitude,
        'latitude',
        'Latitude must be between -90 and 90.',
      );
    }
    if (issue.longitude != null &&
        (issue.longitude! < -180.0 || issue.longitude! > 180.0)) {
      throw ArgumentError.value(
        issue.longitude,
        'longitude',
        'Longitude must be between -180 and 180.',
      );
    }

    final authUserId = session.authenticated?.userIdentifier;

    if (session.authenticated != null && authUserId != null) {
      if (isOfficialOrAdmin(session)) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message:
              'Only citizen users can submit civic issue reports. Staff and administrators are not permitted to submit citizen reports.',
        );
      }
      final role = await roleService.getRole(session, authUserId);
      if (role == RoleService.roleAdmin || role == RoleService.roleEmployee) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message:
              'Only citizen users can submit civic issue reports. Staff and administrators are not permitted to submit citizen reports.',
        );
      }
    }

    final now = DateTime.now();

    final newIssue = Issue(
      title: title,
      description: description,
      category: category,
      status: 'open',
      createdAt: now,
      latitude: issue.latitude,
      longitude: issue.longitude,
      userId: authUserId,
      priority: issue.priority?.trim() ?? 'medium',
      department: issue.department?.trim(),
    );

    final created = await Issue.db.insertRow(session, newIssue);
    final uploadToken = generateUploadToken(session, created.id!);

    String? claimToken;
    Issue issueToReturn = created.copyWith(uploadToken: uploadToken);

    if (authUserId == null) {
      final (rawToken, tokenHash) = claimService.generateClaimToken(
        created.id!,
      );
      final updatedWithClaim = created.copyWith(claimHash: tokenHash);
      await Issue.db.updateRow(session, updatedWithClaim);
      claimToken = rawToken;
      issueToReturn = updatedWithClaim.copyWith(
        uploadToken: uploadToken,
        claimToken: claimToken,
      );
    }

    await auditService.recordAudit(
      session,
      issueId: created.id!,
      action: 'created',
      newStatus: 'open',
      notes: 'Civic issue report created.',
    );

    return issueToReturn;
  }

  /// Checks whether the caller is an authenticated municipal official or administrator.
  static bool isOfficialOrAdmin(Session session) {
    final auth = session.authenticated;
    if (auth == null) {
      return false;
    }

    // 1. Scopes check (Scope.admin or Scope('official'))
    if (auth.scopes.contains(Scope.admin) ||
        auth.scopes.contains(const Scope('official')) ||
        auth.scopes.any((s) => s.name == 'official' || s.name == 'admin')) {
      return true;
    }

    final userId = auth.userIdentifier.trim();
    if (userId.isEmpty) {
      return false;
    }

    // 2. Check configured official user IDs list from session passwords or environment
    String? officialIdsConfig;
    try {
      officialIdsConfig = session.passwords['officialUserIds'];
    } catch (_) {}
    if (officialIdsConfig == null || officialIdsConfig.trim().isEmpty) {
      try {
        officialIdsConfig = session.serverpod.getPassword('officialUserIds');
      } catch (_) {}
    }
    if (officialIdsConfig == null || officialIdsConfig.trim().isEmpty) {
      officialIdsConfig = Platform.environment['OFFICIAL_USER_IDS'];
    }
    if (officialIdsConfig != null && officialIdsConfig.trim().isNotEmpty) {
      final ids = officialIdsConfig
          .split(',')
          .map((id) => id.trim().toLowerCase())
          .where((id) => id.isNotEmpty)
          .toSet();
      if (ids.contains(userId.toLowerCase())) {
        return true;
      }
    }

    // 3. Check configured official domain (defaults to official.civicloop)
    String? officialDomain;
    try {
      officialDomain = session.passwords['officialDomain'];
    } catch (_) {}
    if (officialDomain == null || officialDomain.trim().isEmpty) {
      try {
        officialDomain = session.serverpod.getPassword('officialDomain');
      } catch (_) {}
    }
    if (officialDomain == null || officialDomain.trim().isEmpty) {
      officialDomain = Platform.environment['OFFICIAL_DOMAIN'];
    }
    final effectiveDomain =
        (officialDomain != null && officialDomain.trim().isNotEmpty)
        ? officialDomain.trim().toLowerCase()
        : 'official.civicloop';

    final normalizedDomain = effectiveDomain.startsWith('@')
        ? effectiveDomain
        : '@$effectiveDomain';

    if (userId.toLowerCase().endsWith(normalizedDomain)) {
      return true;
    }

    // 4. Standard official demo identifiers
    final lowerId = userId.toLowerCase();
    if (lowerId == 'official' ||
        lowerId == 'admin' ||
        lowerId.startsWith('official_') ||
        lowerId.startsWith('official-')) {
      return true;
    }

    return false;
  }

  /// Redacts [Issue.userId] (sets to null) unless the caller is an official/admin
  /// or the owner of the issue.
  static Issue redactIssuePrivacy(Session session, Issue issue) {
    if (issue.userId == null) {
      return issue;
    }
    if (isOfficialOrAdmin(session)) {
      return issue;
    }
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId != null && currentUserId == issue.userId) {
      return issue;
    }
    return issue.copyWith(userId: null);
  }

  /// Retrieves all civic issues ordered newest first for public viewing.
  Future<List<Issue>> getIssues(Session session) async {
    final issues = await Issue.db.find(
      session,
      orderByList: (t) => [t.createdAt.desc()],
    );
    return issues.map((issue) => redactIssuePrivacy(session, issue)).toList();
  }

  /// Retrieves all civic issues submitted by the currently authenticated user.
  Future<List<Issue>> getMyIssues(Session session) async {
    final authUserId = session.authenticated?.userIdentifier;
    if (authUserId == null || authUserId.trim().isEmpty) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
        message: 'User must be authenticated to retrieve their issues.',
      );
    }

    return await Issue.db.find(
      session,
      where: (t) => t.userId.equals(authUserId),
      orderByList: (t) => [t.createdAt.desc()],
    );
  }

  /// Retrieves a civic issue by its [id].
  ///
  /// Supports optional [claimToken] for anonymous reporters.
  Future<Issue?> getIssueById(
    Session session,
    int id, {
    String? claimToken,
  }) async {
    if (id <= 0) {
      return null;
    }
    final issue = await Issue.db.findById(session, id);
    if (issue == null) {
      return null;
    }

    final isStaff = await roleService.isStaff(session);
    if (isStaff || isOfficialOrAdmin(session)) {
      return issue;
    }

    final isClaimant = claimService.verifyClaim(session, issue, claimToken);
    if (isClaimant) {
      return issue;
    }

    return redactIssuePrivacy(session, issue);
  }

  /// Updates the status of an existing civic issue (kept for compatibility with officials).
  Future<Issue?> updateIssueStatus(
    Session session,
    int id,
    String status,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
        message: 'Authentication required to update issue status.',
      );
    }

    if (id <= 0) {
      throw ArgumentError.value(
        id,
        'id',
        'Issue ID must be a positive integer.',
      );
    }
    if (!validStatuses.contains(status)) {
      throw ArgumentError.value(
        status,
        'status',
        'Invalid status "$status". Allowed statuses: open, in_progress, resolved, closed.',
      );
    }

    if (!isOfficialOrAdmin(session)) {
      bool isStaff = false;
      try {
        isStaff = await roleService.isStaff(session);
      } catch (_) {}
      if (!isStaff) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message:
              'Only municipal officials or administrators can update issue statuses.',
        );
      }
    }

    final existing = await Issue.db.findById(session, id);
    if (existing == null) {
      return null;
    }

    final previousStatus = existing.status;
    final updated = existing.copyWith(status: status);
    final saved = await Issue.db.updateRow(session, updated);

    await auditService.recordAudit(
      session,
      issueId: id,
      action: 'status_updated',
      previousStatus: previousStatus,
      newStatus: status,
    );

    return saved;
  }

  // --- Admin Dashboard & Case Management Endpoints ---

  /// Admin endpoint to retrieve all cases with filtering, search, and pagination.
  Future<List<Issue>> getAdminIssues(
    Session session, {
    String? status,
    String? category,
    String? department,
    String? priority,
    String? assignedEmployeeId,
    String? search,
    int? limit,
    int? offset,
  }) async {
    final callerIsAdmin = await roleService.isAdmin(session);
    if (!callerIsAdmin && !isOfficialOrAdmin(session)) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can access admin issue list.',
      );
    }

    return await Issue.db.find(
      session,
      where: (t) {
        var expr = t.id.notEquals(-1);
        if (status != null && status.trim().isNotEmpty && status != 'all') {
          expr = expr & t.status.equals(status.trim());
        }
        if (category != null &&
            category.trim().isNotEmpty &&
            category != 'all') {
          expr = expr & t.category.equals(category.trim());
        }
        if (department != null &&
            department.trim().isNotEmpty &&
            department != 'all') {
          expr = expr & t.department.equals(department.trim());
        }
        if (priority != null &&
            priority.trim().isNotEmpty &&
            priority != 'all') {
          expr = expr & t.priority.equals(priority.trim());
        }
        if (assignedEmployeeId != null &&
            assignedEmployeeId.trim().isNotEmpty) {
          expr = expr & t.assignedEmployeeId.equals(assignedEmployeeId.trim());
        }
        if (search != null && search.trim().isNotEmpty) {
          final s = search.trim();
          final idNum = int.tryParse(s);
          if (idNum != null) {
            expr = expr & (t.id.equals(idNum) | t.title.like('%$s%'));
          } else {
            expr = expr & (t.title.like('%$s%') | t.description.like('%$s%'));
          }
        }
        return expr;
      },
      orderByList: (t) => [t.createdAt.desc()],
      limit: limit ?? 50,
      offset: offset ?? 0,
    );
  }

  /// Admin endpoint to retrieve aggregated dashboard statistics.
  Future<AdminDashboardStats> getAdminStats(Session session) async {
    final callerIsAdmin = await roleService.isAdmin(session);
    if (!callerIsAdmin && !isOfficialOrAdmin(session)) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can access admin dashboard statistics.',
      );
    }

    final total = await Issue.db.count(session);
    final open = await Issue.db.count(
      session,
      where: (t) => t.status.equals('open'),
    );
    final assigned = await Issue.db.count(
      session,
      where: (t) => t.status.equals('assigned'),
    );
    final inProgress = await Issue.db.count(
      session,
      where: (t) => t.status.equals('in_progress'),
    );
    final resolved = await Issue.db.count(
      session,
      where: (t) => t.status.equals('resolved'),
    );
    final closed = await Issue.db.count(
      session,
      where: (t) => t.status.equals('closed'),
    );
    final reopened = await Issue.db.count(
      session,
      where: (t) => t.status.equals('reopened'),
    );
    final rejected = await Issue.db.count(
      session,
      where: (t) => t.status.equals('rejected'),
    );

    final now = DateTime.now();
    final overdue = await Issue.db.count(
      session,
      where: (t) =>
          (t.status.equals('assigned') | t.status.equals('in_progress')) &
          (t.dueDate < now),
    );

    return AdminDashboardStats(
      totalReports: total,
      openReports: open,
      assignedReports: assigned,
      inProgressReports: inProgress,
      resolvedReports: resolved,
      closedReports: closed,
      reopenedReports: reopened,
      rejectedReports: rejected,
      overdueReports: overdue,
    );
  }

  /// Admin assigns or reassigns an issue to an employee.
  Future<Issue> assignIssue(
    Session session,
    int issueId,
    String employeeUserId, {
    DateTime? dueDate,
    String? priority,
    String? department,
    String? notes,
  }) async {
    return await lifecycleService.assignIssue(
      session,
      issueId,
      employeeUserId,
      dueDate: dueDate,
      priority: priority,
      department: department,
      notes: notes,
    );
  }

  /// Admin rejects an invalid or duplicate issue with required reason.
  Future<Issue> rejectIssue(
    Session session,
    int issueId,
    String reason,
  ) async {
    return await lifecycleService.rejectIssue(session, issueId, reason);
  }

  // --- Employee Work Management Endpoints ---

  /// Employee endpoint to retrieve cases assigned to the authenticated employee.
  Future<List<Issue>> getEmployeeAssignedIssues(Session session) async {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
        message: 'Authentication required to view assigned cases.',
      );
    }

    final isStaff = await roleService.isStaff(session);
    if (!isStaff && !isOfficialOrAdmin(session)) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only staff and employees can access assigned cases.',
      );
    }

    final trimmedId = currentUserId.trim();
    String? employeeEmail;
    String? employeeId;
    try {
      final roleRecord = await roleService.findRoleRecord(session, trimmedId);
      employeeEmail = roleRecord?.email;
      employeeId = roleRecord?.employeeId;
    } catch (_) {}
    if (employeeEmail == null) {
      try {
        final uuid = UuidValue.fromString(trimmedId);
        final emailAcc = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (emailAcc != null) {
          employeeEmail = emailAcc.email.trim();
        }
      } catch (_) {}
    }

    return await Issue.db.find(
      session,
      where: (t) =>
          t.assignedEmployeeId.equals(trimmedId) |
          (employeeEmail != null
              ? t.assignedEmployeeId.equals(employeeEmail)
              : t.id.equals(-1)) |
          (employeeId != null
              ? t.assignedEmployeeId.equals(employeeId)
              : t.id.equals(-1)),
      orderByList: (t) => [t.createdAt.desc()],
    );
  }

  /// Employee marks case as in-progress.
  Future<Issue> startWork(
    Session session,
    int issueId, {
    String? notes,
  }) async {
    return await lifecycleService.startWork(session, issueId, notes: notes);
  }

  /// Employee adds a progress note.
  Future<Issue> addProgressNote(
    Session session,
    int issueId,
    String note,
  ) async {
    return await lifecycleService.addProgressNote(session, issueId, note);
  }

  /// Employee submits resolution with completion notes and optional completion photo.
  Future<Issue> resolveIssue(
    Session session,
    int issueId,
    String completionNotes, {
    String? completionPhotoPath,
    ByteData? completionPhotoData,
    String? completionPhotoFileName,
  }) async {
    String? effectivePhotoPath = completionPhotoPath;
    if (completionPhotoData != null && completionPhotoFileName != null) {
      final ext = validateAndExtractExtension(completionPhotoFileName);
      if (completionPhotoData.lengthInBytes > maxPhotoBytes) {
        throw ArgumentError.value(
          completionPhotoData.lengthInBytes,
          'completionPhotoData',
          'Completion photo exceeds maximum allowed size of 5 MB.',
        );
      }
      final storagePath = 'issues/$issueId/completion.$ext';
      await session.storage.storeFile(
        storageId: 'public',
        path: storagePath,
        byteData: completionPhotoData,
      );
      effectivePhotoPath = storagePath;
    }

    return await lifecycleService.resolveIssue(
      session,
      issueId,
      completionNotes,
      completionPhotoPath: effectivePhotoPath,
    );
  }

  // --- Citizen Closure & Reopen Endpoints ---

  /// Citizen confirms fixed and closes the case.
  Future<Issue> confirmCitizenClosure(
    Session session,
    int issueId, {
    String? claimToken,
    String? feedbackNotes,
  }) async {
    return await lifecycleService.confirmCitizenClosure(
      session,
      issueId,
      claimToken: claimToken,
      feedbackNotes: feedbackNotes,
    );
  }

  /// Citizen disputes resolution and reopens the case with required reason.
  Future<Issue> reopenIssue(
    Session session,
    int issueId,
    String reason, {
    String? claimToken,
  }) async {
    return await lifecycleService.reopenIssue(
      session,
      issueId,
      reason,
      claimToken: claimToken,
    );
  }

  // --- Audit History & Notifications Endpoints ---

  /// Retrieves chronological audit history for an issue.
  Future<List<CivicIssueAudit>> getIssueAuditHistory(
    Session session,
    int issueId, {
    String? claimToken,
  }) async {
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null) {
      return [];
    }

    final isStaff = await roleService.isStaff(session);
    final isOwner = lifecycleService.verifyCitizenOwnership(
      session,
      issue,
      claimToken: claimToken,
    );

    if (!isStaff && !isOwner && !isOfficialOrAdmin(session)) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only issue participants can view audit history.',
      );
    }

    return await auditService.getHistory(session, issueId);
  }

  /// Retrieves in-app notifications for the authenticated user.
  Future<List<CivicNotification>> getNotifications(
    Session session, {
    bool? unreadOnly,
    int? limit,
  }) async {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return [];
    }
    return await notificationService.getNotifications(
      session,
      currentUserId,
      unreadOnly: unreadOnly,
      limit: limit ?? 50,
    );
  }

  /// Marks a specific notification as read.
  Future<bool> markNotificationRead(
    Session session,
    int notificationId,
  ) async {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return false;
    }
    return await notificationService.markAsRead(
      session,
      notificationId,
      currentUserId,
    );
  }

  /// Marks all notifications for caller as read.
  Future<int> markAllNotificationsRead(Session session) async {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return 0;
    }
    return await notificationService.markAllAsRead(session, currentUserId);
  }

  // --- Role, Staff & Profile Management Endpoints ---

  /// Retrieves caller's profile and trusted role information.
  Future<StaffUserInfo?> getCurrentUserProfile(Session session) async {
    return await roleService.getCurrentUserProfile(session);
  }

  /// Admin retrieves directory of all staff with active workloads.
  Future<List<StaffUserInfo>> getStaffUsers(Session session) async {
    return await roleService.getStaffUsers(session);
  }

  /// Admin provisions or changes a staff user's role.
  Future<CivicUserRole> provisionStaff(
    Session session,
    String targetUserId,
    String role, {
    String? department,
    String? fullName,
    String? email,
  }) async {
    return await roleService.provisionStaff(
      session,
      targetUserId,
      role,
      department: department,
      fullName: fullName,
      email: email,
    );
  }

  /// Admin enables or disables a staff member.
  Future<CivicUserRole> setStaffActiveStatus(
    Session session,
    String targetUserId,
    bool isActive,
  ) async {
    return await roleService.setStaffActiveStatus(
      session,
      targetUserId,
      isActive,
    );
  }

  /// Admin approves a pending staff member.
  Future<CivicUserRole> approveStaff(
    Session session,
    String targetUserId, {
    String? department,
    String? employeeId,
  }) async {
    return await roleService.approveStaff(
      session,
      targetUserId,
      department: department,
      employeeId: employeeId,
    );
  }

  /// Bootstrap initial administrator account.
  Future<CivicUserRole> bootstrapFirstAdmin(
    Session session,
    String secretKey,
    String adminUserId, {
    String? email,
    String? fullName,
  }) async {
    return await roleService.bootstrapFirstAdmin(
      session,
      secretKey,
      adminUserId,
      email: email,
      fullName: fullName,
    );
  }

  // --- Photo Upload & Storage Implementation ---

  /// Allowed image file extensions for issue photo attachments.
  static const Set<String> allowedPhotoExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  /// Maximum allowed photo upload size in bytes (5 MB).
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  /// Allowed issue statuses for direct update.
  static const Set<String> validStatuses = {
    'open',
    'in_progress',
    'resolved',
    'closed',
  };

  /// Validates [photoData] byte length against limits.
  static void validatePhotoBytes(ByteData photoData) {
    if (photoData.lengthInBytes == 0) {
      throw ArgumentError.value(
        photoData.lengthInBytes,
        'photoData',
        'Photo data cannot be empty.',
      );
    }
    if (photoData.lengthInBytes > maxPhotoBytes) {
      throw ArgumentError.value(
        photoData.lengthInBytes,
        'photoData',
        'Photo exceeds maximum allowed size of 5 MB.',
      );
    }
  }

  /// Validates [fileName] and returns its lower-case extension without the leading dot.
  static String validateAndExtractExtension(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'File name cannot be empty.',
      );
    }
    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == trimmed.length - 1) {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'File name must include a valid file extension.',
      );
    }
    final ext = trimmed.substring(dotIndex + 1).toLowerCase();
    if (!allowedPhotoExtensions.contains(ext)) {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'Unsupported file extension "$ext". Allowed extensions: jpg, jpeg, png, webp.',
      );
    }
    return ext;
  }

  /// Generates a HMAC-SHA256 upload authorization token for [issueId].
  static String generateUploadToken(
    Session session,
    int issueId, {
    Duration validity = const Duration(minutes: 30),
  }) {
    final expiry = DateTime.now().add(validity).millisecondsSinceEpoch;
    final secret = _resolveUploadSecret(session);
    final payload = '$issueId:$expiry';
    final hmac = Hmac(sha256, utf8.encode(secret));
    final signature = hmac.convert(utf8.encode(payload)).toString();
    return '$issueId.$expiry.$signature';
  }

  /// Verifies a HMAC-SHA256 upload authorization token.
  static bool verifyUploadToken(
    Session session,
    int issueId,
    String token,
  ) {
    try {
      final parts = token.trim().split('.');
      if (parts.length != 3) return false;
      final tokenIssueId = int.tryParse(parts[0]);
      final expiry = int.tryParse(parts[1]);
      final signature = parts[2];
      if (tokenIssueId == null || expiry == null) return false;
      if (tokenIssueId != issueId) return false;
      if (DateTime.now().millisecondsSinceEpoch > expiry) return false;

      final secret = _resolveUploadSecret(session);
      final payload = '$tokenIssueId:$expiry';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final expectedSignature = hmac.convert(utf8.encode(payload)).toString();

      final expectedBytes = utf8.encode(expectedSignature);
      final actualBytes = utf8.encode(signature);
      return _constantTimeEquals(expectedBytes, actualBytes);
    } catch (_) {
      return false;
    }
  }

  static String _resolveUploadSecret(Session session) {
    try {
      final secret = session.passwords['uploadSecret'];
      if (secret != null && secret.trim().isNotEmpty) return secret.trim();
    } catch (_) {}
    try {
      final secret = session.serverpod.getPassword('uploadSecret');
      if (secret != null && secret.trim().isNotEmpty) return secret.trim();
    } catch (_) {}
    final envSecret = Platform.environment['UPLOAD_SECRET'];
    if (envSecret != null && envSecret.trim().isNotEmpty) {
      return envSecret.trim();
    }
    return 'civicloop_default_upload_secret_key_2026';
  }

  static (String cleanInput, String? token) extractTokenFromInput(
    String input,
  ) {
    final queryIdx = input.indexOf('?token=');
    if (queryIdx != -1) {
      final clean = input.substring(0, queryIdx);
      final token = input.substring(queryIdx + 7);
      return (clean, token);
    }
    final hashIdx = input.indexOf('#token=');
    if (hashIdx != -1) {
      final clean = input.substring(0, hashIdx);
      final token = input.substring(hashIdx + 7);
      return (clean, token);
    }
    return (input, null);
  }

  void _verifyPhotoUploadAuthorization(
    Session session,
    Issue issue, {
    String? uploadToken,
  }) {
    final currentUserId = session.authenticated?.userIdentifier;
    if (currentUserId != null &&
        currentUserId.trim().isNotEmpty &&
        issue.userId != null &&
        issue.userId == currentUserId) {
      return;
    }

    if (isOfficialOrAdmin(session)) {
      return;
    }

    if (uploadToken != null && uploadToken.trim().isNotEmpty) {
      if (verifyUploadToken(session, issue.id!, uploadToken)) {
        return;
      }
    }

    if (issue.userId == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message:
            'Unauthorized: A valid upload token or issue ownership is required to attach photos to an anonymous issue.',
      );
    }
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
        message: 'User must be authenticated to attach photos to an issue.',
      );
    }
    throw NotAuthorizedException(
      reason: AuthenticationFailureReason.insufficientAccess,
      message:
          'You cannot attach or replace photos on an issue you do not own.',
    );
  }

  Future<Issue> attachIssuePhoto(
    Session session,
    int issueId,
    String fileName,
    ByteData photoData, {
    String? uploadToken,
  }) async {
    if (issueId <= 0) {
      throw ArgumentError.value(
        issueId,
        'issueId',
        'Issue ID must be a positive integer.',
      );
    }

    final (cleanFileName, extractedToken) = extractTokenFromInput(fileName);
    final effectiveToken = uploadToken ?? extractedToken;

    final existing = await Issue.db.findById(session, issueId);
    if (existing == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }
    _verifyPhotoUploadAuthorization(
      session,
      existing,
      uploadToken: effectiveToken,
    );

    final ext = validateAndExtractExtension(cleanFileName);
    if (photoData.lengthInBytes == 0) {
      throw ArgumentError.value(
        photoData.lengthInBytes,
        'photoData',
        'Photo data cannot be empty.',
      );
    }
    if (photoData.lengthInBytes > maxPhotoBytes) {
      throw ArgumentError.value(
        photoData.lengthInBytes,
        'photoData',
        'Photo exceeds maximum allowed size of 5 MB.',
      );
    }

    final storagePath = 'issues/$issueId/photo.$ext';
    await session.storage.storeFile(
      storageId: 'public',
      path: storagePath,
      byteData: photoData,
    );

    final updated = existing.copyWith(photoPath: storagePath);
    return await Issue.db.updateRow(session, updated);
  }

  Future<String> getPhotoUploadDescription(
    Session session,
    int issueId,
    String fileName, {
    String? uploadToken,
  }) async {
    if (issueId <= 0) {
      throw ArgumentError.value(
        issueId,
        'issueId',
        'Issue ID must be a positive integer.',
      );
    }
    final (cleanFileName, extractedToken) = extractTokenFromInput(fileName);
    final effectiveToken = uploadToken ?? extractedToken;

    final existing = await Issue.db.findById(session, issueId);
    if (existing == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }
    _verifyPhotoUploadAuthorization(
      session,
      existing,
      uploadToken: effectiveToken,
    );

    final ext = validateAndExtractExtension(cleanFileName);
    final storagePath = 'issues/$issueId/photo.$ext';

    return await session.storage.createUploadDescription(
      storageId: 'public',
      path: storagePath,
    );
  }

  Future<Issue> verifyAndAttachPhoto(
    Session session,
    int issueId,
    String path, {
    String? uploadToken,
  }) async {
    if (issueId <= 0) {
      throw ArgumentError.value(
        issueId,
        'issueId',
        'Issue ID must be a positive integer.',
      );
    }
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty) {
      throw ArgumentError.value(
        path,
        'path',
        'Storage path cannot be empty.',
      );
    }
    final (cleanPath, extractedToken) = extractTokenFromInput(trimmedPath);
    final effectiveToken = uploadToken ?? extractedToken;

    final existing = await Issue.db.findById(session, issueId);
    if (existing == null) {
      throw ArgumentError.value(issueId, 'issueId', 'Issue not found.');
    }
    _verifyPhotoUploadAuthorization(
      session,
      existing,
      uploadToken: effectiveToken,
    );

    final verified = await session.storage.verifyUpload(
      storageId: 'public',
      path: cleanPath,
    );
    if (!verified) {
      throw StateError(
        'Photo upload verification failed or file does not exist.',
      );
    }

    final updated = existing.copyWith(photoPath: cleanPath);
    return await Issue.db.updateRow(session, updated);
  }

  Future<String?> getIssuePhotoUrl(Session session, int issueId) async {
    if (issueId <= 0) return null;
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null || issue.photoPath == null) return null;
    try {
      final uri = await session.storage.publicDownloadUrl(
        storageId: 'public',
        path: issue.photoPath!,
      );
      return uri.toString();
    } on CloudStorageException {
      return null;
    }
  }

  Future<ByteData?> getIssuePhoto(Session session, int issueId) async {
    if (issueId <= 0) return null;
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null || issue.photoPath == null) return null;
    try {
      return await session.storage.retrieveFile(
        storageId: 'public',
        path: issue.photoPath!,
      );
    } on CloudStorageException {
      return null;
    }
  }

  Future<String?> getCompletionPhotoUrl(Session session, int issueId) async {
    if (issueId <= 0) return null;
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null || issue.completionPhotoPath == null) return null;
    try {
      final uri = await session.storage.publicDownloadUrl(
        storageId: 'public',
        path: issue.completionPhotoPath!,
      );
      return uri.toString();
    } on CloudStorageException {
      return null;
    }
  }

  Future<ByteData?> getCompletionPhoto(Session session, int issueId) async {
    if (issueId <= 0) return null;
    final issue = await Issue.db.findById(session, issueId);
    if (issue == null || issue.completionPhotoPath == null) return null;
    try {
      return await session.storage.retrieveFile(
        storageId: 'public',
        path: issue.completionPhotoPath!,
      );
    } on CloudStorageException {
      return null;
    }
  }
}

bool _constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
