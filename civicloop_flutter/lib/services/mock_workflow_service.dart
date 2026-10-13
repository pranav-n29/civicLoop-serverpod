import '../models/demo_issue.dart';

class MockWorkflowService {
  final List<DemoIssue> _issues = defaultDemoIssues();
  static const responders = ['Aisha Khan', 'Marco Silva', 'Priya Shah'];

  Future<List<DemoIssue>> getIssues() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List.unmodifiable(_issues);
  }

  Future<DemoIssue> reviewIssue(String id) => _update(
    id,
    (issue) => issue.status == CivicIssueStatus.reported
        ? issue.copyWith(status: CivicIssueStatus.underReview)
        : issue,
  );

  Future<DemoIssue> assignIssue(String id, String responder) => _update(
    id,
    (issue) => issue.status == CivicIssueStatus.underReview
        ? issue.copyWith(
            status: CivicIssueStatus.assigned,
            assignedResponder: responder,
          )
        : issue,
  );

  Future<DemoIssue> startWork(String id) => _update(
    id,
    (issue) => issue.status == CivicIssueStatus.assigned
        ? issue.copyWith(status: CivicIssueStatus.inProgress)
        : issue,
  );

  Future<DemoIssue> submitResolution(String id, String note) => _update(
    id,
    (issue) => issue.status == CivicIssueStatus.inProgress
        ? issue.copyWith(
            status: CivicIssueStatus.resolved,
            hasResolutionEvidence: true,
            resolutionNote: note,
          )
        : issue,
  );

  Future<DemoIssue> _update(
    String id,
    DemoIssue Function(DemoIssue) transform,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final index = _issues.indexWhere((issue) => issue.id == id);
    if (index < 0) throw StateError('Demo issue not found.');
    final updated = transform(_issues[index]);
    _issues[index] = updated;
    return updated;
  }
}
