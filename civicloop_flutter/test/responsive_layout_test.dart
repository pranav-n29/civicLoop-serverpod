import 'package:civicloop_client/civicloop_client.dart';
import 'package:civicloop_flutter/client.dart';
import 'package:civicloop_flutter/screens/admin_dashboard_screen.dart';
import 'package:civicloop_flutter/screens/auth_dialog.dart';
import 'package:civicloop_flutter/screens/create_issue_screen.dart';
import 'package:civicloop_flutter/screens/employee_dashboard_screen.dart';
import 'package:civicloop_flutter/screens/home_screen.dart';
import 'package:civicloop_flutter/screens/issue_detail_screen.dart';
import 'package:civicloop_flutter/screens/my_issues_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

class _MockAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _data;
  @override
  Future<void> set(AuthSuccess? data) async => _data = data;
  @override
  Future<AuthSuccess?> get() async => _data;
}

class _FakeEndpointIssue extends EndpointIssue {
  _FakeEndpointIssue(super.caller);

  @override
  Future<List<Issue>> getIssues() async => [];

  @override
  Future<List<Issue>> getMyIssues() async => [];

  @override
  Future<StaffUserInfo?> getCurrentUserProfile() async => StaffUserInfo(
    userId: '1',
    email: 'field.technician.alexander@employeecivic.com',
    fullName: 'Lead Field Specialist Alexander Montgomery',
    role: 'employee',
    department: 'Roads & Infrastructure Maintenance',
    isActive: true,
    activeAssignedCasesCount: 3,
    employeeId: 'EMP-9921',
    approvalStatus: 'approved',
  );

  @override
  Future<AdminDashboardStats> getAdminStats() async => AdminDashboardStats(
    totalReports: 42,
    openReports: 14,
    assignedReports: 8,
    inProgressReports: 6,
    resolvedReports: 10,
    closedReports: 4,
    reopenedReports: 2,
    rejectedReports: 1,
    overdueReports: 0,
  );

  @override
  Future<List<Issue>> getAdminIssues({
    String? status,
    String? category,
    String? department,
    String? priority,
    String? assignedEmployeeId,
    String? search,
    int? limit,
    int? offset,
  }) async => [
    Issue(
      id: 101,
      title:
          'Extremely Large Hazardous Pothole on Downtown Oakridge Expressway Main Corridor',
      description:
          'Major road hazard affecting multiple lanes with vehicle damage reports incoming continuously.',
      category: 'Roads & Infrastructure',
      status: 'assigned',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      priority: 'critical',
      department: 'Roads & Infrastructure Maintenance',
      assignedEmployeeId: 'EMP-9921',
      assignedEmployeeName:
          'Lead Field Specialist Alexander Montgomery Longname',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      latitude: 37.7749,
      longitude: -122.4194,
    ),
  ];

  @override
  Future<List<StaffUserInfo>> getStaffUsers() async => [
    StaffUserInfo(
      userId: '1',
      email: 'field.technician.alexander@employeecivic.com',
      fullName: 'Lead Field Specialist Alexander Montgomery',
      role: 'employee',
      department: 'Roads & Infrastructure Maintenance',
      isActive: true,
      activeAssignedCasesCount: 5,
      employeeId: 'EMP-9921',
      approvalStatus: 'approved',
    ),
  ];

  @override
  Future<List<Issue>> getEmployeeAssignedIssues() async => [
    Issue(
      id: 102,
      title: 'Damaged Guardrail and Debris on North Ridge Overpass',
      description: 'Severe structural bend in guardrail.',
      category: 'Roads & Infrastructure',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      priority: 'high',
      department: 'Roads',
      assignedEmployeeId: 'EMP-9921',
      assignedEmployeeName: 'Lead Field Specialist Alexander Montgomery',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      latitude: 37.7833,
      longitude: -122.4167,
    ),
  ];

