import 'package:civicloop_client/civicloop_client.dart';
import 'package:civicloop_flutter/client.dart';
import 'package:civicloop_flutter/screens/auth_dialog.dart';
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

  StaffUserInfo? mockProfile;

  @override
  Future<List<Issue>> getIssues() async => [];

  @override
  Future<List<Issue>> getMyIssues() async => [];

  @override
  Future<StaffUserInfo?> getCurrentUserProfile() async => mockProfile;
}

class _MockClient extends Client {
  final _FakeEndpointIssue fakeIssue;
  _MockClient(this.fakeIssue) : super('http://localhost:8080/');

  @override
  EndpointIssue get issue => fakeIssue;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeEndpointIssue fakeIssue;
  late _MockAuthStorage authStorage;

  setUp(() {
    fakeIssue = _FakeEndpointIssue(Client('http://localhost:8080/'));
    authStorage = _MockAuthStorage();
    client = _MockClient(fakeIssue)
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = FlutterAuthSessionManager(
        storage: authStorage,
      );
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => AuthDialog.show(context),
              child: const Text('Open Auth Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('Role-Based AuthDialog Widget Tests', () {
    testWidgets(
      'Displays one common authentication entry point with Sign In and Register',
      (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Open Auth Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Sign In / Account'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
        expect(find.widgetWithText(OutlinedButton, 'Register'), findsOneWidget);
        expect(
          find.textContaining('CivicLoop supports anonymous civic reporting'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Unified registration form accepts citizen, admin, and employee emails with role preview badges and enables continue',
      (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Open Auth Dialog'));
        await tester.pumpAndSettle();

        // Tap common Register button
        await tester.tap(find.widgetWithText(OutlinedButton, 'Register'));
        await tester.pumpAndSettle();

        expect(find.text('Register'), findsOneWidget);

        final emailField = find.byType(TextField).first;
        final continueButton = find.widgetWithText(FilledButton, 'Continue');

        // 1. Enter admin email (@civicloop.com)
        await tester.enterText(emailField, 'admin@civicloop.com');
        await tester.pumpAndSettle();

        // Verify admin preview badge appears and continue button is enabled
        expect(
          find.textContaining('Municipal Administrator account'),
          findsOneWidget,
        );
        final FilledButton buttonWidget1 = tester.widget(continueButton);
        expect(buttonWidget1.onPressed, isNotNull);

        // 2. Enter employee email (@employeecivic.com)
        await tester.enterText(emailField, 'emp101@employeecivic.com');
        await tester.pumpAndSettle();

        // Verify employee preview badge appears and continue button is enabled
        expect(
          find.textContaining('Field Operations Worker account (ID: emp101)'),
          findsOneWidget,
        );
        final FilledButton buttonWidget2 = tester.widget(continueButton);
        expect(buttonWidget2.onPressed, isNotNull);

        // 3. Enter citizen email
        await tester.enterText(emailField, 'citizen.jane@gmail.com');
        await tester.pumpAndSettle();

        // Verify citizen badge appears and continue button is enabled
        expect(
          find.textContaining('Standard Citizen account'),
          findsOneWidget,
        );
        final FilledButton buttonWidget3 = tester.widget(continueButton);
        expect(buttonWidget3.onPressed, isNotNull);

        // Drain controller debounce timer
        await tester.pump(const Duration(milliseconds: 600));
      },
    );

    testWidgets(
      'Login form displays allowed email formats for each role and link to Register',
      (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Open Auth Dialog'));
        await tester.pumpAndSettle();

        // Open Sign In
        await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Account Sign In'), findsOneWidget);
        expect(
          find.textContaining('Citizens: Any valid personal email'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Admins: name@civicloop.com'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Field Workers: employeeid@employeecivic.com'),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextButton, 'Register'), findsOneWidget);
      },
    );
  });
}
