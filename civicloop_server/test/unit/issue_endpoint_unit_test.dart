import 'dart:typed_data';

import 'package:civicloop_server/src/generated/protocol.dart';
import 'package:civicloop_server/src/issues/issue_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

class FakeSession implements Session {
  @override
  final AuthenticationInfo? authenticated;

  FakeSession({this.authenticated});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('IssueEndpoint Validation Tests', () {
    final endpoint = IssueEndpoint();
    final fakeSession = FakeSession();
    final officialSession = FakeSession(
      authenticated: AuthenticationInfo(
        'official_user',
        {const Scope('official')},
        authId: 'test-auth-id',
      ),
    );
    final citizenSession = FakeSession(
      authenticated: AuthenticationInfo(
        'citizen_123',
        {},
        authId: 'test-auth-id',
      ),
    );

    test('getIssueById returns null for zero or negative id', () async {
      final resultZero = await endpoint.getIssueById(
        fakeSession,
        0,
      );
      expect(resultZero, isNull);

      final resultNegative = await endpoint.getIssueById(
        fakeSession,
        -5,
      );
      expect(resultNegative, isNull);
    });

    test(
      'createIssue throws ArgumentError when title is empty or only whitespace',
      () {
        final issue = Issue(
          title: '   ',
          description: 'Pothole on Main St',
          category: 'Roads',
          status: 'open',
          createdAt: DateTime.now(),
        );

        expect(
          () => endpoint.createIssue(fakeSession, issue),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Title cannot be empty.',
            ),
          ),
        );
      },
    );

