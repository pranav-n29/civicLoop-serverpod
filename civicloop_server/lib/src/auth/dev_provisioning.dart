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
  // Required format administrator: name@civicloop.com
  static const String civicloopAdminEmail = 'admin@civicloop.com';
  static const String civicloopAdminPassword = 'AdminPassword123!';
  static const String civicloopAdminName = 'Municipal Administrator';

  // Required format field worker: employeeid@employeecivic.com
  static const String civicloopEmployeeEmail = 'emp101@employeecivic.com';
  static const String civicloopEmployeePassword = 'WorkerPassword123!';
  static const String civicloopEmployeeName = 'Alex Rivera (emp101)';

  // Backward compatibility test accounts
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

    // 1. Provision standard required Admin account (admin@civicloop.com)
    try {
      await _provisionAdmin(
        session,
        email: civicloopAdminEmail,
        password: civicloopAdminPassword,
        fullName: civicloopAdminName,
        department: 'Executive Management',
        emailAdmin: emailAdmin,
        now: now,
      );
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error provisioning admin@civicloop.com: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }

    // 2. Provision backward-compatible Admin account (admin@official.civicloop)
    try {
      await _provisionAdmin(
        session,
        email: defaultAdminEmail,
        password: defaultAdminPassword,
        fullName: defaultAdminName,
        department: 'Executive Management',
        emailAdmin: emailAdmin,
        now: now,
      );
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error provisioning admin@official.civicloop: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }

    // 3. Provision standard required Field Worker account (emp101@employeecivic.com)
    try {
      await _provisionEmployee(
        session,
        email: civicloopEmployeeEmail,
        password: civicloopEmployeePassword,
        fullName: civicloopEmployeeName,
        department: 'Field Operations & Roads',
        emailAdmin: emailAdmin,
        now: now,
      );
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error provisioning emp101@employeecivic.com: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }

    // 4. Provision backward-compatible Field Worker account (worker@civicloop.local)
    try {
      await _provisionEmployee(
        session,
        email: defaultEmployeeEmail,
        password: defaultEmployeePassword,
        fullName: defaultEmployeeName,
        department: defaultEmployeeDept,
        emailAdmin: emailAdmin,
        now: now,
      );
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error provisioning default worker: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }

    // 5. Sync existing demo admin (nani@official.civicloop) if registered
    try {
      const existingUserEmail = 'nani@official.civicloop';
      final naniAcc = await EmailAccount.db.findFirstRow(
        session,
        where: (t) => t.email.equals(existingUserEmail),
      );
      if (naniAcc != null) {
        final authUser = await AuthUser.db.findById(
          session,
          naniAcc.authUserId,
        );
        if (authUser != null &&
            !authUser.scopeNames.contains(Scope.admin.name!)) {
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
        } else if (naniRole.role != RoleService.roleAdmin ||
            !naniRole.isActive) {
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

    // 6. Development Demo Policy Reconciliation:
    // Safely reconcile all administrator accounts (@civicloop.com), including hani@civicloop.com,
    // ensuring they have roleAdmin, approvalStatus: statusApproved, isActive: true, and Scope.admin.
    try {
      await _reconcileAdminAccounts(session, now: now);
    } catch (e, st) {
      session.log(
        'DevProvisioning: Error reconciling admin accounts: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }
  }

  /// Automatically reconciles any existing administrator accounts ending with @civicloop.com
  /// ensuring they are active, approved, and granted Scope.admin.
  static Future<void> _reconcileAdminAccounts(
    Session session, {
    required DateTime now,
  }) async {
    // 1. Reconcile existing CivicUserRole records for admins
    final adminRoles = await CivicUserRole.db.find(
      session,
      where: (t) =>
          t.role.equals(RoleService.roleAdmin) |
          t.email.like('%@civicloop.com'),
    );

    for (final roleRecord in adminRoles) {
      final email = roleRecord.email;
      if (email != null && RoleService.isAdminEmail(email)) {
        if (roleRecord.approvalStatus != RoleService.statusApproved ||
            !roleRecord.isActive ||
            roleRecord.role != RoleService.roleAdmin) {
          final updated = roleRecord.copyWith(
            role: RoleService.roleAdmin,
            approvalStatus: RoleService.statusApproved,
            isActive: true,
            updatedAt: now,
          );
          await CivicUserRole.db.updateRow(session, updated);
        }
      }
    }

    // 2. Ensure all @civicloop.com EmailAccount holders have AuthUser with Scope.admin
    final adminEmailAccounts = await EmailAccount.db.find(
      session,
      where: (t) => t.email.like('%@civicloop.com'),
    );

    for (final acc in adminEmailAccounts) {
      final authUser = await AuthUser.db.findById(session, acc.authUserId);
      if (authUser != null &&
          !authUser.scopeNames.contains(Scope.admin.name!)) {
        final updated = authUser.copyWith(
          scopeNames: {...authUser.scopeNames, Scope.admin.name!},
        );
        await AuthUser.db.updateRow(session, updated);
      }

      // Ensure CivicUserRole exists
      final existingRole = await CivicUserRole.db.findFirstRow(
        session,
        where: (t) =>
            t.userId.equals(acc.authUserId.toString()) |
            t.email.equals(acc.email),
      );
      if (existingRole == null) {
        await CivicUserRole.db.insertRow(
          session,
          CivicUserRole(
            userId: acc.authUserId.toString(),
            email: acc.email,
            fullName: RoleService.formatStaffName(
              acc.email,
              RoleService.roleAdmin,
            ),
            role: RoleService.roleAdmin,
            approvalStatus: RoleService.statusApproved,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }

  static Future<void> _provisionAdmin(
    Session session, {
    required String email,
    required String password,
    required String fullName,
    required String department,
    required EmailIdpAdmin emailAdmin,
    required DateTime now,
  }) async {
    final existingAdminAcc = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
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
        email: email,
        password: password,
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
            userName: fullName,
            email: email,
            createdAt: now,
          ),
        );
      }
    } else {
      adminAuthId = existingAdminAcc.authUserId;
      final authUser = await AuthUser.db.findById(session, adminAuthId);
      if (authUser != null &&
          !authUser.scopeNames.contains(Scope.admin.name!)) {
        final updated = authUser.copyWith(
          scopeNames: {...authUser.scopeNames, Scope.admin.name!},
        );
        await AuthUser.db.updateRow(session, updated);
      }
      await emailAdmin.setPassword(
        session,
        email: email,
        password: password,
      );
    }

    final existingAdminRole = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(adminAuthId.toString()) | t.email.equals(email),
    );
    if (existingAdminRole == null) {
      await CivicUserRole.db.insertRow(
        session,
        CivicUserRole(
          userId: adminAuthId.toString(),
          email: email,
          fullName: fullName,
          role: RoleService.roleAdmin,
          department: department,
          approvalStatus: RoleService.statusApproved,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else if (existingAdminRole.role != RoleService.roleAdmin ||
        !existingAdminRole.isActive ||
        existingAdminRole.email != email ||
        existingAdminRole.approvalStatus != RoleService.statusApproved) {
      final updated = existingAdminRole.copyWith(
        role: RoleService.roleAdmin,
        email: email,
        approvalStatus: RoleService.statusApproved,
        isActive: true,
        updatedAt: now,
      );
      await CivicUserRole.db.updateRow(session, updated);
    }
  }

  static Future<void> _provisionEmployee(
    Session session, {
    required String email,
    required String password,
    required String fullName,
    required String department,
    required EmailIdpAdmin emailAdmin,
    required DateTime now,
  }) async {
    final existingWorkerAcc = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
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
        email: email,
        password: password,
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
            userName: fullName,
            email: email,
            createdAt: now,
          ),
        );
      }
    } else {
      workerAuthId = existingWorkerAcc.authUserId;
      await emailAdmin.setPassword(
        session,
        email: email,
        password: password,
      );
    }

    final empId = RoleService.extractEmployeeId(email);
    final existingWorkerRole = await CivicUserRole.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(workerAuthId.toString()) | t.email.equals(email),
    );
    if (existingWorkerRole == null) {
      await CivicUserRole.db.insertRow(
        session,
        CivicUserRole(
          userId: workerAuthId.toString(),
          email: email,
          fullName: fullName,
          role: RoleService.roleEmployee,
          department: department,
          employeeId: empId,
          approvalStatus: RoleService.statusApproved,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else if (existingWorkerRole.role != RoleService.roleEmployee ||
        !existingWorkerRole.isActive ||
        existingWorkerRole.email != email ||
        existingWorkerRole.approvalStatus != RoleService.statusApproved ||
        existingWorkerRole.employeeId != empId) {
      final updated = existingWorkerRole.copyWith(
        role: RoleService.roleEmployee,
        email: email,
        employeeId: empId,
        approvalStatus: RoleService.statusApproved,
        isActive: true,
        updatedAt: now,
      );
      await CivicUserRole.db.updateRow(session, updated);
    }
  }
}
