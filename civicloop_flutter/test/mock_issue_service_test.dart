import 'package:flutter_test/flutter_test.dart';

import 'package:civicloop_flutter/models/demo_issue.dart';
import 'package:civicloop_flutter/services/mock_issue_service.dart';

void main() {
  test('creates a user report in the shared demo collection', () async {
    final service = MockIssueService();

    final created = await service.addReport(
      category: 'Roads',
      severity: 'High',
      description: 'A new demo report',
      location: 'Oakridge Avenue',
    );
    final issues = await service.getIssues();

    expect(created.isUserReport, isTrue);
    expect(created.status, CivicIssueStatus.reported);
    expect(issues.first.id, created.id);
    expect(issues.first.description, 'A new demo report');
  });

  test('supporting the same issue twice is idempotent', () async {
    final service = MockIssueService();
    final issue = (await service.getIssues()).first;
    final originalCount = issue.supportCount;

    final first = await service.supportIssue(issue.id);
    final second = await service.supportIssue(issue.id);

    expect(first.supportCount, originalCount + 1);
    expect(second.supportCount, originalCount + 1);
  });

  test('verification is limited to eligible resolved issues', () async {
    final service = MockIssueService();
    final issues = await service.getIssues();
    final resolved = issues.firstWhere(
      (issue) => issue.status == CivicIssueStatus.resolved,
    );
    final active = issues.firstWhere(
      (issue) => issue.status != CivicIssueStatus.resolved,
    );

    final verified = await service.submitVerification(
      issueId: resolved.id,
      resolved: true,
    );

    expect(verified.verificationSubmitted, isTrue);
    expect(
      () => service.submitVerification(issueId: active.id, resolved: true),
      throwsStateError,
    );
  });
}
