import 'package:civicloop_server/src/generated/protocol.dart';
import 'package:civicloop_server/src/issues/role_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given CivicLoop Role-Based Authentication', (
    sessionBuilder,
    endpoints,
  ) {
    const roleService = RoleService();

    group('1. Unified Registration and Role Classification', () {
      test(
        'RoleService classifies email formats and extracts employee identifiers',
        () {
          // Citizen emails
          expect(RoleService.isAdminEmail('citizen@gmail.com'), isFalse);
          expect(RoleService.isEmployeeEmail('citizen@gmail.com'), isFalse);
          expect(RoleService.isReservedDomain('citizen@gmail.com'), isFalse);

          // Admin emails (@civicloop.com)
          expect(RoleService.isAdminEmail('admin@civicloop.com'), isTrue);
          expect(RoleService.isEmployeeEmail('admin@civicloop.com'), isFalse);
          expect(RoleService.isReservedDomain('admin@civicloop.com'), isTrue);
          expect(
            RoleService.formatStaffName(
              'jane.doe@civicloop.com',
              RoleService.roleAdmin,
            ),
            equals('Jane Doe'),
          );

          // Employee emails (@employeecivic.com)
          expect(
            RoleService.isEmployeeEmail('emp101@employeecivic.com'),
            isTrue,
          );
          expect(RoleService.isAdminEmail('emp101@employeecivic.com'), isFalse);
          expect(
            RoleService.isReservedDomain('emp101@employeecivic.com'),
            isTrue,
          );
          expect(
            RoleService.extractEmployeeId('emp101@employeecivic.com'),
            equals('emp101'),
          );
          expect(
            RoleService.formatStaffName(
              'emp101@employeecivic.com',
              RoleService.roleEmployee,
            ),
            equals('Field Worker (emp101)'),
          );
        },
      );

      test(
        'Citizen registration creates active, approved citizen account',
        () async {
          const citizenId = 'citizen-unified-test-id';
          const citizenEmail = 'citizen.jane@gmail.com';

          final dbSession = sessionBuilder.build();
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: citizenId,
              email: citizenEmail,
              fullName: 'Jane Citizen',
              role: RoleService.roleCitizen,
              isActive: true,
              approvalStatus: RoleService.statusApproved,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          final role = await roleService.getRole(dbSession, citizenId);
          expect(role, equals(RoleService.roleCitizen));

          final citizenSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              citizenId,
              {},
            ),
          );
          final profile = await endpoints.issue.getCurrentUserProfile(
            citizenSession,
          );
          expect(profile, isNotNull);
          expect(profile!.role, equals(RoleService.roleCitizen));
          expect(profile.isActive, isTrue);
          expect(profile.approvalStatus, equals(RoleService.statusApproved));
        },
      );

      test(
        'Employee registration creates pending approval account without staff permissions until approved',
        () async {
          const empId = 'emp-pending-user-id';
          const empEmail = 'emp909@employeecivic.com';

          final dbSession = sessionBuilder.build();
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: empId,
              email: empEmail,
              employeeId: 'emp909',
              fullName: 'Alex Worker (emp909)',
              role: RoleService.roleEmployee,
              isActive: false,
              approvalStatus: RoleService.statusPending,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // Role can be resolved for routing without throwing deactivation error
          final role = await roleService.getRole(dbSession, empId);
          expect(role, equals(RoleService.roleEmployee));

          final pendingEmpSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              empId,
              {},
            ),
          );

          // Profile indicates pending approval
          final profile = await endpoints.issue.getCurrentUserProfile(
            pendingEmpSession,
          );
          expect(profile, isNotNull);
          expect(profile!.role, equals(RoleService.roleEmployee));
          expect(profile.isActive, isFalse);
          expect(profile.approvalStatus, equals(RoleService.statusPending));
          expect(profile.employeeId, equals('emp909'));

          // Cannot access employee endpoints while pending
          await expectLater(
            () => endpoints.issue.getEmployeeAssignedIssues(pendingEmpSession),
            throwsA(isA<ServerpodInsufficientAccessException>()),
          );

          // Admin approves the employee
          final adminSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'admin@civicloop.com',
              {const Scope('admin')},
            ),
          );
          final approved = await endpoints.issue.approveStaff(
            adminSession,
            empId,
            department: 'Field Maintenance',
          );
          expect(approved.isActive, isTrue);
          expect(approved.approvalStatus, equals(RoleService.statusApproved));
          expect(approved.department, equals('Field Maintenance'));

          // Now the employee can access assigned cases
          final assignedIssues = await endpoints.issue
              .getEmployeeAssignedIssues(
                pendingEmpSession,
              );
          expect(assignedIssues, isNotNull);
        },
      );

      test(
        'Admin issue assignment rejects pending or deactivated staff and accepts approved staff',
        () async {
          final adminSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'admin@civicloop.com',
              {const Scope('admin')},
            ),
          );

          final dbSession = sessionBuilder.build();

          // 1. Pending employee
          const pendingEmpId = 'worker-pending-assign';
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: pendingEmpId,
              email: 'emp301@employeecivic.com',
              employeeId: 'emp301',
              fullName: 'Pending Worker',
              role: RoleService.roleEmployee,
              isActive: false,
              approvalStatus: RoleService.statusPending,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // 2. Deactivated employee
          const deactEmpId = 'worker-deact-assign';
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: deactEmpId,
              email: 'emp302@employeecivic.com',
              employeeId: 'emp302',
              fullName: 'Deactivated Worker',
              role: RoleService.roleEmployee,
              isActive: false,
              approvalStatus: RoleService.statusApproved,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // 3. Approved active employee
          const approvedEmpId = 'worker-approved-assign';
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: approvedEmpId,
              email: 'emp303@employeecivic.com',
              employeeId: 'emp303',
              fullName: 'Approved Worker',
              role: RoleService.roleEmployee,
              isActive: true,
              approvalStatus: RoleService.statusApproved,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // Create an open issue
          final issue = await endpoints.issue.createIssue(
            sessionBuilder,
            Issue(
              title: 'Pothole for assignment',
              description: 'Needs asphalt repair',
              category: 'Roads',
              status: 'open',
              createdAt: DateTime.now(),
            ),
          );

          // Assigning to pending employee is rejected
          await expectLater(
            () => endpoints.issue.assignIssue(
              adminSession,
              issue.id!,
              pendingEmpId,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Target employee account is pending approval'),
              ),
            ),
          );

          // Assigning to deactivated employee is rejected
          await expectLater(
            () => endpoints.issue.assignIssue(
              adminSession,
              issue.id!,
              deactEmpId,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Target employee account is disabled'),
              ),
            ),
          );

          // Assigning to approved active employee succeeds
          final assignedIssue = await endpoints.issue.assignIssue(
            adminSession,
            issue.id!,
            approvedEmpId,
            department: 'Roads',
          );
          expect(assignedIssue.status, equals('assigned'));
          expect(assignedIssue.assignedEmployeeId, equals(approvedEmpId));

          // Verify assigned issue appears in employee dashboard
          final empSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              approvedEmpId,
              {},
            ),
          );
          final myCases = await endpoints.issue.getEmployeeAssignedIssues(
            empSession,
          );
          expect(myCases.any((i) => i.id == issue.id), isTrue);
        },
      );
    });

    group('2. Authorized Administrator Privileges & Email Format', () {
      test(
        'Admin with name@civicloop.com format has admin role and accesses admin endpoints',
        () async {
          final adminSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'admin@civicloop.com',
              {const Scope('admin')},
            ),
          );

          final profile = await endpoints.issue.getCurrentUserProfile(
            adminSession,
          );
          expect(profile, isNotNull);
          expect(profile!.role, equals('admin'));

          final stats = await endpoints.issue.getAdminStats(adminSession);
          expect(stats, isNotNull);

          final adminIssues = await endpoints.issue.getAdminIssues(
            adminSession,
          );
          expect(adminIssues, isNotNull);
        },
      );

      test(
        'Admin role with mismatched email format (e.g. personal @gmail.com) is denied access',
        () async {
          const imposterId = 'admin-imposter-id';
          const imposterEmail = 'imposter@gmail.com';

          final dbSession = sessionBuilder.build();
          final existing = await CivicUserRole.db.findFirstRow(
            dbSession,
            where: (t) => t.userId.equals(imposterId),
          );
          if (existing == null) {
            await CivicUserRole.db.insertRow(
              dbSession,
              CivicUserRole(
                userId: imposterId,
                email: imposterEmail,
                fullName: 'Fake Admin',
                role: RoleService.roleAdmin,
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          }

          // Direct RoleService check verifies the specific NotAuthorizedException message
          await expectLater(
            () => roleService.getRole(sessionBuilder.build(), imposterId),
            throwsA(
              isA<NotAuthorizedException>().having(
                (e) => e.message,
                'message',
                contains('Municipal Administrator format (name@civicloop.com)'),
              ),
            ),
          );

          // Endpoint invocation verifies ServerpodInsufficientAccessException is thrown to client
          final imposterSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              imposterId,
              {},
            ),
          );
          await expectLater(
            () => endpoints.issue.getCurrentUserProfile(imposterSession),
            throwsA(isA<ServerpodInsufficientAccessException>()),
          );
        },
      );
    });

    group('3. Authorized Employee Privileges & Email Format', () {
      test(
        'Employee with employeeid@employeecivic.com format has employee role and accesses assigned issues',
        () async {
          final employeeSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'emp101@employeecivic.com',
              {},
            ),
          );

          final dbSession = sessionBuilder.build();
          final existing = await CivicUserRole.db.findFirstRow(
            dbSession,
            where: (t) => t.userId.equals('emp101@employeecivic.com'),
          );
          if (existing == null) {
            await CivicUserRole.db.insertRow(
              dbSession,
              CivicUserRole(
                userId: 'emp101@employeecivic.com',
                email: 'emp101@employeecivic.com',
                fullName: 'Alex Rivera (emp101)',
                role: RoleService.roleEmployee,
                department: 'Field Operations',
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          }

          final profile = await endpoints.issue.getCurrentUserProfile(
            employeeSession,
          );
          expect(profile, isNotNull);
          expect(profile!.role, equals('employee'));

          final assigned = await endpoints.issue.getEmployeeAssignedIssues(
            employeeSession,
          );
          expect(assigned, isNotNull);
        },
      );

      test('Employee cannot access admin dashboard endpoints', () async {
        final employeeSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'emp101@employeecivic.com',
            {},
          ),
        );

        await expectLater(
          () => endpoints.issue.getAdminStats(employeeSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      });

      test('Employee role with mismatched email format is denied access', () async {
        const workerImposterId = 'worker-imposter-id';
        const workerImposterEmail = 'worker@yahoo.com';

        final dbSession = sessionBuilder.build();
        final existing = await CivicUserRole.db.findFirstRow(
          dbSession,
          where: (t) => t.userId.equals(workerImposterId),
        );
        if (existing == null) {
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: workerImposterId,
              email: workerImposterEmail,
              fullName: 'Fake Worker',
              role: RoleService.roleEmployee,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }

        // Direct RoleService check verifies the specific NotAuthorizedException message
        await expectLater(
          () => roleService.getRole(sessionBuilder.build(), workerImposterId),
          throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.message,
              'message',
              contains(
                'Field Operations Worker format (employeeid@employeecivic.com)',
              ),
            ),
          ),
        );

        // Endpoint invocation verifies ServerpodInsufficientAccessException is thrown to client
        final workerSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            workerImposterId,
            {},
          ),
        );
        await expectLater(
          () => endpoints.issue.getCurrentUserProfile(workerSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      });
    });

    group('4. Citizen Access Control and Restrictions', () {
      test('Citizen cannot access admin endpoints', () async {
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-mark@example.com',
            {},
          ),
        );

        await expectLater(
          () => endpoints.issue.getAdminStats(citizenSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
        await expectLater(
          () => endpoints.issue.getAdminIssues(citizenSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
        await expectLater(
          () => endpoints.issue.getStaffUsers(citizenSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      });

      test('Citizen cannot access employee assigned cases', () async {
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-mark@example.com',
            {},
          ),
        );

        await expectLater(
          () => endpoints.issue.getEmployeeAssignedIssues(citizenSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      });

      test(
        'Unprovisioned account with reserved staff email is denied access',
        () async {
          // Direct RoleService check verifies the specific NotAuthorizedException message
          await expectLater(
            () => roleService.getRole(
              sessionBuilder.build(),
              'random@civicloop.com',
            ),
            throwsA(
              isA<NotAuthorizedException>().having(
                (e) => e.message,
                'message',
                contains('Unauthorized staff account'),
              ),
            ),
          );

          final unprovisionedStaffSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'random@civicloop.com',
              {},
            ),
          );

          await expectLater(
            () => endpoints.issue.getCurrentUserProfile(
              unprovisionedStaffSession,
            ),
            throwsA(isA<ServerpodInsufficientAccessException>()),
          );
        },
      );
    });

    group('5. Role Modification and Deactivation Safeguards', () {
      test('Admin cannot modify their own role', () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@civicloop.com',
            {const Scope('admin')},
          ),
        );

        await expectLater(
          () => endpoints.issue.provisionStaff(
            adminSession,
            'admin@civicloop.com',
            'citizen',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Administrators cannot modify their own role.'),
            ),
          ),
        );
      });

      test('Admin cannot deactivate their own account', () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@civicloop.com',
            {const Scope('admin')},
          ),
        );

        // 1. Self-deactivation rejection by email
        await expectLater(
          () => endpoints.issue.setStaffActiveStatus(
            adminSession,
            'admin@civicloop.com',
            false,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Administrators cannot change their own active status.'),
            ),
          ),
        );

        // 2. Self-deactivation rejection by userId alias
        await expectLater(
          () => endpoints.issue.setStaffActiveStatus(
            adminSession,
            'admin@civicloop.com',
            true,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Administrators cannot change their own active status.'),
            ),
          ),
        );
      });

      test(
        'Administrator can activate and deactivate another eligible staff account',
        () async {
          final adminSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'admin@civicloop.com',
              {const Scope('admin')},
            ),
          );

          const targetWorkerId = 'worker-toggle-test-1';
          final dbSession = sessionBuilder.build();
          final existing = await CivicUserRole.db.findFirstRow(
            dbSession,
            where: (t) => t.userId.equals(targetWorkerId),
          );
          if (existing == null) {
            await CivicUserRole.db.insertRow(
              dbSession,
              CivicUserRole(
                userId: targetWorkerId,
                email: 'worker.toggle1@employeecivic.com',
                role: RoleService.roleEmployee,
                isActive: true,
                approvalStatus: RoleService.statusApproved,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          }

          // Deactivate other staff member
          final deactivated = await endpoints.issue.setStaffActiveStatus(
            adminSession,
            targetWorkerId,
            false,
          );
          expect(deactivated.isActive, isFalse);

          final dbCheck1 = await CivicUserRole.db.findFirstRow(
            dbSession,
            where: (t) => t.userId.equals(targetWorkerId),
          );
          expect(dbCheck1?.isActive, isFalse);

          // Reactivate other staff member
          final reactivated = await endpoints.issue.setStaffActiveStatus(
            adminSession,
            targetWorkerId,
            true,
          );
          expect(reactivated.isActive, isTrue);

          final dbCheck2 = await CivicUserRole.db.findFirstRow(
            dbSession,
            where: (t) => t.userId.equals(targetWorkerId),
          );
          expect(dbCheck2?.isActive, isTrue);
        },
      );

      test('Deactivated account is denied access with clear message', () async {
        const deactivatedId = 'deactivated-worker-99';
        final dbSession = sessionBuilder.build();
        final existing = await CivicUserRole.db.findFirstRow(
          dbSession,
          where: (t) => t.userId.equals(deactivatedId),
        );
        if (existing == null) {
          await CivicUserRole.db.insertRow(
            dbSession,
            CivicUserRole(
              userId: deactivatedId,
              email: 'worker99@employeecivic.com',
              role: RoleService.roleEmployee,
              isActive: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }

        // Direct RoleService check verifies the specific NotAuthorizedException message
        await expectLater(
          () => roleService.getRole(sessionBuilder.build(), deactivatedId),
          throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.message,
              'message',
              contains('Account has been deactivated.'),
            ),
          ),
        );

        // Endpoint invocation verifies ServerpodInsufficientAccessException is thrown to client
        final deactivatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            deactivatedId,
            {},
          ),
        );

        await expectLater(
          () => endpoints.issue.getCurrentUserProfile(deactivatedSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      });
    });

    group(
      '6. Development Demo Policy: Auto-Approved Municipal Admins and Reconciliation',
      () {
        test(
          'hani@civicloop.com is safely reconciled, active, approved, and granted admin dashboard access',
          () async {
            const haniId = 'hani-reconciliation-test-id';
            const haniEmail = 'hani@civicloop.com';

            final dbSession = sessionBuilder.build();
            final existing = await CivicUserRole.db.findFirstRow(
              dbSession,
              where: (t) => t.userId.equals(haniId) | t.email.equals(haniEmail),
            );
            if (existing == null) {
              await CivicUserRole.db.insertRow(
                dbSession,
                CivicUserRole(
                  userId: haniId,
                  email: haniEmail,
                  fullName: 'Hani (Admin)',
                  role: RoleService.roleAdmin,
                  approvalStatus: RoleService.statusPending,
                  isActive: false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
            }

            final haniSession = sessionBuilder.copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                haniId,
                {const Scope('admin')},
              ),
            );

            // Profile retrieval auto-reconciles and returns active approved admin profile
            final profile = await endpoints.issue.getCurrentUserProfile(
              haniSession,
            );
            expect(profile, isNotNull);
            expect(profile!.role, equals(RoleService.roleAdmin));
            expect(profile.isActive, isTrue);
            expect(profile.approvalStatus, equals(RoleService.statusApproved));

            // Admin stats can be accessed without exception
            final stats = await endpoints.issue.getAdminStats(haniSession);
            expect(stats, isNotNull);

            // Database record is now reconciled
            final reconciledRole = await CivicUserRole.db.findFirstRow(
              dbSession,
              where: (t) => t.userId.equals(haniId) | t.email.equals(haniEmail),
            );
            expect(
              reconciledRole?.approvalStatus,
              equals(RoleService.statusApproved),
            );
            expect(reconciledRole?.isActive, isTrue);
          },
        );

        test(
          'New verified @civicloop.com account receives active approved admin role immediately without manual approval',
          () async {
            const newAdminId = 'new-admin-test-id';
            const newAdminEmail = 'sarah@civicloop.com';

            final dbSession = sessionBuilder.build();
            await CivicUserRole.db.insertRow(
              dbSession,
              CivicUserRole(
                userId: newAdminId,
                email: newAdminEmail,
                fullName: 'Sarah Admin',
                role: RoleService.roleAdmin,
                approvalStatus: RoleService.statusApproved,
                isActive: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            final newAdminSession = sessionBuilder.copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                newAdminId,
                {const Scope('admin')},
              ),
            );

            final profile = await endpoints.issue.getCurrentUserProfile(
              newAdminSession,
            );
            expect(profile, isNotNull);
            expect(profile!.role, equals(RoleService.roleAdmin));
            expect(profile.isActive, isTrue);
            expect(profile.approvalStatus, equals(RoleService.statusApproved));

            // Can access admin stats and staff directory
            final stats = await endpoints.issue.getAdminStats(newAdminSession);
            expect(stats, isNotNull);
            final staff = await endpoints.issue.getStaffUsers(newAdminSession);
            expect(staff, isNotNull);
          },
        );

        test(
          'Citizen account accesses Citizen Home and cannot call admin-only endpoints',
          () async {
            final citizenSession = sessionBuilder.copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'citizen-reg-verified@gmail.com',
                {},
              ),
            );

            final profile = await endpoints.issue.getCurrentUserProfile(
              citizenSession,
            );
            expect(profile, isNotNull);
            expect(profile!.role, equals(RoleService.roleCitizen));
            expect(profile.isActive, isTrue);
            expect(profile.approvalStatus, equals(RoleService.statusApproved));

            await expectLater(
              () => endpoints.issue.getAdminStats(citizenSession),
              throwsA(isA<ServerpodInsufficientAccessException>()),
            );
            await expectLater(
              () => endpoints.issue.getStaffUsers(citizenSession),
              throwsA(isA<ServerpodInsufficientAccessException>()),
            );
          },
        );

        test(
          'Pending employee account cannot access admin-only endpoints or assigned tasks until approved',
          () async {
            const empId = 'emp-pending-verify-id';
            const empEmail = 'emp998@employeecivic.com';

            final dbSession = sessionBuilder.build();
            await CivicUserRole.db.insertRow(
              dbSession,
              CivicUserRole(
                userId: empId,
                email: empEmail,
                employeeId: 'emp998',
                fullName: 'Worker Pending',
                role: RoleService.roleEmployee,
                approvalStatus: RoleService.statusPending,
                isActive: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            final empSession = sessionBuilder.copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                empId,
                {},
              ),
            );

            // Cannot call admin endpoints
            await expectLater(
              () => endpoints.issue.getAdminStats(empSession),
              throwsA(isA<ServerpodInsufficientAccessException>()),
            );

            // Cannot access employee tasks while pending
            await expectLater(
              () => endpoints.issue.getEmployeeAssignedIssues(empSession),
              throwsA(isA<ServerpodInsufficientAccessException>()),
            );

            // Admin approves the employee
            final adminSession = sessionBuilder.copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'admin@civicloop.com',
                {const Scope('admin')},
              ),
            );
            final approved = await endpoints.issue.approveStaff(
              adminSession,
              empId,
              department: 'Roads & Sanitation',
            );
            expect(approved.approvalStatus, equals(RoleService.statusApproved));
            expect(approved.isActive, isTrue);

            // Now employee can access assigned tasks
            final assigned = await endpoints.issue.getEmployeeAssignedIssues(
              empSession,
            );
            expect(assigned, isNotNull);
          },
        );

        test('Session restoration and logout work correctly', () async {
          // Restoring valid session returns profile
          final adminSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'admin@civicloop.com',
              {const Scope('admin')},
            ),
          );
          final profile = await endpoints.issue.getCurrentUserProfile(
            adminSession,
          );
          expect(profile, isNotNull);
          expect(profile!.role, equals('admin'));

          // Unauthenticated session (simulating logged out client) returns null
          final unauthProfile = await endpoints.issue.getCurrentUserProfile(
            sessionBuilder,
          );
          expect(unauthProfile, isNull);
        });
      },
    );
  });
}