  @override
  Future<List<CivicIssueAudit>> getIssueAuditHistory(
    int issueId, {
    String? claimToken,
  }) async => [
    CivicIssueAudit(
      issueId: issueId,
      actorId: 'admin_1',
      actorRole: 'admin',
      actorName: 'City Administrator',
      action: 'case_assigned_and_scheduled',
      previousStatus: 'open_for_triage',
      newStatus: 'under_investigation',
      notes: 'Assigned to field technician for immediate resolution.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
}

class _MockClient extends Client {
  final _FakeEndpointIssue fakeIssue;
  _MockClient(this.fakeIssue) : super('http://localhost:8080/');

  @override
  EndpointIssue get issue => fakeIssue;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final fakeIssue = _FakeEndpointIssue(Client('http://localhost:8080/'));
    client = _MockClient(fakeIssue)
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = FlutterAuthSessionManager(
        storage: _MockAuthStorage(),
      );
  });

  group('Responsive Layout Tests - Narrow Screen Verification', () {
    testWidgets(
      'HomeScreen AppBar does not overflow on a narrow 360px screen',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('CivicLoop'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HomeScreen AppBar does not overflow on extra narrow 320px screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('CivicLoop'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'MyIssuesScreen buttons stack vertically on a narrow screen without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: MyIssuesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Personal Reports'), findsOneWidget);
        expect(find.text('Sign In / Register'), findsOneWidget);
        expect(find.text('Enter Claim Token'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AuthDialog renders cleanly on 320px narrow phone screen without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => AuthDialog.show(context),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Sign In / Account'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
        expect(find.widgetWithText(OutlinedButton, 'Register'), findsOneWidget);

        // Open email auth view
        await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
        await tester.pumpAndSettle();

        // Check login screen renders and options wrap
        expect(find.text('Account Sign In'), findsOneWidget);
        expect(find.text("Don't have an account?"), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Register'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to registration screen
        await tester.ensureVisible(find.widgetWithText(TextButton, 'Register'));
        await tester.tap(find.widgetWithText(TextButton, 'Register'));
        await tester.pumpAndSettle();

        // Check registration screen renders "Already have an account? Sign in" without overflow
        expect(find.text('Register'), findsWidgets);
        expect(find.text('Already have an account?'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Sign in'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AdminDashboardScreen renders header, badges, cards and staff directory without overflow on 360px and 320px',
      (tester) async {
        for (final width in [360.0, 320.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const MaterialApp(
              home: AdminDashboardScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Case Operations'), findsOneWidget);
          expect(find.text('Staff & Workloads'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Switch to Staff & Workloads tab
          await tester.tap(find.text('Staff & Workloads'));
          await tester.pumpAndSettle();

          expect(
            find.text('Lead Field Specialist Alexander Montgomery'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'EmployeeDashboardScreen renders banner, badges and action buttons without overflow on 360px and 320px',
      (tester) async {
        for (final width in [360.0, 320.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const MaterialApp(
              home: EmployeeDashboardScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.textContaining('Assigned Field Tasks'), findsOneWidget);
          expect(find.text('Details'), findsOneWidget);
          expect(find.text('Add Note'), findsOneWidget);
          expect(find.text('Resolve'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'IssueDetailScreen renders technician info, due date, banners and timeline without overflow on 360px and 320px',
      (tester) async {
        final testIssue = Issue(
          id: 201,
          title:
              'Hazardous Water Main Break Flooding Downtown Commercial Center',
          description:
              'Major water pressure rupture on Main St and 4th Avenue.',
          category: 'Water & Utilities',
          status: 'resolved',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          priority: 'critical',
          department: 'Public Works & Water Utilities',
          assignedEmployeeId: 'EMP-9921',
          assignedEmployeeName:
              'Lead Field Specialist Alexander Montgomery Longname',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          latitude: 37.7749,
          longitude: -122.4194,
        );

        for (final width in [360.0, 320.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialApp(
              home: IssueDetailScreen(issue: testIssue),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.textContaining('Details'), findsWidgets);
          expect(find.text('Audit Trail & Lifecycle History'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'CreateIssueScreen renders without overflow on 360px and 320px',
      (tester) async {
        for (final width in [360.0, 320.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: CreateIssueScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('1. What is the issue? (Description)'),
            findsOneWidget,
          );
          expect(find.text('2. Issue Title & Category'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );
  });
}
