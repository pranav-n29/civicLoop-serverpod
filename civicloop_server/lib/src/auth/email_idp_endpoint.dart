import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import '../issues/role_service.dart';

/// Identity provider endpoint for unified email-based authentication.
///
/// Supports citizens, municipal administrators, and field workers through a unified
/// registration and login flow:
/// - Citizen registrations (standard email) receive immediate active 'citizen' role.
/// - Administrator registrations (@civicloop.com):
///   - Development Demo Policy: Every verified @civicloop.com account receives active
///     'admin' role, approved status, and Scope.admin privileges without manual approval.
///     WARNING: In production, auto-granting admin privileges based on email domain is insecure.
/// - Field Worker registrations (@employeecivic.com) create a persistent employee record
///   with pending approval status, extracted employeeId, and no active permissions until approved.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<UuidValue> startRegistration(
    final Session session, {
    required final String email,
  }) async {
    // Allow citizens, administrators (@civicloop.com), and employees (@employeecivic.com)
    return await super.startRegistration(session, email: email);
  }

  @override
  Future<AuthSuccess> finishRegistration(
    final Session session, {
    required final String registrationToken,
    required final String password,
  }) async {
    final authSuccess = await super.finishRegistration(
      session,
      registrationToken: registrationToken,
      password: password,
    );

    final authUserId = authSuccess.authUserId.toString();
    try {
      final emailAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authSuccess.authUserId),
      );
      final rawEmail = emailAcc?.email.trim().toLowerCase();
      final now = DateTime.now();

      final existingRole = await CivicUserRole.db.findFirstRow(
        session,
        where: (t) =>
            t.userId.equals(authUserId) |
            (rawEmail != null ? t.email.equals(rawEmail) : t.id.equals(-1)),
      );

      if (existingRole == null) {
        String assignedRole = RoleService.roleCitizen;
        String approvalStatus = RoleService.statusApproved;
        bool isActive = true;
        String? employeeId;
        String? fullName;

        if (rawEmail != null && RoleService.isAdminEmail(rawEmail)) {
          // Development Demo Policy:
          // In this development demo environment, every successfully registered and verified
          // @civicloop.com email automatically becomes an active, approved Municipal Administrator
          // with Scope.admin privileges without requiring manual approval.
          // WARNING: In a real-world municipal production deployment, auto-granting administrative
          // privileges solely based on user-supplied email domain is insecure. Production systems
          // must require multi-party administrator invitation, hardware security keys, or strict
          // identity proofing.
          assignedRole = RoleService.roleAdmin;
          approvalStatus = RoleService.statusApproved;
          isActive = true;
          fullName = RoleService.formatStaffName(
            rawEmail,
            RoleService.roleAdmin,
          );

          // Grant Scope.admin to AuthUser
          try {
            final authUser = await AuthUser.db.findById(
              session,
              authSuccess.authUserId,
            );
            if (authUser != null &&
                !authUser.scopeNames.contains(Scope.admin.name!)) {
              final updatedAuth = authUser.copyWith(
                scopeNames: {...authUser.scopeNames, Scope.admin.name!},
              );
              await AuthUser.db.updateRow(session, updatedAuth);
            }
          } catch (_) {}
        } else if (rawEmail != null && RoleService.isEmployeeEmail(rawEmail)) {
          // Employee registration: pending admin approval, not active, no scopes
          assignedRole = RoleService.roleEmployee;
          approvalStatus = RoleService.statusPending;
          isActive = false;
          employeeId = RoleService.extractEmployeeId(rawEmail);
          fullName = RoleService.formatStaffName(
            rawEmail,
            RoleService.roleEmployee,
          );
        } else {
          // Citizen registration: immediately approved & active
          assignedRole = RoleService.roleCitizen;
          approvalStatus = RoleService.statusApproved;
          isActive = true;
          fullName = rawEmail?.split('@').first;
        }

        await CivicUserRole.db.insertRow(
          session,
          CivicUserRole(
            userId: authUserId,
            email: rawEmail,
            role: assignedRole,
            fullName: fullName,
            employeeId: employeeId,
            approvalStatus: approvalStatus,
            isActive: isActive,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else if (rawEmail != null && RoleService.isAdminEmail(rawEmail)) {
        // Safely reconcile any existing admin account that was previously marked pending or inactive
        if (existingRole.approvalStatus != RoleService.statusApproved ||
            !existingRole.isActive ||
            existingRole.role != RoleService.roleAdmin) {
          final updated = existingRole.copyWith(
            role: RoleService.roleAdmin,
            approvalStatus: RoleService.statusApproved,
            isActive: true,
            updatedAt: now,
          );
          await CivicUserRole.db.updateRow(session, updated);
        }
        try {
          final authUser = await AuthUser.db.findById(
            session,
            authSuccess.authUserId,
          );
          if (authUser != null &&
              !authUser.scopeNames.contains(Scope.admin.name!)) {
            final updatedAuth = authUser.copyWith(
              scopeNames: {...authUser.scopeNames, Scope.admin.name!},
            );
            await AuthUser.db.updateRow(session, updatedAuth);
          }
        } catch (_) {}
      }

      // Also ensure UserProfile exists
      final existingProfile = await UserProfile.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authSuccess.authUserId),
      );
      if (existingProfile == null && rawEmail != null) {
        await UserProfile.db.insertRow(
          session,
          UserProfile(
            authUserId: authSuccess.authUserId,
            userName: rawEmail.split('@').first,
            email: rawEmail,
            createdAt: now,
          ),
        );
      }
    } catch (e, st) {
      session.log(
        'EmailIdpEndpoint.finishRegistration error setting role: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
    }

    return authSuccess;
  }
}