    test('createIssue throws ArgumentError when description is empty', () {
      final issue = Issue(
        title: 'Broken lamp',
        description: '  ',
        category: 'Lighting',
        status: 'open',
        createdAt: DateTime.now(),
      );

      expect(
        () => endpoint.createIssue(fakeSession, issue),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Description cannot be empty.',
          ),
        ),
      );
    });

    test('createIssue throws ArgumentError when category is empty', () {
      final issue = Issue(
        title: 'Broken lamp',
        description: 'Dark area at night',
        category: '',
        status: 'open',
        createdAt: DateTime.now(),
      );

      expect(
        () => endpoint.createIssue(fakeSession, issue),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Category cannot be empty.',
          ),
        ),
      );
    });

    test('createIssue throws ArgumentError for invalid latitude', () {
      final issue = Issue(
        title: 'Broken lamp',
        description: 'Dark area at night',
        category: 'Lighting',
        status: 'open',
        createdAt: DateTime.now(),
        latitude: 95.0,
      );

      expect(
        () => endpoint.createIssue(fakeSession, issue),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Latitude must be between -90 and 90.',
          ),
        ),
      );
    });

    test('createIssue throws ArgumentError for invalid longitude', () {
      final issue = Issue(
        title: 'Broken lamp',
        description: 'Dark area at night',
        category: 'Lighting',
        status: 'open',
        createdAt: DateTime.now(),
        longitude: -190.0,
      );

      expect(
        () => endpoint.createIssue(fakeSession, issue),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Longitude must be between -180 and 180.',
          ),
        ),
      );
    });

    test(
      'updateIssueStatus throws NotAuthorizedException when session is unauthenticated',
      () {
        expect(
          () => endpoint.updateIssueStatus(fakeSession, 1, 'open'),
          throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.reason,
              'reason',
              equals(AuthenticationFailureReason.unauthenticated),
            ),
          ),
        );
      },
    );

    test(
      'updateIssueStatus throws NotAuthorizedException when session is an ordinary citizen',
      () {
        expect(
          () => endpoint.updateIssueStatus(citizenSession, 1, 'open'),
          throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.reason,
              'reason',
              equals(AuthenticationFailureReason.insufficientAccess),
            ),
          ),
        );
      },
    );

    test(
      'updateIssueStatus throws ArgumentError for zero or negative id with official session',
      () {
        expect(
          () => endpoint.updateIssueStatus(officialSession, 0, 'open'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Issue ID must be a positive integer.',
            ),
          ),
        );

        expect(
          () => endpoint.updateIssueStatus(officialSession, -1, 'open'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Issue ID must be a positive integer.',
            ),
          ),
        );
      },
    );

    test(
      'updateIssueStatus throws ArgumentError for invalid status values with official session',
      () {
        for (final invalidStatus in [
          '',
          '   ',
          'invalid',
          'OPEN',
          'In_Progress',
          'deleted',
          'pending',
        ]) {
          expect(
            () => endpoint.updateIssueStatus(officialSession, 1, invalidStatus),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Invalid status'),
              ),
            ),
          );
        }
      },
    );

    test(
      'isOfficialOrAdmin identifies official and admin sessions correctly',
      () {
        expect(IssueEndpoint.isOfficialOrAdmin(fakeSession), isFalse);
        expect(IssueEndpoint.isOfficialOrAdmin(citizenSession), isFalse);

        final adminScopeSession = FakeSession(
          authenticated: AuthenticationInfo(
            'any_admin',
            {Scope.admin},
            authId: 'test-auth-id',
          ),
        );
        expect(IssueEndpoint.isOfficialOrAdmin(adminScopeSession), isTrue);

        final officialScopeSession = FakeSession(
          authenticated: AuthenticationInfo(
            'any_official',
            {const Scope('official')},
            authId: 'test-auth-id',
          ),
        );
        expect(IssueEndpoint.isOfficialOrAdmin(officialScopeSession), isTrue);

        final officialEmailSession = FakeSession(
          authenticated: AuthenticationInfo(
            'clerk@official.civicloop',
            {},
            authId: 'test-auth-id',
          ),
        );
        expect(IssueEndpoint.isOfficialOrAdmin(officialEmailSession), isTrue);

        final officialNamedSession = FakeSession(
          authenticated: AuthenticationInfo(
            'official',
            {},
            authId: 'test-auth-id',
          ),
        );
        expect(IssueEndpoint.isOfficialOrAdmin(officialNamedSession), isTrue);
      },
    );

    test(
      'redactIssuePrivacy redacts userId for public or other citizens but preserves for owner and official',
      () {
        final sampleIssue = Issue(
          id: 42,
          title: 'Noise complaint',
          description: 'Loud music late at night',
          category: 'Noise',
          status: 'open',
          createdAt: DateTime.now(),
          userId: 'citizen_123',
        );

        // Unauthenticated caller: userId redacted to null
        final redactedPublic = IssueEndpoint.redactIssuePrivacy(
          fakeSession,
          sampleIssue,
        );
        expect(redactedPublic.userId, isNull);
        expect(redactedPublic.title, equals('Noise complaint'));

        // Another citizen caller: userId redacted to null
        final otherCitizenSession = FakeSession(
          authenticated: AuthenticationInfo(
            'citizen_456',
            {},
            authId: 'test-auth-id',
          ),
        );
        final redactedOtherCitizen = IssueEndpoint.redactIssuePrivacy(
          otherCitizenSession,
          sampleIssue,
        );
        expect(redactedOtherCitizen.userId, isNull);

        // Owner citizen caller: userId preserved
        final ownerSession = FakeSession(
          authenticated: AuthenticationInfo(
            'citizen_123',
            {},
            authId: 'test-auth-id',
          ),
        );
        final preservedOwner = IssueEndpoint.redactIssuePrivacy(
          ownerSession,
          sampleIssue,
        );
        expect(preservedOwner.userId, equals('citizen_123'));

        // Official caller: userId preserved
        final preservedOfficial = IssueEndpoint.redactIssuePrivacy(
          officialSession,
          sampleIssue,
        );
        expect(preservedOfficial.userId, equals('citizen_123'));

        // Anonymous issue (already null userId)
        final anonIssue = sampleIssue.copyWith(userId: null);
        final anonViewed = IssueEndpoint.redactIssuePrivacy(
          fakeSession,
          anonIssue,
        );
        expect(anonViewed.userId, isNull);
      },
    );

    test('IssueEndpoint.validStatuses contains only the required statuses', () {
      expect(
        IssueEndpoint.validStatuses,
        equals({'open', 'in_progress', 'resolved', 'closed'}),
      );
    });

    test(
      'getMyIssues throws NotAuthorizedException when session is unauthenticated',
      () async {
        final unauthenticatedSession = FakeSession();
        expect(
          () => endpoint.getMyIssues(unauthenticatedSession),
          throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.reason,
              'reason',
              equals(AuthenticationFailureReason.unauthenticated),
            ),
          ),
        );
      },
    );

    test(
      'getMyIssues throws NotAuthorizedException when userIdentifier is whitespace',
      () async {
        final emptyUserSession = FakeSession(
          authenticated: AuthenticationInfo('   ', {}, authId: 'test-auth-id'),
        );
        expect(
          () => endpoint.getMyIssues(emptyUserSession),
          throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.reason,
              'reason',
              equals(AuthenticationFailureReason.unauthenticated),
            ),
          ),
        );
      },
    );

    test('validateAndExtractExtension accepts valid image extensions', () {
      expect(
        IssueEndpoint.validateAndExtractExtension('pothole.jpg'),
        equals('jpg'),
      );
      expect(
        IssueEndpoint.validateAndExtractExtension('PHOTO.JPEG'),
        equals('jpeg'),
      );
      expect(
        IssueEndpoint.validateAndExtractExtension('street.png'),
        equals('png'),
      );
      expect(
        IssueEndpoint.validateAndExtractExtension('sign.webp'),
        equals('webp'),
      );
    });

    test('validateAndExtractExtension rejects invalid extensions or names', () {
      for (final invalid in [
        '',
        '   ',
        'file',
        'file.',
        'file.exe',
        'file.pdf',
        'file.html',
        'file.sh',
      ]) {
        expect(
          () => IssueEndpoint.validateAndExtractExtension(invalid),
          throwsA(isA<ArgumentError>()),
        );
      }
    });

    test('validatePhotoBytes enforces non-empty and 5MB size limit', () {
      // Empty byte data
      expect(
        () => IssueEndpoint.validatePhotoBytes(ByteData(0)),
        throwsA(isA<ArgumentError>()),
      );

      // Exceeds 5MB (5 * 1024 * 1024 + 1)
      expect(
        () => IssueEndpoint.validatePhotoBytes(
          ByteData(IssueEndpoint.maxPhotoBytes + 1),
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Valid byte data
      expect(
        () => IssueEndpoint.validatePhotoBytes(ByteData(1024)),
        returnsNormally,
      );
    });

    test('attachIssuePhoto throws ArgumentError for non-positive issueId', () {
      expect(
        () => endpoint.attachIssuePhoto(
          fakeSession,
          0,
          'photo.jpg',
          ByteData(100),
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => endpoint.attachIssuePhoto(
          fakeSession,
          -5,
          'photo.jpg',
          ByteData(100),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'getPhotoUploadDescription throws ArgumentError for non-positive issueId',
      () {
        expect(
          () => endpoint.getPhotoUploadDescription(
            fakeSession,
            0,
            'photo.jpg',
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'verifyAndAttachPhoto throws ArgumentError for empty path or non-positive id',
      () {
        expect(
          () => endpoint.verifyAndAttachPhoto(
            fakeSession,
            0,
            'issues/1/photo.jpg',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => endpoint.verifyAndAttachPhoto(
            fakeSession,
            1,
            '   ',
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'getIssuePhotoUrl and getIssuePhoto return null for non-positive issueId',
      () async {
        expect(await endpoint.getIssuePhotoUrl(fakeSession, 0), isNull);
        expect(await endpoint.getIssuePhotoUrl(fakeSession, -1), isNull);
        expect(await endpoint.getIssuePhoto(fakeSession, 0), isNull);
        expect(await endpoint.getIssuePhoto(fakeSession, -1), isNull);
      },
    );
  });
}
