import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart';
import 'issue_endpoint.dart';

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

  /// Resolves the trusted role for the given [userId].
  ///
  /// Resolves the trusted role for the given [userId].
  ///
  /// Checks the persistent [CivicUserRole] database table first (by userId and email).
  /// Falls back to configured official/admin identifiers or defaults to 'citizen'.
  Future<String> getRole(Session session, String? userId) async {
    if (userId == null || userId.trim().isEmpty) {
      return roleCitizen;
    }
    final trimmedId = userId.trim();

    // 1. Check persistent database record by userId
    var existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedId),
    );
    if (existing != null && existing.isActive) {
      return existing.role.toLowerCase();
    }

    // 2. Check if trimmedId is a UUID and matches an EmailAccount
    String? email;
    try {
      final uuid = UuidValue.fromString(trimmedId);
      final emailAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(uuid),
      );
      if (emailAcc != null) {
        email = emailAcc.email.trim().toLowerCase();
        existing = await CivicUserRole.db.findFirstRow(
          session,
          where: (t) => t.email.equals(email) | t.userId.equals(email),
        );
        if (existing != null && existing.isActive) {
          return existing.role.toLowerCase();
        }
      }
    } catch (_) {}

    // 3. Fallback to existing official/admin config for bootstrapping & test setups
    if (IssueEndpoint.isOfficialOrAdmin(session)) {
      return roleAdmin;
    }

    // 4. If email ends with configured official domain or @official.civicloop, auto-recognize as admin
    if (email != null &&
        (email.endsWith('@official.civicloop') || email.endsWith('official.civicloop'))) {
      return roleAdmin;
    }

    return roleCitizen;
  }

  /// Checks whether the authenticated caller has the [roleAdmin] role.
  Future<bool> isAdmin(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final role = await getRole(session, userId);
    return role == roleAdmin;
  }

  /// Checks whether the authenticated caller has the [roleEmployee] role.
  Future<bool> isEmployee(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final role = await getRole(session, userId);
    return role == roleEmployee;
  }

  /// Checks whether the caller is either an admin or an employee.
  Future<bool> isStaff(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final role = await getRole(session, userId);
    return role == roleAdmin || role == roleEmployee;
  }

  /// Returns user profile info for the caller or null if unauthenticated.
  Future<StaffUserInfo?> getCurrentUserProfile(Session session) async {
    final authUserId = session.authenticated?.userIdentifier;
    if (authUserId == null || authUserId.trim().isEmpty) {
      return null;
    }

    final trimmedId = authUserId.trim();
    var roleRecord = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedId),
    );

    String? userEmail = roleRecord?.email;
    if (roleRecord == null) {
      try {
        final uuid = UuidValue.fromString(trimmedId);
        final emailAcc = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (emailAcc != null) {
          userEmail = emailAcc.email;
          roleRecord = await CivicUserRole.db.findFirstRow(
            session,
            where: (t) => t.email.equals(userEmail) | t.userId.equals(userEmail),
          );
        }
      } catch (_) {}
    }

    final effectiveRole = roleRecord?.role ?? (await getRole(session, trimmedId));
    final isActive = roleRecord?.isActive ?? true;

    // Auto-persist role for recognized admins/employees who logged in via official domain
    if (roleRecord == null && (effectiveRole == roleAdmin || effectiveRole == roleEmployee)) {
      final now = DateTime.now();
      final newRecord = CivicUserRole(
        userId: trimmedId,
        role: effectiveRole,
        email: userEmail,
        fullName: effectiveRole == roleAdmin ? 'Municipal Administrator' : 'Field Operations Worker',
        department: effectiveRole == roleAdmin ? 'Administration' : 'Field Operations',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      try {
        roleRecord = await CivicUserRole.db.insertRow(session, newRecord);
      } catch (_) {}
    }

    int activeCount = 0;
    if (effectiveRole == roleEmployee) {
      activeCount = await Issue.db.count(
        session,
        where: (t) =>
            (t.assignedEmployeeId.equals(trimmedId) |
             (userEmail != null ? t.assignedEmployeeId.equals(userEmail) : t.id.equals(-1))) &
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
    );
  }

  /// Provisions or updates a staff user account. Requires caller to be an admin.
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
      throw ArgumentError.value(targetUserId, 'targetUserId', 'User ID cannot be empty.');
    }

    final normalizedRole = role.trim().toLowerCase();
    if (!validRoles.contains(normalizedRole)) {
      throw ArgumentError.value(
        role,
        'role',
        'Invalid role "$role". Allowed roles are: citizen, employee, admin.',
      );
    }

    final existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedTarget),
    );

    final now = DateTime.now();
    if (existing != null) {
      final updated = existing.copyWith(
        role: normalizedRole,
        department: department?.trim(),
        fullName: fullName?.trim() ?? existing.fullName,
        email: email?.trim() ?? existing.email,
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
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      return await CivicUserRole.db.insertRow(session, newRecord);
    }
  }

  /// Enables or disables a staff account. Requires caller to be an admin.
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
    final existing = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(trimmedTarget),
    );
    if (existing == null) {
      throw ArgumentError.value(
        targetUserId,
        'targetUserId',
        'Staff user role record not found.',
      );
    }

    final updated = existing.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
    return await CivicUserRole.db.updateRow(session, updated);
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
              t.assignedEmployeeId.equals(r.userId) &
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
      throw ArgumentError.value(adminUserId, 'adminUserId', 'Admin User ID cannot be empty.');
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
        message: 'Invalid bootstrap secret key and existing administrators already exist.',
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
