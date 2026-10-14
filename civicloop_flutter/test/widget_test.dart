import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:civicloop_client/civicloop_client.dart';
import 'package:civicloop_flutter/client.dart';
import 'package:civicloop_flutter/main.dart';
import 'package:civicloop_flutter/screens/admin_dashboard_screen.dart';
import 'package:civicloop_flutter/screens/create_issue_screen.dart';
import 'package:civicloop_flutter/screens/employee_dashboard_screen.dart';
import 'package:civicloop_flutter/utils/custom_image_picker.dart';
import 'package:civicloop_flutter/utils/sample_photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

class MockAuthSuccessStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _data;

  @override
  Future<void> set(AuthSuccess? data) async {
    _data = data;
  }

  @override
  Future<AuthSuccess?> get() async {
    return _data;
  }
}

class FakeEndpointIssue extends EndpointIssue {
  FakeEndpointIssue(super.caller);

  Issue? lastCreatedIssue;
  int? lastPhotoIssueId;
  String? lastPhotoFileName;
  ByteData? lastPhotoImageBytes;
  String? lastUploadToken;
  bool shouldFailPhotoUpload = false;

  void reset() {
    lastCreatedIssue = null;
    lastPhotoIssueId = null;
    lastPhotoFileName = null;
    lastPhotoImageBytes = null;
    lastUploadToken = null;
    shouldFailPhotoUpload = false;
  }

  @override
  Future<Issue> createIssue(Issue issue) async {
    lastCreatedIssue = issue;
    return Issue(
      id: 42,
      title: issue.title,
      description: issue.description,
      category: issue.category,
      status: 'open',
      createdAt: DateTime.now(),
      latitude: issue.latitude,
      longitude: issue.longitude,
      uploadToken: 'mock_token_for_issue_42',
    );
  }

  @override
  Future<Issue> attachIssuePhoto(
    int issueId,
    String fileName,
    ByteData imageBytes, {
    String? uploadToken,
  }) async {
    if (shouldFailPhotoUpload) {
      throw Exception('Server rejected photo upload');
    }
    lastPhotoIssueId = issueId;
    lastPhotoFileName = fileName;
    lastPhotoImageBytes = imageBytes;
    lastUploadToken = uploadToken;
    return Issue(
      id: issueId,
      title: lastCreatedIssue?.title ?? 'Title',
      description: lastCreatedIssue?.description ?? 'Desc',
      category: lastCreatedIssue?.category ?? 'Other',
      status: 'open',
      createdAt: DateTime.now(),
      photoPath: '/photos/$issueId/$fileName',
      uploadToken: uploadToken,
    );
  }

  StaffUserInfo? currentUserProfile;
  List<CivicNotification> notifications = [];
  AdminDashboardStats? adminStats;
  List<Issue> adminIssues = [];
  List<Issue> employeeIssues = [];
  List<StaffUserInfo> staffUsers = [];

  @override
  Future<StaffUserInfo?> getCurrentUserProfile() async {
    return currentUserProfile;
  }

  @override
  Future<List<CivicNotification>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    if (unreadOnly == true) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  @override
  Future<AdminDashboardStats> getAdminStats() async {
    return adminStats ??
        AdminDashboardStats(
          totalReports: 10,
          openReports: 3,
          assignedReports: 2,
          inProgressReports: 2,
          resolvedReports: 2,
          closedReports: 1,
          reopenedReports: 0,
          rejectedReports: 0,
          overdueReports: 1,
        );
  }

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
  }) async {
    return adminIssues;
  }

  @override
  Future<List<Issue>> getEmployeeAssignedIssues() async {
    return employeeIssues;
  }

  @override
  Future<List<StaffUserInfo>> getStaffUsers() async {
    return staffUsers;
  }
}

class MockCivicLoopClient extends Client {
  final FakeEndpointIssue fakeIssue;

  MockCivicLoopClient(this.fakeIssue) : super('http://localhost:8080/');

  @override
  EndpointIssue get issue => fakeIssue;
}

