import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import '../issues/role_service.dart';

/// Safe local-development-only provisioning utility for CivicLoop.
///
/// Automatically ensures that development and demo accounts exist with
/// proper Serverpod authentication records and trusted CivicUserRole permissions.
class DevProvisioning {
  static const String defaultAdminEmail = 'admin@official.civicloop';
  static const String defaultAdminPassword = 'AdminPassword123!';
  static const String defaultAdminName = 'Municipal Administrator';

  static const String defaultEmployeeEmail = 'worker@civicloop.local';
  static const String defaultEmployeePassword = 'WorkerPassword123!';
  static const String defaultEmployeeName = 'Alex Rivera (Field Ops)';
  static const String defaultEmployeeDept = 'Public Works & Roads';

  /// Provisions or synchronizes local development accounts using Serverpod's
  /// authenticating system and persistent role storage.
  static Future<void> provision(Session session) async {
    final now = DateTime.now();
    final emailAdmin = AuthServices.getIdentityProvider<EmailIdp>().admin;

    // 1. Provision / sync Admin account (admin@official.civicloop)
    try {
      final existingAdminAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.email.equals(defaultAdminEmail),
      );

      UuidValue adminAuthId;
      if (existingAdminAcc == null) {
        final authUser = await AuthServices.instance.authUsers.create(
          session,
          scopes: {Scope.admin},
        );
        adminAuthId = authUser.id;

        await emailAdmin.createEmailAuthentication(
          session,
          authUserId: adminAuthId,
          email: defaultAdminEmail,
          password: defaultAdminPassword,
        );

        final profile = await UserProfile.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(adminAuthId),
        );
        if (profile == null) {
          await UserProfile.db.insertRow(
            session,
            UserProfile(
              authUserId: adminAuthId,
              userName: defaultAdminName,
              email: defaultAdminEmail,
              createdAt: now,
            ),
          );
        }
      } else {
        adminAuthId = existingAdminAcc.authUserId;
        // Ensure user has admin scope
        final authUser = await AuthUser.db.findById(session, adminAuthId);
        if (authUser != null && !authUser.scopeNames.contains(Scope.admin.name!)) {
          final updated = authUser.copyWith(
            scopeNames: {...authUser.scopeNames, Scope.admin.name!},
          );
          await AuthUser.db.updateRow(session, updated);
        }
        // Set predictable dev password
        await emailAdmin.setPassword(
          session,
          email: defaultAdminEmail,
          password: defaultAdminPassword,
        );
      }

      // Ensure CivicUserRole record exists
      final existingAdminRole = await CivicUserRole.db.findFirstRow(
        session,
        where: (t) =>
            t.userId.equals(adminAuthId.toString()) |
            t.email.equals(defaultAdminEmail),
      );
      if (existingAdminRole == null) {
        await CivicUserRole.db.insertRow(
          session,
          CivicUserRole(
            userId: adminAuthId.toString(),
            email: defaultAdminEmail,
            fullName: defaultAdminName,
            role: RoleService.roleAdmin,
            department: 'Executive Management',
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else if (existingAdminRole.role != RoleService.roleAdmin ||
          !existingAdminRole.isActive) {
        final updated = existingAdminRole.copyWith(
          role: RoleService.roleAdmin,
          isActive: true,
          updatedAt: now,
        );
        await CivicUserRole.db.updateRow(session, updated);
      }
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error provisioning default admin: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }

    // 2. Provision / sync Field Worker account (worker@civicloop.local)
    try {
      final existingWorkerAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.email.equals(defaultEmployeeEmail),
      );

      UuidValue workerAuthId;
      if (existingWorkerAcc == null) {
        final authUser = await AuthServices.instance.authUsers.create(
          session,
          scopes: {},
        );
        workerAuthId = authUser.id;

        await emailAdmin.createEmailAuthentication(
          session,
          authUserId: workerAuthId,
          email: defaultEmployeeEmail,
          password: defaultEmployeePassword,
        );

        final profile = await UserProfile.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(workerAuthId),
        );
        if (profile == null) {
          await UserProfile.db.insertRow(
            session,
            UserProfile(
              authUserId: workerAuthId,
              userName: defaultEmployeeName,
              email: defaultEmployeeEmail,
              createdAt: now,
            ),
          );
        }
      } else {
        workerAuthId = existingWorkerAcc.authUserId;
        await emailAdmin.setPassword(
          session,
          email: defaultEmployeeEmail,
          password: defaultEmployeePassword,
        );
      }

      // Ensure CivicUserRole record exists
      final existingWorkerRole = await CivicUserRole.db.findFirstRow(
        session,
        where: (t) =>
            t.userId.equals(workerAuthId.toString()) |
            t.email.equals(defaultEmployeeEmail),
      );
      if (existingWorkerRole == null) {
        await CivicUserRole.db.insertRow(
          session,
          CivicUserRole(
            userId: workerAuthId.toString(),
            email: defaultEmployeeEmail,
            fullName: defaultEmployeeName,
            role: RoleService.roleEmployee,
            department: defaultEmployeeDept,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else if (existingWorkerRole.role != RoleService.roleEmployee ||
          !existingWorkerRole.isActive) {
        final updated = existingWorkerRole.copyWith(
          role: RoleService.roleEmployee,
          isActive: true,
          updatedAt: now,
        );
        await CivicUserRole.db.updateRow(session, updated);
      }
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error provisioning default worker: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }

    // 3. Sync existing demo admin (nani@official.civicloop) if registered
    try {
      const existingUserEmail = 'nani@official.civicloop';
      final naniAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.email.equals(existingUserEmail),
      );
      if (naniAcc != null) {
        final authUser = await AuthUser.db.findById(session, naniAcc.authUserId);
        if (authUser != null && !authUser.scopeNames.contains(Scope.admin.name!)) {
          final updated = authUser.copyWith(
            scopeNames: {...authUser.scopeNames, Scope.admin.name!},
          );
          await AuthUser.db.updateRow(session, updated);
        }

        final naniRole = await CivicUserRole.db.findFirstRow(
          session,
          where: (t) =>
              t.userId.equals(naniAcc.authUserId.toString()) |
              t.email.equals(existingUserEmail),
        );
        if (naniRole == null) {
          await CivicUserRole.db.insertRow(
            session,
            CivicUserRole(
              userId: naniAcc.authUserId.toString(),
              email: existingUserEmail,
              fullName: 'Nani (Admin)',
              role: RoleService.roleAdmin,
              department: 'Administration',
              isActive: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
        } else if (naniRole.role != RoleService.roleAdmin || !naniRole.isActive) {
          final updated = naniRole.copyWith(
            role: RoleService.roleAdmin,
            isActive: true,
            updatedAt: now,
          );
          await CivicUserRole.db.updateRow(session, updated);
        }
      }
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error syncing nani@official.civicloop: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }
  }
}
