import 'dart:typed_data';

import 'package:civicloop_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Issue endpoint', (sessionBuilder, endpoints) {
    test(
      'when calling createIssue then issue is created with open status, server timestamp, and generated id',
      () async {
        final issueToCreate = Issue(
          title: 'Broken streetlight',
          description: 'Streetlight on 5th Ave is flickering',
          category: 'Lighting',
          status: 'ignored_status',
          createdAt: DateTime(2000, 1, 1),
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final created = await endpoints.issue.createIssue(
          sessionBuilder,
          issueToCreate,
        );

        expect(created.id, isNotNull);
        expect(created.title, equals('Broken streetlight'));
        expect(
          created.description,
          equals('Streetlight on 5th Ave is flickering'),
        );
        expect(created.category, equals('Lighting'));
        expect(created.status, equals('open'));
        expect(created.createdAt.year, greaterThanOrEqualTo(2026));
        expect(created.latitude, equals(37.7749));
        expect(created.longitude, equals(-122.4194));
      },
    );

    test(
      'when calling createIssue with empty title then throws ArgumentError',
      () async {
        final invalidIssue = Issue(
          title: '   ',
          description: 'Valid description',
          category: 'Roads',
          status: 'open',
          createdAt: DateTime.now(),
        );

        expect(
          () => endpoints.issue.createIssue(sessionBuilder, invalidIssue),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'when calling createIssue with empty description then throws ArgumentError',
      () async {
        final invalidIssue = Issue(
          title: 'Valid title',
          description: '',
          category: 'Roads',
          status: 'open',
          createdAt: DateTime.now(),
        );

        expect(
          () => endpoints.issue.createIssue(sessionBuilder, invalidIssue),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('when calling getIssues then returns issues newest first', () async {
      final issue1 = Issue(
        title: 'Issue 1',
        description: 'First issue created',
        category: 'Roads',
        status: 'open',
        createdAt: DateTime.now(),
      );
      final issue2 = Issue(
        title: 'Issue 2',
        description: 'Second issue created',
        category: 'Parks',
        status: 'open',
        createdAt: DateTime.now(),
      );

      final created1 = await endpoints.issue.createIssue(
        sessionBuilder,
        issue1,
      );
      // Small pause to guarantee timestamp distinction
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final created2 = await endpoints.issue.createIssue(
        sessionBuilder,
        issue2,
      );

      final issues = await endpoints.issue.getIssues(sessionBuilder);

      expect(issues, isNotEmpty);
      final ids = issues.map((i) => i.id).toList();
      final idx1 = ids.indexOf(created1.id);
      final idx2 = ids.indexOf(created2.id);
      expect(
        idx2,
        lessThan(idx1),
      ); // idx2 was created later, so appears earlier (newest first)
    });

    test(
      'when calling getIssueById with existing id then returns issue',
      () async {
        final issue = Issue(
          title: 'Water leak',
          description: 'Water pipe leaking near park',
          category: 'Water',
          status: 'open',
          createdAt: DateTime.now(),
        );

        final created = await endpoints.issue.createIssue(
          sessionBuilder,
          issue,
        );
        final fetched = await endpoints.issue.getIssueById(
          sessionBuilder,
          created.id!,
        );

        expect(fetched, isNotNull);
        expect(fetched!.id, equals(created.id));
        expect(fetched.title, equals('Water leak'));
      },
    );

    test(
      'when calling getIssueById with non-existent id then returns null',
      () async {
        final fetched = await endpoints.issue.getIssueById(
          sessionBuilder,
          999999,
        );
        expect(fetched, isNull);
      },
    );

    test(
      'when calling updateIssueStatus without authentication then throws ServerpodUnauthenticatedException',
      () async {
        expect(
          () => endpoints.issue.updateIssueStatus(
            sessionBuilder,
            1,
            'resolved',
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      },
    );

    test(
      'when calling updateIssueStatus as ordinary citizen then throws ServerpodInsufficientAccessException',
      () async {
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-reporter',
            {},
          ),
        );

        expect(
          () => endpoints.issue.updateIssueStatus(
            citizenSession,
            1,
            'resolved',
          ),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      },
    );

    test(
      'when calling updateIssueStatus with valid statuses as official then issue is updated and persisted',
      () async {
        final officialSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'official@official.civicloop',
            {const Scope('official')},
          ),
        );

        final issue = Issue(
          title: 'Damaged sidewalk',
          description: 'Sidewalk cracked on Elm Street',
          category: 'Infrastructure',
          status: 'open',
          createdAt: DateTime.now(),
        );

        final created = await endpoints.issue.createIssue(
          sessionBuilder,
          issue,
        );
        expect(created.status, equals('open'));

        // Transition through all allowed statuses: in_progress -> resolved -> closed -> open
        final updatedToInProgress = await endpoints.issue.updateIssueStatus(
          officialSession,
          created.id!,
          'in_progress',
        );
        expect(updatedToInProgress, isNotNull);
        expect(updatedToInProgress!.status, equals('in_progress'));

        final updatedToResolved = await endpoints.issue.updateIssueStatus(
          officialSession,
          created.id!,
          'resolved',
        );
        expect(updatedToResolved, isNotNull);
        expect(updatedToResolved!.status, equals('resolved'));

        final updatedToClosed = await endpoints.issue.updateIssueStatus(
          officialSession,
          created.id!,
          'closed',
        );
        expect(updatedToClosed, isNotNull);
        expect(updatedToClosed!.status, equals('closed'));

        final updatedToOpen = await endpoints.issue.updateIssueStatus(
          officialSession,
          created.id!,
          'open',
        );
        expect(updatedToOpen, isNotNull);
        expect(updatedToOpen!.status, equals('open'));

        // Verify persistence by fetching directly from DB
        final fetched = await endpoints.issue.getIssueById(
          officialSession,
          created.id!,
        );
        expect(fetched, isNotNull);
        expect(fetched!.status, equals('open'));
      },
    );

    test(
      'when calling updateIssueStatus with non-existent id as official then returns null',
      () async {
        final officialSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'official@official.civicloop',
            {const Scope('official')},
          ),
        );

        final result = await endpoints.issue.updateIssueStatus(
          officialSession,
          999999,
          'resolved',
        );
        expect(result, isNull);
      },
    );

    test(
      'when calling updateIssueStatus with invalid status as official then throws ArgumentError',
      () async {
        final officialSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'official@official.civicloop',
            {const Scope('official')},
          ),
        );

        final issue = Issue(
          title: 'Test issue',
          description: 'Description',
          category: 'Roads',
          status: 'open',
          createdAt: DateTime.now(),
        );
        final created = await endpoints.issue.createIssue(
          sessionBuilder,
          issue,
        );

        expect(
          () => endpoints.issue.updateIssueStatus(
            officialSession,
            created.id!,
            'rejected',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => endpoints.issue.updateIssueStatus(
            officialSession,
            created.id!,
            'INVALID',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => endpoints.issue.updateIssueStatus(
            officialSession,
            created.id!,
            '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'when calling updateIssueStatus with non-positive id as official then throws ArgumentError',
      () async {
        final officialSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'official@official.civicloop',
            {const Scope('official')},
          ),
        );

        expect(
          () => endpoints.issue.updateIssueStatus(
            officialSession,
            0,
            'resolved',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => endpoints.issue.updateIssueStatus(
            officialSession,
            -10,
            'resolved',
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'when calling createIssue as authenticated user then server sets userId and ignores client-provided value',
      () async {
        final userSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'test-user-alpha',
            {},
          ),
        );

        final issueToCreate = Issue(
          title: 'Damaged bench',
          description: 'Park bench broken in central park',
          category: 'Parks',
          status: 'open',
          createdAt: DateTime.now(),
          userId: 'spoofed-user-id',
        );

        final created = await endpoints.issue.createIssue(
          userSession,
          issueToCreate,
        );

        expect(created.id, isNotNull);
        expect(created.userId, equals('test-user-alpha'));

        // Verify database persistence of userId via owner session
        final fetchedByOwner = await endpoints.issue.getIssueById(
          userSession,
          created.id!,
        );
        expect(fetchedByOwner, isNotNull);
        expect(fetchedByOwner!.userId, equals('test-user-alpha'));

        // Verify public/unauthenticated view redacts citizen reporter userId
        final fetchedPublic = await endpoints.issue.getIssueById(
          sessionBuilder,
          created.id!,
        );
        expect(fetchedPublic, isNotNull);
        expect(fetchedPublic!.userId, isNull);
      },
    );

    test(
      'when calling createIssue as unauthenticated user then issue is created with null userId (anonymous)',
      () async {
        final issueToCreate = Issue(
          title: 'Anonymous report',
          description: 'Graffiti on retaining wall',
          category: 'Vandalism',
          status: 'open',
          createdAt: DateTime.now(),
          userId: 'attempted-user-id',
        );

        final created = await endpoints.issue.createIssue(
          sessionBuilder,
          issueToCreate,
        );

        expect(created.id, isNotNull);
        expect(created.userId, isNull);

        final fetched = await endpoints.issue.getIssueById(
          sessionBuilder,
          created.id!,
        );
        expect(fetched, isNotNull);
        expect(fetched!.userId, isNull);
      },
    );

    test(
      'when calling createIssue as municipal administrator then throws NotAuthorizedException',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@civicloop.com',
            {const Scope('admin')},
          ),
        );

        final issueToCreate = Issue(
          title: 'Admin civic report attempt',
          description: 'Trying to report as administrator',
          category: 'Roads',
          status: 'open',
          createdAt: DateTime.now(),
        );

        await expectLater(
          () => endpoints.issue.createIssue(adminSession, issueToCreate),
          throwsA(
            anyOf(
              isA<ServerpodInsufficientAccessException>(),
              isA<NotAuthorizedException>(),
            ),
          ),
        );
      },
    );

    test(
      'when calling createIssue as employee/worker then throws NotAuthorizedException',
      () async {
        final empSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'emp-create-restricted',
            {},
          ),
        );

        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@civicloop.com',
            {const Scope('admin')},
          ),
        );
        await endpoints.issue.provisionStaff(
          adminSession,
          'emp-create-restricted',
          'employee',
        );

        final issueToCreate = Issue(
          title: 'Worker civic report attempt',
          description: 'Trying to report as field worker',
          category: 'Sanitation',
          status: 'open',
          createdAt: DateTime.now(),
        );

        await expectLater(
          () => endpoints.issue.createIssue(empSession, issueToCreate),
          throwsA(
            anyOf(
              isA<ServerpodInsufficientAccessException>(),
              isA<NotAuthorizedException>(),
            ),
          ),
        );
      },
    );

    test(
      'when calling getMyIssues then returns only authenticated user issues and enforces isolation between users',
      () async {
        final userASession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'user-A',
            {},
          ),
        );
        final userBSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'user-B',
            {},
          ),
        );

        // Create issue for User A
        final issueA = await endpoints.issue.createIssue(
          userASession,
          Issue(
            title: 'User A Issue',
            description: 'Created by User A',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // Create issue for User B
        final issueB = await endpoints.issue.createIssue(
          userBSession,
          Issue(
            title: 'User B Issue',
            description: 'Created by User B',
            category: 'Lighting',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // Create anonymous issue
        final anonymousIssue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Anonymous Issue',
            description: 'Created anonymously',
            category: 'Parks',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // Query for User A
        final userAIssues = await endpoints.issue.getMyIssues(userASession);
        final userAIssueIds = userAIssues.map((i) => i.id).toList();

        expect(userAIssueIds, contains(issueA.id));
        expect(userAIssueIds, isNot(contains(issueB.id)));
        expect(userAIssueIds, isNot(contains(anonymousIssue.id)));
        expect(userAIssues.every((i) => i.userId == 'user-A'), isTrue);

        // Query for User B
        final userBIssues = await endpoints.issue.getMyIssues(userBSession);
        final userBIssueIds = userBIssues.map((i) => i.id).toList();

        expect(userBIssueIds, contains(issueB.id));
        expect(userBIssueIds, isNot(contains(issueA.id)));
        expect(userBIssueIds, isNot(contains(anonymousIssue.id)));
        expect(userBIssues.every((i) => i.userId == 'user-B'), isTrue);
      },
    );

    test(
      'when calling getMyIssues without authentication then throws ServerpodUnauthenticatedException',
      () async {
        expect(
          () => endpoints.issue.getMyIssues(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );

        final unauthenticatedOverrideSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );
        expect(
          () => endpoints.issue.getMyIssues(unauthenticatedOverrideSession),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      },
    );

    test(
      'when attaching photo to issue as owner then photo is persisted in cloud storage and issue updated',
      () async {
        final userSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'photo-owner',
            {},
          ),
        );

        final issue = await endpoints.issue.createIssue(
          userSession,
          Issue(
            title: 'Pothole with photo',
            description: 'Pothole on 4th street',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );
        expect(issue.photoPath, isNull);

        // Prepare sample photo bytes
        final sampleBytes = Uint8List.fromList([
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
          1,
          2,
          3,
          4,
        ]).buffer.asByteData();

        final updated = await endpoints.issue.attachIssuePhoto(
          userSession,
          issue.id!,
          'pothole.png',
          sampleBytes,
        );

        expect(updated.photoPath, equals('issues/${issue.id}/photo.png'));

        // Verify database persistence of photoPath
        final fetched = await endpoints.issue.getIssueById(
          sessionBuilder,
          issue.id!,
        );
        expect(fetched, isNotNull);
        expect(fetched!.photoPath, equals('issues/${issue.id}/photo.png'));

        // Verify retrieval of binary photo data from cloud storage
        final photoBytes = await endpoints.issue.getIssuePhoto(
          sessionBuilder,
          issue.id!,
        );
        expect(photoBytes, isNotNull);
        expect(photoBytes!.lengthInBytes, equals(sampleBytes.lengthInBytes));

        // Verify retrieval of public photo URL
        final photoUrl = await endpoints.issue.getIssuePhotoUrl(
          sessionBuilder,
          issue.id!,
        );
        expect(photoUrl, isNotNull);
        expect(
          Uri.decodeFull(photoUrl!),
          contains('issues/${issue.id}/photo.png'),
        );
      },
    );

    test(
      'when non-owner tries to attach photo then throws ServerpodInsufficientAccessException',
      () async {
        final ownerSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'real-owner',
            {},
          ),
        );
        final intruderSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'intruder',
            {},
          ),
        );

        final issue = await endpoints.issue.createIssue(
          ownerSession,
          Issue(
            title: 'Owner issue',
            description: 'Issue description',
            category: 'Lighting',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final sampleBytes = Uint8List.fromList([
          1,
          2,
          3,
          4,
        ]).buffer.asByteData();

        expect(
          () => endpoints.issue.attachIssuePhoto(
            intruderSession,
            issue.id!,
            'photo.jpg',
            sampleBytes,
          ),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      },
    );

    test(
      'when unauthenticated caller tries to attach photo to attributed issue then throws ServerpodUnauthenticatedException',
      () async {
        final ownerSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'owner-user',
            {},
          ),
        );

        final issue = await endpoints.issue.createIssue(
          ownerSession,
          Issue(
            title: 'Owner issue',
            description: 'Issue description',
            category: 'Lighting',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final sampleBytes = Uint8List.fromList([
          1,
          2,
          3,
          4,
        ]).buffer.asByteData();

        expect(
          () => endpoints.issue.attachIssuePhoto(
            sessionBuilder,
            issue.id!,
            'photo.jpg',
            sampleBytes,
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      },
    );

    test(
      'when caller tries to attach photo post-creation to anonymous issue then throws ServerpodInsufficientAccessException',
      () async {
        final anonIssue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Anonymous report',
            description: 'No owner',
            category: 'Parks',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final userSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'some-user',
            {},
          ),
        );

        final sampleBytes = Uint8List.fromList([
          1,
          2,
          3,
          4,
        ]).buffer.asByteData();

        expect(
          () => endpoints.issue.attachIssuePhoto(
            userSession,
            anonIssue.id!,
            'photo.jpg',
            sampleBytes,
          ),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      },
    );

    test(
      'when creating anonymous issue then returns valid non-null uploadToken',
      () async {
        final anonIssue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Anonymous pothole',
            description: 'Huge pothole on Oak Street',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        expect(anonIssue.id, isNotNull);
        expect(anonIssue.userId, isNull);
        expect(anonIssue.uploadToken, isNotNull);
        expect(anonIssue.uploadToken, isNotEmpty);
      },
    );

    test(
      'when attaching photo to anonymous issue with valid uploadToken then photo is persisted and linked',
      () async {
        final anonIssue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Anonymous graffiti',
            description: 'Graffiti under overpass',
            category: 'Vandalism',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        expect(anonIssue.uploadToken, isNotNull);

        final sampleBytes = Uint8List.fromList([
          137,
          80,
          78,
          71,
          13,
          10,
          26,
          10,
          10,
          20,
          30,
          40,
        ]).buffer.asByteData();

        final updated = await endpoints.issue.attachIssuePhoto(
          sessionBuilder,
          anonIssue.id!,
          'graffiti.png',
          sampleBytes,
          uploadToken: anonIssue.uploadToken,
        );

        expect(updated.photoPath, equals('issues/${anonIssue.id}/photo.png'));

        // Verify retrieval of the photo
        final fetched = await endpoints.issue.getIssueById(
          sessionBuilder,
          anonIssue.id!,
        );
        expect(fetched?.photoPath, equals('issues/${anonIssue.id}/photo.png'));

        final retrievedBytes = await endpoints.issue.getIssuePhoto(
          sessionBuilder,
          anonIssue.id!,
        );
        expect(retrievedBytes, isNotNull);
        expect(
          retrievedBytes!.lengthInBytes,
          equals(sampleBytes.lengthInBytes),
        );
      },
    );

    test(
      'when attaching photo to anonymous issue with invalid or forged uploadToken then throws ServerpodInsufficientAccessException',
      () async {
        final anonIssue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Anonymous trash',
            description: 'Illegal dumping in alley',
            category: 'Sanitation',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final sampleBytes = Uint8List.fromList([
          1,
          2,
          3,
          4,
        ]).buffer.asByteData();

        // Forged / invalid token
        await expectLater(
          endpoints.issue.attachIssuePhoto(
            sessionBuilder,
            anonIssue.id!,
            'trash.jpg',
            sampleBytes,
            uploadToken: 'invalid_token_12345',
          ),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );

        // Token from another issue
        final otherIssue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Other issue',
            description: 'Other description',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        await expectLater(
          endpoints.issue.attachIssuePhoto(
            sessionBuilder,
            anonIssue.id!,
            'trash.jpg',
            sampleBytes,
            uploadToken: otherIssue.uploadToken,
          ),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      },
    );

    test(
      'when calling getPhotoUploadDescription as owner then valid upload description is returned',
      () async {
        final ownerSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'desc-owner',
            {},
          ),
        );

        final issue = await endpoints.issue.createIssue(
          ownerSession,
          Issue(
            title: 'Issue for direct upload',
            description: 'Description',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final description = await endpoints.issue.getPhotoUploadDescription(
          ownerSession,
          issue.id!,
          'evidence.webp',
        );

        expect(description, isNotEmpty);
        expect(
          Uri.decodeFull(description),
          contains('issues/${issue.id}/photo.webp'),
        );
      },
    );

    test(
      'when calling getIssuePhotoUrl or getIssuePhoto for issue with no photo then returns null',
      () async {
        final issue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Issue without photo',
            description: 'No photo attached',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final url = await endpoints.issue.getIssuePhotoUrl(
          sessionBuilder,
          issue.id!,
        );
        expect(url, isNull);

        final photo = await endpoints.issue.getIssuePhoto(
          sessionBuilder,
          issue.id!,
        );
        expect(photo, isNull);
      },
    );

    test(
      'when calling getIssues and getIssueById then citizen reporter userId is redacted for public and other citizens, but visible to owner and official',
      () async {
        final userASession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'reporter-alice',
            {},
          ),
        );
        final userBSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'reporter-bob',
            {},
          ),
        );
        final officialSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'inspector-dan@official.civicloop',
            {const Scope('official')},
          ),
        );

        final issueA = await endpoints.issue.createIssue(
          userASession,
          Issue(
            title: 'Alice Issue',
            description: 'Reported by Alice',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        final issueB = await endpoints.issue.createIssue(
          userBSession,
          Issue(
            title: 'Bob Issue',
            description: 'Reported by Bob',
            category: 'Parks',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // 1. Public unauthenticated caller: both issues have null userId
        final publicList = await endpoints.issue.getIssues(sessionBuilder);
        final publicIssueA = publicList.firstWhere((i) => i.id == issueA.id);
        final publicIssueB = publicList.firstWhere((i) => i.id == issueB.id);
        expect(publicIssueA.userId, isNull);
        expect(publicIssueB.userId, isNull);

        final publicSingleA = await endpoints.issue.getIssueById(
          sessionBuilder,
          issueA.id!,
        );
        expect(publicSingleA!.userId, isNull);

        // 2. Citizen caller Alice: sees own userId on issueA, but null on issueB
        final aliceList = await endpoints.issue.getIssues(userASession);
        final aliceIssueA = aliceList.firstWhere((i) => i.id == issueA.id);
        final aliceIssueB = aliceList.firstWhere((i) => i.id == issueB.id);
        expect(aliceIssueA.userId, equals('reporter-alice'));
        expect(aliceIssueB.userId, isNull);

        final aliceSingleA = await endpoints.issue.getIssueById(
          userASession,
          issueA.id!,
        );
        expect(aliceSingleA!.userId, equals('reporter-alice'));

        final aliceSingleB = await endpoints.issue.getIssueById(
          userASession,
          issueB.id!,
        );
        expect(aliceSingleB!.userId, isNull);

        // 3. Official caller: sees full reporter userId on all issues
        final officialList = await endpoints.issue.getIssues(officialSession);
        final officialIssueA = officialList.firstWhere(
          (i) => i.id == issueA.id,
        );
        final officialIssueB = officialList.firstWhere(
          (i) => i.id == issueB.id,
        );
        expect(officialIssueA.userId, equals('reporter-alice'));
        expect(officialIssueB.userId, equals('reporter-bob'));

        final officialSingleA = await endpoints.issue.getIssueById(
          officialSession,
          issueA.id!,
        );
        expect(officialSingleA!.userId, equals('reporter-alice'));

        // 4. getMyIssues continues to return authenticated owner's full attribution
        final myIssues = await endpoints.issue.getMyIssues(userASession);
        expect(myIssues.any((i) => i.id == issueA.id), isTrue);
        expect(myIssues.every((i) => i.userId == 'reporter-alice'), isTrue);
      },
    );

    test(
      'Full role lifecycle: citizen creates -> admin assigns -> employee starts work & resolves -> citizen confirms fixed',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final empSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'worker-john',
            {},
          ),
        );
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-claire',
            {},
          ),
        );

        // 1. Provision worker-john as employee
        await endpoints.issue.provisionStaff(
          adminSession,
          'worker-john',
          'employee',
          department: 'Public Works',
          fullName: 'John Worker',
          email: 'john@city.gov',
        );

        // 2. Citizen creates issue
        final created = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Water leak on 5th Ave',
            description: 'Major water pipe burst near fire hydrant',
            category: 'Water',
            status: 'open',
            createdAt: DateTime.now(),
            priority: 'medium',
          ),
        );
        expect(created.id, isNotNull);
        expect(created.status, equals('open'));

        // 3. Admin assigns to worker-john with due date & department
        final due = DateTime.now().add(const Duration(days: 2));
        final assigned = await endpoints.issue.assignIssue(
          adminSession,
          created.id!,
          'worker-john',
          dueDate: due,
          priority: 'high',
          department: 'Public Works',
          notes: 'High priority leak repair',
        );
        expect(assigned.status, equals('assigned'));
        expect(assigned.assignedEmployeeId, equals('worker-john'));
        expect(assigned.priority, equals('high'));

        // Verify notification was sent to worker-john
        final workerNotifs = await endpoints.issue.getNotifications(empSession);
        expect(
          workerNotifs.any(
            (n) => n.issueId == created.id! && n.type == 'assignment',
          ),
          isTrue,
        );

        // 4. Employee sees assigned issue
        final empList = await endpoints.issue.getEmployeeAssignedIssues(
          empSession,
        );
        expect(empList.any((i) => i.id == created.id!), isTrue);

        // 5. Employee starts work
        final inProgress = await endpoints.issue.startWork(
          empSession,
          created.id!,
          notes: 'Excavation begun on site',
        );
        expect(inProgress.status, equals('in_progress'));

        // 6. Employee adds a progress note
        final withNote = await endpoints.issue.addProgressNote(
          empSession,
          created.id!,
          'Pipe valve replaced, backfilling trench',
        );
        expect(withNote.progressNotes, contains('Pipe valve replaced'));

        // 7. Employee resolves with completion notes & dummy photo
        final sampleBytes = Uint8List.fromList([
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
        ]);
        final byteData = ByteData.sublistView(sampleBytes);
        final resolved = await endpoints.issue.resolveIssue(
          empSession,
          created.id!,
          'Pipe completely fixed and tested under pressure',
          completionPhotoData: byteData,
          completionPhotoFileName: 'completed.png',
        );
        expect(resolved.status, equals('resolved'));
        expect(resolved.resolvedAt, isNotNull);
        expect(resolved.completionPhotoPath, isNotNull);

        // Verify citizen got notification of resolution
        final citizenNotifs = await endpoints.issue.getNotifications(
          citizenSession,
        );
        expect(
          citizenNotifs.any(
            (n) => n.issueId == created.id! && n.type == 'case_resolved',
          ),
          isTrue,
        );

        // 8. Citizen confirms fixed and closes the case
        final closed = await endpoints.issue.confirmCitizenClosure(
          citizenSession,
          created.id!,
          feedbackNotes: 'Water is running clean now. Thank you!',
        );
        expect(closed.status, equals('closed'));
        expect(closed.closedAt, isNotNull);

        // 9. Verify full audit trail
        final audits = await endpoints.issue.getIssueAuditHistory(
          adminSession,
          created.id!,
        );
        expect(audits.length, greaterThanOrEqualTo(5));
        final actions = audits.map((a) => a.action).toList();
        expect(actions, contains('created'));
        expect(actions, contains('assigned'));
        expect(actions, contains('work_started'));
        expect(actions, contains('resolved'));
        expect(actions, contains('closed_by_citizen'));
      },
    );

    test(
      'Dispute reopen: citizen reopens resolved case -> admin reassigns',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final empSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'worker-reopen',
            {},
          ),
        );
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-reopen',
            {},
          ),
        );

        await endpoints.issue.provisionStaff(
          adminSession,
          'worker-reopen',
          'employee',
        );

        final created = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Street light blinking',
            description: 'Light fixture flickers all night',
            category: 'Lighting',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        await endpoints.issue.assignIssue(
          adminSession,
          created.id!,
          'worker-reopen',
        );
        await endpoints.issue.startWork(empSession, created.id!);
        await endpoints.issue.resolveIssue(
          empSession,
          created.id!,
          'Bulb replaced',
        );

        // Citizen disputes fix
        final reopened = await endpoints.issue.reopenIssue(
          citizenSession,
          created.id!,
          'Light is still flickering at night, ballast may be faulty',
        );
        expect(reopened.status, equals('reopened'));
        expect(reopened.reopenReason, contains('ballast may be faulty'));
        expect(reopened.reopenedAt, isNotNull);

        // Admin reassigns
        final reassigned = await endpoints.issue.assignIssue(
          adminSession,
          created.id!,
          'worker-reopen',
          notes: 'Please check the ballast this time',
        );
        expect(reassigned.status, equals('assigned'));
      },
    );

    test(
      'Admin reject issue requires valid reason and rejects case',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-reject',
            {},
          ),
        );

        final created = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Private property complaint',
            description: 'Neighbors fence is ugly',
            category: 'Other',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // Empty reason throws ArgumentError
        await expectLater(
          () => endpoints.issue.rejectIssue(adminSession, created.id!, '   '),
          throwsA(isA<ArgumentError>()),
        );

        final rejected = await endpoints.issue.rejectIssue(
          adminSession,
          created.id!,
          'Private property dispute outside municipal jurisdiction',
        );
        expect(rejected.status, equals('rejected'));
        expect(rejected.rejectionReason, contains('jurisdiction'));
        expect(rejected.rejectedAt, isNotNull);
      },
    );

    test(
      'Rejection lifecycle: rejection from open, reopened, assigned, and invalid statuses',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-lifecycle-reject',
            {},
          ),
        );
        final workerSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'worker-reject-flow',
            {},
          ),
        );

        // Provision active employee
        await endpoints.issue.provisionStaff(
          adminSession,
          'worker-reject-flow',
          'employee',
          department: 'Public Works',
          fullName: 'Field Worker Dave',
          email: 'worker.dave@employeecivic.com',
        );

        // 1. Rejection from "open"
        final openCase = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Spam report',
            description: 'Advertisements on public bench',
            category: 'Sanitation',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );
        final rejectedOpen = await endpoints.issue.rejectIssue(
          adminSession,
          openCase.id!,
          'Spam / commercial solicitation',
        );
        expect(rejectedOpen.status, equals('rejected'));
        expect(
          rejectedOpen.rejectionReason,
          equals('Spam / commercial solicitation'),
        );
        expect(rejectedOpen.rejectedAt, isNotNull);

        // 2. Rejection from "assigned" (explicit assigned case workflow)
        final assignedCase = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Assigned case to be cancelled',
            description: 'Duplicate water leak report',
            category: 'Water',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );
        final assigned = await endpoints.issue.assignIssue(
          adminSession,
          assignedCase.id!,
          'worker-reject-flow',
        );
        expect(assigned.status, equals('assigned'));
        expect(assigned.assignedEmployeeId, equals('worker-reject-flow'));

        final rejectedAssigned = await endpoints.issue.rejectIssue(
          adminSession,
          assigned.id!,
          'Duplicate utility report; already addressed by regional water board',
        );
        expect(rejectedAssigned.status, equals('rejected'));
        expect(
          rejectedAssigned.assignedEmployeeId,
          equals('worker-reject-flow'),
          reason: 'Assignment record must be preserved for audit history',
        );
        expect(rejectedAssigned.assignedEmployeeName, isNotNull);
        expect(rejectedAssigned.rejectedAt, isNotNull);

        // Verify audit log for assigned rejection
        final auditLogs = await endpoints.issue.getIssueAuditHistory(
          adminSession,
          assigned.id!,
        );
        expect(
          auditLogs.any(
            (a) =>
                a.action == 'rejected_by_admin' &&
                a.previousStatus == 'assigned' &&
                a.newStatus == 'rejected' &&
                (a.notes?.contains('assigned to') ?? false),
          ),
          isTrue,
        );

        // 3. Rejection from "reopened"
        final reopenedCase = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Pothole for dispute',
            description: 'Road damage on Maple Street',
            category: 'Roads',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );
        await endpoints.issue.assignIssue(
          adminSession,
          reopenedCase.id!,
          'worker-reject-flow',
        );
        await endpoints.issue.startWork(workerSession, reopenedCase.id!);
        await endpoints.issue.resolveIssue(
          workerSession,
          reopenedCase.id!,
          'Paved patch applied',
        );
        await endpoints.issue.reopenIssue(
          citizenSession,
          reopenedCase.id!,
          'Patch has cracked again',
        );
        final rejectedReopened = await endpoints.issue.rejectIssue(
          adminSession,
          reopenedCase.id!,
          'Private driveway outside city jurisdiction upon re-inspection',
        );
        expect(rejectedReopened.status, equals('rejected'));
        expect(rejectedReopened.rejectionReason, contains('jurisdiction'));

        // 4. Invalid transitions: in_progress, resolved, closed, rejected
        // 4a. in_progress
        final inProgressCase = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Active work case',
            description: 'Streetlight outage',
            category: 'Electrical',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );
        await endpoints.issue.assignIssue(
          adminSession,
          inProgressCase.id!,
          'worker-reject-flow',
        );
        await endpoints.issue.startWork(workerSession, inProgressCase.id!);
        await expectLater(
          () => endpoints.issue.rejectIssue(
            adminSession,
            inProgressCase.id!,
            'Try rejecting active work',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Work is currently in progress'),
            ),
          ),
        );

        // 4b. resolved
        await endpoints.issue.resolveIssue(
          workerSession,
          inProgressCase.id!,
          'Bulb replaced',
        );
        await expectLater(
          () => endpoints.issue.rejectIssue(
            adminSession,
            inProgressCase.id!,
            'Try rejecting resolved case',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('already been resolved'),
            ),
          ),
        );

        // 4c. closed
        await endpoints.issue.confirmCitizenClosure(
          citizenSession,
          inProgressCase.id!,
        );
        await expectLater(
          () => endpoints.issue.rejectIssue(
            adminSession,
            inProgressCase.id!,
            'Try rejecting closed case',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Case is closed'),
            ),
          ),
        );

        // 4d. rejected
        await expectLater(
          () => endpoints.issue.rejectIssue(
            adminSession,
            rejectedOpen.id!,
            'Try rejecting already rejected case',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('already been rejected'),
            ),
          ),
        );
      },
    );

    test(
      'Anonymous issue with claim token allows owner to confirm fixed or dispute reopen',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final empSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'worker-anon',
            {},
          ),
        );

        await endpoints.issue.provisionStaff(
          adminSession,
          'worker-anon',
          'employee',
        );

        // Anonymous creation returns claimToken
        final created = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Illegal dumping in park',
            description: 'Tires dumped by park entrance',
            category: 'Sanitation',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );
        expect(created.claimToken, isNotNull);
        final token = created.claimToken!;

        await endpoints.issue.assignIssue(
          adminSession,
          created.id!,
          'worker-anon',
        );
        await endpoints.issue.startWork(empSession, created.id!);
        await endpoints.issue.resolveIssue(
          empSession,
          created.id!,
          'Tires collected and hauled away',
        );

        // Anonymous claimant can confirm closure using claimToken
        final closed = await endpoints.issue.confirmCitizenClosure(
          sessionBuilder,
          created.id!,
          claimToken: token,
          feedbackNotes: 'All clean now, thank you!',
        );
        expect(closed.status, equals('closed'));

        // Invalid claim token fails
        await expectLater(
          () => endpoints.issue.confirmCitizenClosure(
            sessionBuilder,
            created.id!,
            claimToken: 'invalid_token_123',
          ),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
      },
    );

    test(
      'RBAC and authorization enforcement across roles',
      () async {
        final citizenSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'citizen-rbac',
            {},
          ),
        );
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final emp1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'emp-1',
            {},
          ),
        );
        final emp2Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'emp-2',
            {},
          ),
        );

        await endpoints.issue.provisionStaff(adminSession, 'emp-1', 'employee');
        await endpoints.issue.provisionStaff(adminSession, 'emp-2', 'employee');

        final issue = await endpoints.issue.createIssue(
          citizenSession,
          Issue(
            title: 'Traffic light dead',
            description: 'Intersection is dark',
            category: 'Traffic',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // 1. Citizen cannot access admin stats or admin issues
        await expectLater(
          () => endpoints.issue.getAdminStats(citizenSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
        await expectLater(
          () => endpoints.issue.getAdminIssues(citizenSession),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );

        // 2. Citizen cannot assign or reject
        await expectLater(
          () => endpoints.issue.assignIssue(citizenSession, issue.id!, 'emp-1'),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );
        await expectLater(
          () => endpoints.issue.rejectIssue(citizenSession, issue.id!, 'Spam'),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );

        // 3. Admin assigns to emp-1
        await endpoints.issue.assignIssue(adminSession, issue.id!, 'emp-1');

        // 4. emp-2 cannot start work on emp-1's case
        await expectLater(
          () => endpoints.issue.startWork(emp2Session, issue.id!),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );

        // 5. emp-1 starts work & resolves
        await endpoints.issue.startWork(emp1Session, issue.id!);
        await endpoints.issue.resolveIssue(
          emp1Session,
          issue.id!,
          'Fixed wiring',
        );

        // 6. Employee cannot close case (only citizen reporter can close)
        await expectLater(
          () => endpoints.issue.confirmCitizenClosure(emp1Session, issue.id!),
          throwsA(isA<ServerpodInsufficientAccessException>()),
        );

        // 7. Admin stats returns valid numbers
        final stats = await endpoints.issue.getAdminStats(adminSession);
        expect(stats.totalReports, greaterThanOrEqualTo(1));
        expect(stats.resolvedReports, greaterThanOrEqualTo(1));
      },
    );

    test(
      'In-app notification management and read status updates',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final notifUserSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'notif-recipient',
            {},
          ),
        );

        await endpoints.issue.provisionStaff(
          adminSession,
          'notif-recipient',
          'employee',
        );

        final issue = await endpoints.issue.createIssue(
          sessionBuilder,
          Issue(
            title: 'Notification test issue',
            description: 'Testing notification inbox',
            category: 'Testing',
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

        // Assign generates notification
        await endpoints.issue.assignIssue(
          adminSession,
          issue.id!,
          'notif-recipient',
        );

        final notifs = await endpoints.issue.getNotifications(notifUserSession);
        expect(notifs, isNotEmpty);
        final firstNotif = notifs.first;
        expect(firstNotif.isRead, isFalse);

        // Mark single read
        final marked = await endpoints.issue.markNotificationRead(
          notifUserSession,
          firstNotif.id!,
        );
        expect(marked, isTrue);

        final unreadAfter = await endpoints.issue.getNotifications(
          notifUserSession,
          unreadOnly: true,
        );
        expect(unreadAfter.any((n) => n.id == firstNotif.id), isFalse);

        // Mark all read
        final count = await endpoints.issue.markAllNotificationsRead(
          notifUserSession,
        );
        expect(count, greaterThanOrEqualTo(0));
      },
    );

    test(
      'Staff management directory, profile, and active status toggle',
      () async {
        final adminSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'admin@official.civicloop',
            {const Scope('admin'), const Scope('official')},
          ),
        );
        final staffSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'staff-profile-test',
            {},
          ),
        );

        await endpoints.issue.provisionStaff(
          adminSession,
          'staff-profile-test',
          'employee',
          department: 'Parks & Recreation',
          fullName: 'Jane Park',
          email: 'jane@city.gov',
        );

        // Verify profile retrieval
        final profile = await endpoints.issue.getCurrentUserProfile(
          staffSession,
        );
        expect(profile, isNotNull);
        expect(profile!.role, equals('employee'));
        expect(profile.department, equals('Parks & Recreation'));
        expect(profile.fullName, equals('Jane Park'));

        // Admin directory includes Jane
        final directory = await endpoints.issue.getStaffUsers(adminSession);
        expect(directory.any((s) => s.userId == 'staff-profile-test'), isTrue);

        // Admin deactivates staff
        final deactivated = await endpoints.issue.setStaffActiveStatus(
          adminSession,
          'staff-profile-test',
          false,
        );
        expect(deactivated.isActive, isFalse);
      },
    );
  });
}