void main() {
  late FakeEndpointIssue fakeEndpointIssue;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    fakeEndpointIssue = FakeEndpointIssue(Client('http://localhost:8080/'));
    client = MockCivicLoopClient(fakeEndpointIssue)
      ..connectivityMonitor = FlutterConnectivityMonitor()
      ..authSessionManager = FlutterAuthSessionManager(
        storage: MockAuthSuccessStorage(),
      );
    CustomImagePicker.pickCustomImageOverride = null;
  });

  tearDown(() {
    CustomImagePicker.pickCustomImageOverride = null;
  });

  group('PhotoUtils & SamplePhoto Tests', () {
    test('validates file extensions correctly', () {
      expect(PhotoUtils.validateExtension('pothole.jpg'), isNull);
      expect(PhotoUtils.validateExtension('photo.JPEG'), isNull);
      expect(PhotoUtils.validateExtension('road.png'), isNull);
      expect(PhotoUtils.validateExtension('leak.webp'), isNull);

      expect(PhotoUtils.validateExtension(''), isNotNull);
      expect(PhotoUtils.validateExtension('   '), isNotNull);
      expect(PhotoUtils.validateExtension('noextension'), isNotNull);
      expect(PhotoUtils.validateExtension('document.pdf'), isNotNull);
      expect(PhotoUtils.validateExtension('malware.exe'), isNotNull);
    });

    test('validates photo byte size correctly', () {
      final validBytes = Uint8List(1024 * 1024); // 1 MB
      expect(PhotoUtils.validateBytes(validBytes), isNull);

      final emptyBytes = Uint8List(0);
      expect(PhotoUtils.validateBytes(emptyBytes), contains('empty'));

      final oversizedBytes = Uint8List(5 * 1024 * 1024 + 1); // 5 MB + 1 byte
      expect(PhotoUtils.validateBytes(oversizedBytes), contains('exceeds'));
    });

    test('formats byte sizes into readable units', () {
      expect(PhotoUtils.formatBytes(500), equals('500 B'));
      expect(PhotoUtils.formatBytes(1500), equals('1.5 KB'));
      expect(PhotoUtils.formatBytes(2 * 1024 * 1024), equals('2.00 MB'));
    });

    test('sample photos are valid non-empty assets', () {
      expect(PhotoUtils.samplePhotos.length, equals(4));

      for (final sample in PhotoUtils.samplePhotos) {
        expect(sample.id, isNotEmpty);
        expect(sample.name, isNotEmpty);
        expect(sample.fileName, endsWith('.png'));
        expect(sample.bytes, isNotEmpty);
        expect(sample.byteData.lengthInBytes, greaterThan(0));
      }
    });

    testWidgets(
      'all sample photos are genuine valid PNGs decodable by Flutter engine',
      (tester) async {
        final pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

        for (final sample in PhotoUtils.samplePhotos) {
          final bytes = sample.bytes;
          expect(bytes.length, greaterThan(8));
          expect(
            bytes.sublist(0, 8),
            equals(pngSignature),
            reason: '${sample.name} must have valid PNG signature',
          );
          expect(bytes.length, lessThan(PhotoUtils.maxPhotoBytes));
          expect(PhotoUtils.validateExtension(sample.fileName), isNull);
          expect(PhotoUtils.validateBytes(bytes), isNull);

          await tester.runAsync(() async {
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            expect(
              frame.image.width,
              equals(64),
              reason: '${sample.name} width should be 64',
            );
            expect(
              frame.image.height,
              equals(64),
              reason: '${sample.name} height should be 64',
            );
          });
        }
      },
    );
  });

  group('CivicLoopApp Widget Tests', () {
    testWidgets('renders home screen with app bar and navigation tabs', (
      tester,
    ) async {
      await tester.pumpWidget(const CivicLoopApp());
      await tester.pump();

      expect(find.text('CivicLoop'), findsOneWidget);
      expect(find.text('Urban Issue Triage & Management'), findsOneWidget);
      expect(find.text('Issue Feed'), findsOneWidget);
      expect(find.text('My Reports'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('can navigate to Report Issue tab and see form fields', (
      tester,
    ) async {
      await tester.pumpWidget(const CivicLoopApp());
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Report Issue'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Auto-Triage'), findsOneWidget);
      expect(find.textContaining('Issue Title & Category'), findsOneWidget);
      expect(find.text('Submit Civic Issue Report'), findsOneWidget);
      expect(find.byKey(const Key('upload_photo_button')), findsOneWidget);
    });

    testWidgets('can navigate to My Reports tab', (tester) async {
      await tester.pumpWidget(const CivicLoopApp());
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('My Reports'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal Reports'), findsOneWidget);
      expect(find.text('Sign In / Register'), findsOneWidget);
    });

    testWidgets(
      'selecting each sample photo renders Image.memory preview and matches upload bytes',
      (tester) async {
        await tester.pumpWidget(const CivicLoopApp());
        await tester.pump();

        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Report Issue'),
          ),
        );
        await tester.pumpAndSettle();

        final expectedSamples = [
          ('Pothole on Main St', 'pothole_evidence.png', '1.2 KB', 1236),
          (
            'Flickering Streetlight',
            'streetlight_evidence.png',
            '1.0 KB',
            1040,
          ),
          ('Burst Water Pipe', 'water_leak_evidence.png', '1.6 KB', 1603),
          ('Public Park Graffiti', 'graffiti_evidence.png', '1.5 KB', 1581),
        ];

        for (final (name, fileName, expectedSize, exactBytes)
            in expectedSamples) {
          await tester.ensureVisible(find.text(name));
          await tester.pumpAndSettle();
          await tester.tap(find.text(name));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('sample_photo_preview')), findsOneWidget);
          expect(find.textContaining(fileName), findsOneWidget);
          expect(find.textContaining(expectedSize), findsOneWidget);

          final sample = PhotoUtils.samplePhotos.firstWhere(
            (s) => s.name == name,
          );
          expect(sample.bytes.length, equals(exactBytes));
          final uploadData = PhotoUtils.toByteData(sample.bytes);
          expect(
            uploadData.buffer.asUint8List(
              uploadData.offsetInBytes,
              uploadData.lengthInBytes,
            ),
            equals(sample.bytes),
          );
        }
      },
    );
  });

  group('Photo Selection & Custom Image Upload Tests', () {
    testWidgets('initial state has NO photo selected by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
      );
      await tester.pumpAndSettle();

      // Ensure no sample photo preview is displayed
      expect(find.byKey(const Key('sample_photo_preview')), findsNothing);
      // Ensure no custom photo preview is displayed
      expect(find.byKey(const Key('custom_photo_preview')), findsNothing);
      // Ensure "Upload Your Photo" button is clearly present
      expect(find.byKey(const Key('upload_photo_button')), findsOneWidget);
      expect(find.text('Upload Your Photo'), findsOneWidget);
    });

    testWidgets('selecting and removing a sample photo works cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
      );
      await tester.pumpAndSettle();

      // Select first sample photo
      await tester.ensureVisible(find.text('Pothole on Main St'));
      await tester.tap(find.text('Pothole on Main St'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sample_photo_preview')), findsOneWidget);
      expect(find.textContaining('pothole_evidence.png'), findsOneWidget);

      // Tap remove button
      await tester.ensureVisible(
        find.byKey(const Key('remove_sample_photo_button')),
      );
      await tester.tap(find.byKey(const Key('remove_sample_photo_button')));
      await tester.pumpAndSettle();

      // Preview should now be gone
      expect(find.byKey(const Key('sample_photo_preview')), findsNothing);
    });

    testWidgets(
      'custom image picker loads image, displays preview, and can be removed',
      (tester) async {
        final mockBytes = PhotoUtils.samplePhotos[0].bytes;
        CustomImagePicker.pickCustomImageOverride = () async {
          return PickedFileData(
            fileName: 'my_neighborhood_pothole.png',
            bytes: mockBytes,
          );
        };

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
        );
        await tester.pumpAndSettle();

        // Tap Upload Your Photo
        await tester.ensureVisible(
          find.byKey(const Key('upload_photo_button')),
        );
        await tester.tap(find.byKey(const Key('upload_photo_button')));
        await tester.pumpAndSettle();

        // Verify custom preview card appears
        expect(find.byKey(const Key('custom_photo_preview')), findsOneWidget);
        expect(
          find.textContaining('my_neighborhood_pothole.png'),
          findsOneWidget,
        );
        expect(find.textContaining('Custom Upload (1.2 KB)'), findsOneWidget);

        // Tap remove custom photo button
        await tester.tap(find.byKey(const Key('remove_custom_photo_button')));
        await tester.pumpAndSettle();

        // Verify preview is removed
        expect(find.byKey(const Key('custom_photo_preview')), findsNothing);
      },
    );

    testWidgets('mutual exclusion between sample photo and custom photo', (
      tester,
    ) async {
      final mockBytes = PhotoUtils.samplePhotos[1].bytes;
      CustomImagePicker.pickCustomImageOverride = () async {
        return PickedFileData(fileName: 'custom_lamp.jpg', bytes: mockBytes);
      };

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
      );
      await tester.pumpAndSettle();

      // 1. First pick a custom photo
      await tester.ensureVisible(find.byKey(const Key('upload_photo_button')));
      await tester.tap(find.byKey(const Key('upload_photo_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_photo_preview')), findsOneWidget);
      expect(find.byKey(const Key('sample_photo_preview')), findsNothing);

      // 2. Now tap a sample photo chip (Pothole on Main St)
      await tester.ensureVisible(find.text('Pothole on Main St'));
      await tester.tap(find.text('Pothole on Main St'));
      await tester.pumpAndSettle();

      // Custom photo must be deselected, and sample photo preview must appear
      expect(find.byKey(const Key('custom_photo_preview')), findsNothing);
      expect(find.byKey(const Key('sample_photo_preview')), findsOneWidget);

      // 3. Now pick custom photo again
      await tester.ensureVisible(find.byKey(const Key('upload_photo_button')));
      await tester.tap(find.byKey(const Key('upload_photo_button')));
      await tester.pumpAndSettle();

      // Sample photo must be deselected, and custom photo preview must appear
      expect(find.byKey(const Key('sample_photo_preview')), findsNothing);
      expect(find.byKey(const Key('custom_photo_preview')), findsOneWidget);
    });

    testWidgets('validation rejects unsupported file extension', (
      tester,
    ) async {
      CustomImagePicker.pickCustomImageOverride = () async {
        return PickedFileData(
          fileName: 'report_document.pdf',
          bytes: Uint8List(100),
        );
      };

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('upload_photo_button')));
      await tester.tap(find.byKey(const Key('upload_photo_button')));
      await tester.pumpAndSettle();

      // Custom photo preview should NOT appear
      expect(find.byKey(const Key('custom_photo_preview')), findsNothing);
      // Validation error message should be displayed in the banner and SnackBar
      expect(
        find.descendant(
          of: find.byKey(const Key('photo_validation_error')),
          matching: find.textContaining('Invalid photo format ".pdf"'),
        ),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('validation rejects files exceeding 5 MB limit', (
      tester,
    ) async {
      final oversizedBytes = Uint8List(5 * 1024 * 1024 + 1024); // 5.001 MB
      CustomImagePicker.pickCustomImageOverride = () async {
        return PickedFileData(
          fileName: 'large_image.png',
          bytes: oversizedBytes,
        );
      };

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('upload_photo_button')));
      await tester.tap(find.byKey(const Key('upload_photo_button')));
      await tester.pumpAndSettle();

      // Custom photo preview should NOT appear
      expect(find.byKey(const Key('custom_photo_preview')), findsNothing);
      // Validation error message should be displayed in the banner and SnackBar
      expect(
        find.descendant(
          of: find.byKey(const Key('photo_validation_error')),
          matching: find.textContaining(
            'exceeds maximum allowed limit of 5 MB',
          ),
        ),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('submitting issue without a photo succeeds normally', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
      );
      await tester.pumpAndSettle();

      // Enter description and title
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Broken park bench near the playground',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Damaged Park Bench',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text('Submit Civic Issue Report'));
      await tester.tap(find.text('Submit Civic Issue Report'));
      await tester.pumpAndSettle();

      // Verify createIssue was called
      expect(fakeEndpointIssue.lastCreatedIssue, isNotNull);
      expect(
        fakeEndpointIssue.lastCreatedIssue!.title,
        equals('Damaged Park Bench'),
      );
      // Verify attachIssuePhoto was NOT called
      expect(fakeEndpointIssue.lastPhotoIssueId, isNull);

      // Verify success dialog reports submission without a photo
      expect(find.text('Issue Submitted!'), findsOneWidget);
      expect(find.text('Report submitted without a photo.'), findsOneWidget);
    });

    testWidgets(
      'submitting issue with custom photo attaches photo to created issue',
      (tester) async {
        final mockBytes = PhotoUtils.samplePhotos[2].bytes;
        CustomImagePicker.pickCustomImageOverride = () async {
          return PickedFileData(
            fileName: 'custom_water_leak.png',
            bytes: mockBytes,
          );
        };

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
        );
        await tester.pumpAndSettle();

        // Enter description and title
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Water leaking heavily from main line onto sidewalk',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'Water Leak');

        // Pick custom photo
        await tester.ensureVisible(
          find.byKey(const Key('upload_photo_button')),
        );
        await tester.tap(find.byKey(const Key('upload_photo_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('custom_photo_preview')), findsOneWidget);

        // Submit
        await tester.ensureVisible(find.text('Submit Civic Issue Report'));
        await tester.tap(find.text('Submit Civic Issue Report'));
        await tester.pumpAndSettle();

        // Verify issue was created first with ID 42
        expect(fakeEndpointIssue.lastCreatedIssue, isNotNull);
        // Verify photo was attached to issue ID 42 with correct bytes and filename
        expect(fakeEndpointIssue.lastPhotoIssueId, equals(42));
        expect(
          fakeEndpointIssue.lastPhotoFileName,
          equals('custom_water_leak.png'),
        );
        expect(
          fakeEndpointIssue.lastPhotoImageBytes!.lengthInBytes,
          equals(mockBytes.lengthInBytes),
        );
        expect(
          fakeEndpointIssue.lastUploadToken,
          equals('mock_token_for_issue_42'),
        );

        // Verify success dialog confirms photo upload
        expect(find.text('Issue Submitted!'), findsOneWidget);
        expect(
          find.text('Photo attachment successfully uploaded and linked.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'submitting issue when photo attachment fails warns user without false success',
      (tester) async {
        final mockBytes = PhotoUtils.samplePhotos[3].bytes;
        CustomImagePicker.pickCustomImageOverride = () async {
          return PickedFileData(
            fileName: 'graffiti_wall.png',
            bytes: mockBytes,
          );
        };
        fakeEndpointIssue.shouldFailPhotoUpload = true;

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: CreateIssueScreen())),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Graffiti on library wall',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Library Wall Graffiti',
        );

        await tester.ensureVisible(
          find.byKey(const Key('upload_photo_button')),
        );
        await tester.tap(find.byKey(const Key('upload_photo_button')));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Submit Civic Issue Report'));
        await tester.tap(find.text('Submit Civic Issue Report'));
        await tester.pumpAndSettle();

        // Verify issue was created
        expect(fakeEndpointIssue.lastCreatedIssue, isNotNull);

        // Verify dialog shows warning and failure details, NOT false success
        expect(find.text('Issue Created (Photo Warning)'), findsOneWidget);
        expect(
          find.textContaining('photo upload failed:'),
          findsOneWidget,
        );
        expect(
          find.text('Photo attachment successfully uploaded and linked.'),
          findsNothing,
        );
      },
    );
  });

  group('Role-Based Dashboards Tests', () {
    testWidgets('AdminDashboardScreen renders command center and metrics', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AdminDashboardScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Municipal Command Center'), findsOneWidget);
      expect(find.text('Case Operations'), findsOneWidget);
      expect(find.text('Staff & Workloads'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('EmployeeDashboardScreen renders field worker task board', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmployeeDashboardScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Field Worker Task Board'), findsOneWidget);
      expect(find.text('All Tasks'), findsOneWidget);
      expect(find.text('ASSIGNED'), findsOneWidget);
      expect(find.text('IN_PROGRESS'), findsOneWidget);
      expect(find.text('RESOLVED'), findsOneWidget);
    });
  });
}
