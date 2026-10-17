import 'package:civicloop_client/civicloop_client.dart';
import 'package:civicloop_flutter/client.dart';
import 'package:civicloop_flutter/screens/auth_dialog.dart';
import 'package:civicloop_flutter/screens/home_screen.dart';
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
  Future<List<Issue>> getIssues({String? category, String? status}) async => [];

  @override
  Future<List<Issue>> getMyIssues() async => [];

  @override
  Future<List<Issue>> getAnonymousIssues(List<int> issueIds) async => [];

  @override
  Future<StaffUserInfo?> getCurrentUserProfile() async => null;
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
    testWidgets('HomeScreen AppBar does not overflow on a narrow 360px screen', (
      tester,
    ) async {
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
    });

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
        expect(find.text('Sign In with Email'), findsOneWidget);

        // Open email auth view
        await tester.tap(find.text('Sign In with Email'));
        await tester.pumpAndSettle();

        // Check login screen renders and options wrap
        expect(find.text('Sign In'), findsWidgets);
        expect(find.text("Don't have an account?"), findsOneWidget);
        expect(find.text('Sign up'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to registration screen
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Check registration screen renders "Already have an account? Sign in" without overflow
        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('Already have an account?'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
