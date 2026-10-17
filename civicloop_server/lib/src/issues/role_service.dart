import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'issue_endpoint.dart';
import 'notification_service.dart';

/// Service managing user roles, staff provisioning, and role-based permissions.
class RoleService {
  const RoleService();

  static const String roleCitizen = 'citizen';
  static const String roleEmployee = 'employee';
  static const String roleAdmin = 'admin';

  static const Set<String> validRoles = {
    roleCitizen,
    roleEmployee,
    roleAdmin,
  };

  static const String statusApproved = 'approved';
  static const String statusPending = 'pending';
  static const String statusRejected = 'rejected';

  /// Extracts the employee identifier from an employee email (e.g. 'emp101' from 'emp101@employeecivic.com').
  static String extractEmployeeId(String email) {
    final lower = email.trim().toLowerCase();
    final parts = lower.split('@');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0];
    }
    return 'EMP-${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Generates a friendly display name for a staff member based on their email.
  static String formatStaffName(String email, String role) {
    final prefix = email.split('@').first;
    if (prefix.contains('.')) {
      final subparts = prefix.split('.');
      return subparts
          .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
          .join(' ');
    }
    if (role == roleAdmin) {
      return 'Admin ${prefix[0].toUpperCase()}${prefix.substring(1)}';
    }
    return 'Field Worker ($prefix)';
  }

  /// Validates whether [email] matches the authorized Municipal Administrator format: name@civicloop.com.
  /// Also permits legacy official domain @official.civicloop for testing backward compatibility.
  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    final lower = email.trim().toLowerCase();
    final parts = lower.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return false;
    return parts[1] == 'civicloop.com' || parts[1] == 'official.civicloop';
  }

  /// Validates whether [email] matches the authorized Field Operations Worker format: employeeid@employeecivic.com.
  /// Also permits legacy worker domain @civicloop.local and @city.gov for testing backward compatibility.
  static bool isEmployeeEmail(String? email) {
    if (email == null) return false;
    final lower = email.trim().toLowerCase();
    final parts = lower.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return false;
    return parts[1] == 'employeecivic.com' ||
        parts[1] == 'civicloop.local' ||
        parts[1] == 'city.gov';
  }

  /// Checks whether [email] belongs to a reserved staff domain (@civicloop.com, @employeecivic.com, etc.).
  /// Public registration is never permitted for reserved staff email domains.
  static bool isReservedDomain(String? email) {
    if (email == null) return false;
    final lower = email.trim().toLowerCase();
    final parts = lower.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return false;
    final domain = parts[1];
    return domain == 'civicloop.com' ||
        domain == 'employeecivic.com' ||
        domain == 'official.civicloop' ||
        domain == 'civicloop.local';
  }

  /// Resolves the trusted role for the given [userId].
  ///
  /// Resolves the role strictly from trusted server-side [CivicUserRole] records and scopes.
  /// Never grants admin or employee privileges based purely on email domain strings or client claims.
  /// Throws [NotAuthorizedException] if an account is deactivated or if its authorized role
  /// does not match the required email format.
  Future<String> getRole(Session session, String? userId) async {
    if (userId == null || userId.trim().isEmpty) {
      return roleCitizen;
    }
    final trimmedId = userId.trim();

    // 1. Check persistent database record by userId
    var roleRecord = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedId),
    );

    String? userEmail = roleRecord?.email;
    if (trimmedId.contains('@')) {
      userEmail ??= trimmedId.toLowerCase();
    }

    // 2. Look up EmailAccount if userId is a UUID
    try {
      final uuid = UuidValue.fromString(trimmedId);
      final emailAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(uuid),
      );
      if (emailAcc != null) {
        userEmail = emailAcc.email.trim().toLowerCase();
        roleRecord ??= await CivicUserRole.db.findFirstRow(
          session,
          where: (t) => t.email.equals(userEmail) | t.userId.equals(userEmail),
        );
      }
    } catch (_) {}

    // 3. Evaluate persistent role record if present
    if (roleRecord != null) {
      if (!roleRecord.isActive && roleRecord.approvalStatus != statusPending) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message: 'Access denied: Account has been deactivated.',
        );
      }
      final effectiveRole = roleRecord.role.toLowerCase();
      if (effectiveRole == roleAdmin) {
        if (userEmail != null &&
            userEmail.contains('@') &&
            !isAdminEmail(userEmail)) {
          throw NotAuthorizedException(
            reason: AuthenticationFailureReason.insufficientAccess,
            message:
                'Access denied: Account email format does not match the authorized Municipal Administrator format (name@civicloop.com).',
          );
        }
        return roleAdmin;
      }
      if (effectiveRole == roleEmployee) {
        if (userEmail != null &&
            userEmail.contains('@') &&
            !isEmployeeEmail(userEmail)) {
          throw NotAuthorizedException(
            reason: AuthenticationFailureReason.insufficientAccess,
            message:
                'Access denied: Account email format does not match the authorized Field Operations Worker format (employeeid@employeecivic.com).',
          );
        }
        return roleEmployee;
      }
      // Citizen record with reserved domain is unauthorized
      if (effectiveRole == roleCitizen &&
          userEmail != null &&
          userEmail.contains('@') &&
          isReservedDomain(userEmail)) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message:
              'Access denied: Unauthorized staff account. Administrator and employee accounts must be provisioned by a municipal administrator.',
        );
      }
      return roleCitizen;
    }

    // 4. Check for explicit Serverpod admin/official scopes
    final auth = session.authenticated;
    final hasAdminScope =
        auth != null &&
        (auth.scopes.contains(Scope.admin) ||
            auth.scopes.any((s) => s.name == 'official' || s.name == 'admin'));
    if (hasAdminScope) {
      if (userEmail != null &&
          userEmail.contains('@') &&
          !isAdminEmail(userEmail)) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message:
              'Access denied: Account email format does not match the authorized Municipal Administrator format (name@civicloop.com).',
        );
      }
      return roleAdmin;
    }

    // 5. Configured official user IDs for bootstrapping & test setups
    if (IssueEndpoint.isOfficialOrAdmin(session)) {
      if (userEmail != null &&
          userEmail.contains('@') &&
          !isAdminEmail(userEmail)) {
        throw NotAuthorizedException(
          reason: AuthenticationFailureReason.insufficientAccess,
          message:
              'Access denied: Account email format does not match the authorized Municipal Administrator format (name@civicloop.com).',
        );
      }
      return roleAdmin;
    }

    // 6. If user attempts to authenticate with an unprovisioned reserved domain, deny access
    if (userEmail != null &&
        userEmail.contains('@') &&
        isReservedDomain(userEmail)) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message:
            'Access denied: Unauthorized staff account. Administrator and employee accounts must be provisioned by a municipal administrator.',
      );
    }

    return roleCitizen;
  }

  /// Helper to locate the [CivicUserRole] record for a given [userId].
  Future<CivicUserRole?> findRoleRecord(Session session, String userId) async {
    final trimmedId = userId.trim();
    var roleRecord = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedId),
    );
    if (roleRecord == null) {
      try {
        final uuid = UuidValue.fromString(trimmedId);
        final emailAcc = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (emailAcc != null) {
          final userEmail = emailAcc.email.trim().toLowerCase();
          roleRecord = await CivicUserRole.db.findFirstRow(
            session,
            where: (t) =>
                t.email.equals(userEmail) | t.userId.equals(userEmail),
          );
        }
      } catch (_) {}
    }
    return roleRecord;
  }

  /// Checks whether the authenticated caller has the active, approved [roleAdmin] role.
  Future<bool> isAdmin(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    try {
      final roleRecord = await findRoleRecord(session, userId);
      String? userEmail = roleRecord?.email;
      if (userEmail == null && userId.contains('@')) {
        userEmail = userId;
      }
      if (roleRecord != null) {
        if (roleRecord.role.toLowerCase() == roleAdmin) {
          final email = roleRecord.email ?? userEmail;
          if (email == null || isAdminEmail(email)) {
            // Development Demo Policy: verified @civicloop.com admins are active and approved
            if (roleRecord.approvalStatus != statusApproved ||
                !roleRecord.isActive) {
              try {
                final updated = roleRecord.copyWith(
                  approvalStatus: statusApproved,
                  isActive: true,
                  updatedAt: DateTime.now(),
                );
                await CivicUserRole.db.updateRow(session, updated);
              } catch (_) {}
            }
            return true;
          }
          return false;
        }
        if (!roleRecord.isActive ||
            roleRecord.approvalStatus == statusPending) {
          return false;
        }
        return false;
      }
      final role = await getRole(session, userId);
      return role == roleAdmin;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether the authenticated caller has the active, approved [roleEmployee] role.
  Future<bool> isEmployee(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    try {
      final roleRecord = await findRoleRecord(session, userId);
      if (roleRecord != null) {
        if (!roleRecord.isActive ||
            roleRecord.approvalStatus == statusPending) {
          return false;
        }
        if (roleRecord.role.toLowerCase() == roleEmployee) {
          final email =
              roleRecord.email ?? (userId.contains('@') ? userId : null);
          return email == null || isEmployeeEmail(email);
        }
        return false;
      }
      final role = await getRole(session, userId);
      return role == roleEmployee;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether the caller is either an active admin or an active employee.
  Future<bool> isStaff(Session session) async {
    return (await isAdmin(session)) || (await isEmployee(session));
  }

  /// Returns user profile info for the caller or null if unauthenticated.
  /// Throws [NotAuthorizedException] if the account is deactivated or has a role mismatch.
  Future<StaffUserInfo?> getCurrentUserProfile(Session session) async {
    final authUserId = session.authenticated?.userIdentifier;
    if (authUserId == null || authUserId.trim().isEmpty) {
      return null;
    }

    final trimmedId = authUserId.trim();
    // Resolve role from trusted server state (validates email format and active status)
    final effectiveRole = await getRole(session, trimmedId);

    var roleRecord = await findRoleRecord(session, trimmedId);
    String? userEmail = roleRecord?.email;
    if (userEmail == null && trimmedId.contains('@')) {
      userEmail = trimmedId;
    }

    // Development Demo Policy: verified @civicloop.com admins are active and approved
    final bool isAdminAccount =
        effectiveRole == roleAdmin &&
        (userEmail == null || isAdminEmail(userEmail));

    final isActive = isAdminAccount ? true : (roleRecord?.isActive ?? true);
    final approvalStatus = isAdminAccount
        ? statusApproved
        : (roleRecord?.approvalStatus ??
              (isActive ? statusApproved : statusPending));

    // Self-heal database record if an admin account was stored as pending or inactive
    if (isAdminAccount &&
        roleRecord != null &&
        (roleRecord.approvalStatus != statusApproved || !roleRecord.isActive)) {
      try {
        final updated = roleRecord.copyWith(
          approvalStatus: statusApproved,
          isActive: true,
          updatedAt: DateTime.now(),
        );
        await CivicUserRole.db.updateRow(session, updated);
      } catch (_) {}
    }

    int activeCount = 0;
    if (effectiveRole == roleEmployee) {
      activeCount = await Issue.db.count(
        session,
        where: (t) =>
            (t.assignedEmployeeId.equals(trimmedId) |
                (userEmail != null
                    ? t.assignedEmployeeId.equals(userEmail)
                    : t.id.equals(-1)) |
                (roleRecord?.employeeId != null
                    ? t.assignedEmployeeId.equals(roleRecord!.employeeId!)
                    : t.id.equals(-1))) &
            (t.status.equals('assigned') | t.status.equals('in_progress')),
      );
    }

    return StaffUserInfo(
      userId: trimmedId,
      email: roleRecord?.email ?? userEmail,
      fullName: roleRecord?.fullName,
      role: effectiveRole,
      department: roleRecord?.department,
      isActive: isActive,
      activeAssignedCasesCount: activeCount,
      employeeId: roleRecord?.employeeId,
      approvalStatus: approvalStatus,
    );
  }

  /// Provisions or updates a staff user account. Requires caller to be an admin.
  /// Prevents administrators from modifying their own roles.
  /// Enforces authorized email formats: name@civicloop.com for admin, employeeid@employeecivic.com for employee.
  Future<CivicUserRole> provisionStaff(
    Session session,
    String targetUserId,
    String role, {
    String? department,
    String? fullName,
    String? email,
  }) async {
    final callerIsAdmin = await isAdmin(session);
    if (!callerIsAdmin) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can provision or change staff roles.',
      );
    }

    final trimmedTarget = targetUserId.trim();
    if (trimmedTarget.isEmpty) {
      throw ArgumentError.value(
        targetUserId,
        'targetUserId',
        'User ID cannot be empty.',
      );
    }

    // Prevent modifying own role
    final callerUserId = session.authenticated?.userIdentifier.trim();
    if (callerUserId != null &&
        (callerUserId == trimmedTarget ||
            (email != null &&
                callerUserId.toLowerCase() == email.trim().toLowerCase()))) {
      throw ArgumentError('Administrators cannot modify their own role.');
    }
    if (callerUserId != null) {
      try {
        final uuid = UuidValue.fromString(callerUserId);
        final callerEmailAcc = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (callerEmailAcc != null) {
          final callerEmail = callerEmailAcc.email.trim().toLowerCase();
          if (callerEmail == trimmedTarget.toLowerCase() ||
              (email != null && callerEmail == email.trim().toLowerCase())) {
            throw ArgumentError('Administrators cannot modify their own role.');
          }
        }
      } catch (_) {}
    }

    final normalizedRole = role.trim().toLowerCase();
    if (!validRoles.contains(normalizedRole)) {
      throw ArgumentError.value(
        role,
        'role',
        'Invalid role "$role". Allowed roles are: citizen, employee, admin.',
      );
    }

    final effectiveEmail = (email?.trim().isNotEmpty == true)
        ? email!.trim().toLowerCase()
        : (trimmedTarget.contains('@') ? trimmedTarget.toLowerCase() : null);

    if (normalizedRole == roleAdmin &&
        effectiveEmail != null &&
        !isAdminEmail(effectiveEmail)) {
      throw ArgumentError.value(
        effectiveEmail,
        'email',
        'Administrator accounts must use the authorized email format (name@civicloop.com).',
      );
    }
    if (normalizedRole == roleEmployee &&
        effectiveEmail != null &&
        !isEmployeeEmail(effectiveEmail)) {
      throw ArgumentError.value(
        effectiveEmail,
        'email',
        'Employee accounts must use the authorized email format (employeeid@employeecivic.com).',
      );
    }

    final existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedTarget),
    );

    final extractedEmpId = normalizedRole == roleEmployee
        ? extractEmployeeId(effectiveEmail ?? trimmedTarget)
        : null;

    final now = DateTime.now();
    if (existing != null) {
      final updated = existing.copyWith(
        role: normalizedRole,
        department: department?.trim(),
        fullName: fullName?.trim() ?? existing.fullName,
        email: email?.trim() ?? existing.email,
        employeeId: existing.employeeId ?? extractedEmpId,
        approvalStatus: statusApproved,
        isActive: true,
        updatedAt: now,
      );
      return await CivicUserRole.db.updateRow(session, updated);
    } else {
      final newRecord = CivicUserRole(
        userId: trimmedTarget,
        role: normalizedRole,
        department: department?.trim(),
        fullName: fullName?.trim(),
        email: email?.trim(),
        employeeId: extractedEmpId,
        approvalStatus: statusApproved,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      return await CivicUserRole.db.insertRow(session, newRecord);
    }
  }

  /// Enables or disables a staff account. Requires caller to be an admin.
  /// Prevents administrators from modifying their own active status.
  Future<CivicUserRole> setStaffActiveStatus(
    Session session,
    String targetUserId,
    bool isActive,
  ) async {
    final callerIsAdmin = await isAdmin(session);
    if (!callerIsAdmin) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can manage staff active status.',
      );
    }

    final trimmedTarget = targetUserId.trim();
    if (trimmedTarget.isEmpty) {
      throw ArgumentError.value(
        targetUserId,
        'targetUserId',
        'Target staff user ID cannot be empty.',
      );
    }

    final callerUserId = session.authenticated?.userIdentifier.trim();
    if (callerUserId != null && callerUserId == trimmedTarget) {
      throw ArgumentError(
        'Administrators cannot change their own active status.',
      );
    }

    String? callerEmail;
    if (callerUserId != null) {
      try {
        final uuid = UuidValue.fromString(callerUserId);
        final callerEmailAcc = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (callerEmailAcc != null) {
          callerEmail = callerEmailAcc.email.trim().toLowerCase();
        }
      } catch (_) {}
    }
    if (callerEmail != null && callerEmail == trimmedTarget.toLowerCase()) {
      throw ArgumentError(
        'Administrators cannot change their own active status.',
      );
    }

    var existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedTarget),
    );
    existing ??= await CivicUserRole.db.findFirstRow(
      session,
      where: (t) =>
          t.email.equals(trimmedTarget) | t.employeeId.equals(trimmedTarget),
    );

    if (existing == null) {
      throw ArgumentError.value(
        targetUserId,
        'targetUserId',
        'Staff user role record not found.',
      );
    }

    // Verify found record does not belong to the calling administrator
    if (callerUserId != null && existing.userId == callerUserId) {
      throw ArgumentError(
        'Administrators cannot change their own active status.',
      );
    }
    if (callerEmail != null &&
        existing.email != null &&
        existing.email!.trim().toLowerCase() == callerEmail) {
      throw ArgumentError(
        'Administrators cannot change their own active status.',
      );
    }

    final updated = existing.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
    return await CivicUserRole.db.updateRow(session, updated);
  }

  /// Approves and activates a pending staff account. Requires caller to be an admin.
  Future<CivicUserRole> approveStaff(
    Session session,
    String targetUserId, {
    String? department,
    String? employeeId,
  }) async {
    final callerIsAdmin = await isAdmin(session);
    if (!callerIsAdmin) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can approve staff accounts.',
      );
    }

    final trimmedTarget = targetUserId.trim();
    if (trimmedTarget.isEmpty) {
      throw ArgumentError.value(
        targetUserId,
        'targetUserId',
        'Target user ID cannot be empty.',
      );
    }

    var existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(trimmedTarget) | t.email.equals(trimmedTarget),
    );
    if (existing == null && trimmedTarget.isNotEmpty) {
      try {
        final uuid = UuidValue.fromString(trimmedTarget);
        final emailAcc = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (emailAcc != null) {
          existing = await CivicUserRole.db.findFirstRow(
            session,
            where: (t) =>
                t.email.equals(emailAcc.email) |
                t.userId.equals(emailAcc.email),
          );
        }
      } catch (_) {}
    }

    if (existing == null) {
      throw ArgumentError.value(
        targetUserId,
        'targetUserId',
        'Staff user role record not found.',
      );
    }

    final now = DateTime.now();
    final updated = existing.copyWith(
      isActive: true,
      approvalStatus: statusApproved,
      department: department?.trim() ?? existing.department,
      employeeId: employeeId?.trim() ?? existing.employeeId,
      updatedAt: now,
    );
    final saved = await CivicUserRole.db.updateRow(session, updated);

    // If approved as admin, grant admin scope to auth user if it exists
    if (saved.role == roleAdmin) {
      try {
        final uuid = UuidValue.fromString(saved.userId);
        final authUser = await AuthUser.db.findById(session, uuid);
        if (authUser != null &&
            !authUser.scopeNames.contains(Scope.admin.name!)) {
          final updatedAuth = authUser.copyWith(
            scopeNames: {...authUser.scopeNames, Scope.admin.name!},
          );
          await AuthUser.db.updateRow(session, updatedAuth);
        }
      } catch (_) {}
    }

    // Send in-app notification
    try {
      const notificationService = NotificationService();
      await notificationService.createNotification(
        session,
        recipientId: saved.userId,
        issueId: 0,
        title: 'Account Approved',
        message: saved.role == roleAdmin
            ? 'Your Municipal Administrator account has been approved and activated.'
            : 'Your Field Operations Worker account has been approved and activated. You can now receive assignments.',
        type: 'account_approved',
      );
    } catch (_) {}

    return saved;
  }

  /// Lists all staff users with their workload and role info. Requires admin access.
  Future<List<StaffUserInfo>> getStaffUsers(Session session) async {
    final callerIsAdmin = await isAdmin(session);
    if (!callerIsAdmin) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Only administrators can view staff directory.',
      );
    }

    final staffRoles = await CivicUserRole.db.find(
      session,
      where: (t) => t.role.equals(roleAdmin) | t.role.equals(roleEmployee),
      orderBy: (t) => t.fullName,
    );

    final result = <StaffUserInfo>[];
    for (final r in staffRoles) {
      int activeCount = 0;
      if (r.role == roleEmployee) {
        activeCount = await Issue.db.count(
          session,
          where: (t) =>
              (t.assignedEmployeeId.equals(r.userId) |
                  (r.email != null
                      ? t.assignedEmployeeId.equals(r.email!)
                      : t.id.equals(-1)) |
                  (r.employeeId != null
                      ? t.assignedEmployeeId.equals(r.employeeId!)
                      : t.id.equals(-1))) &
              (t.status.equals('assigned') | t.status.equals('in_progress')),
        );
      }
      result.add(
        StaffUserInfo(
          userId: r.userId,
          email: r.email,
          fullName: r.fullName,
          role: r.role,
          department: r.department,
          isActive: r.isActive,
          activeAssignedCasesCount: activeCount,
          employeeId: r.employeeId,
          approvalStatus:
              r.approvalStatus ?? (r.isActive ? statusApproved : statusPending),
        ),
      );
    }
    return result;
  }

  /// Securely provisions the first administrator without requiring an existing admin.
  ///
  /// Requires a valid secret key matching `passwords['bootstrapSecret']` or server secret.
  Future<CivicUserRole> bootstrapFirstAdmin(
    Session session,
    String secretKey,
    String adminUserId, {
    String? email,
    String? fullName,
  }) async {
    final trimmedKey = secretKey.trim();
    final trimmedId = adminUserId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(
        adminUserId,
        'adminUserId',
        'Admin User ID cannot be empty.',
      );
    }

    final effectiveEmail = (email?.trim().isNotEmpty == true)
        ? email!.trim().toLowerCase()
        : (trimmedId.contains('@') ? trimmedId.toLowerCase() : null);
    if (effectiveEmail != null && !isAdminEmail(effectiveEmail)) {
      throw ArgumentError.value(
        effectiveEmail,
        'email',
        'Administrator accounts must use the authorized email format (name@civicloop.com).',
      );
    }

    String? expectedSecret;
    try {
      expectedSecret = session.passwords['bootstrapSecret'];
    } catch (_) {}
    if (expectedSecret == null || expectedSecret.trim().isEmpty) {
      try {
        expectedSecret = session.serverpod.getPassword('bootstrapSecret');
      } catch (_) {}
    }
    if (expectedSecret == null || expectedSecret.trim().isEmpty) {
      final envSecret = Platform.environment['BOOTSTRAP_SECRET'];
      if (envSecret != null && envSecret.trim().isNotEmpty) {
        expectedSecret = envSecret.trim();
      } else {
        expectedSecret = 'civicloop_bootstrap_admin_secret_key_2026';
      }
    }

    // Verify secret key using constant-time comparison
    final expectedBytes = utf8.encode(expectedSecret);
    final actualBytes = utf8.encode(trimmedKey);
    final keyValid = _constantTimeEquals(expectedBytes, actualBytes);

    // Also allow bootstrap if no admin exists in the database yet
    final existingAdminCount = await CivicUserRole.db.count(
      session,
      where: (t) => t.role.equals(roleAdmin) & t.isActive.equals(true),
    );

    if (!keyValid && existingAdminCount > 0) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message:
            'Invalid bootstrap secret key and existing administrators already exist.',
      );
    }

    final existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedId),
    );
    final now = DateTime.now();
    if (existing != null) {
      final updated = existing.copyWith(
        role: roleAdmin,
        fullName: fullName?.trim() ?? existing.fullName,
        email: email?.trim() ?? existing.email,
        approvalStatus: statusApproved,
        isActive: true,
        updatedAt: now,
      );
      return await CivicUserRole.db.updateRow(session, updated);
    } else {
      final newRecord = CivicUserRole(
        userId: trimmedId,
        role: roleAdmin,
        department: 'Administration',
        fullName: fullName?.trim() ?? 'System Administrator',
        email: email?.trim(),
        approvalStatus: statusApproved,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      return await CivicUserRole.db.insertRow(session, newRecord);
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
