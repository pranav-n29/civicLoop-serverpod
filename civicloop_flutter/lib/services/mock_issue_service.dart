import '../models/demo_issue.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MockIssueService {
  final List<DemoIssue> _issues = List<DemoIssue>.from(defaultDemoIssues());
  final Set<String> _supportedIssueIds = <String>{};

  MockIssueService();

  Future<List<DemoIssue>> getIssues() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List.unmodifiable(_issues);
  }

  Future<DemoIssue> supportIssue(String issueId) async {
    final index = _issues.indexWhere((issue) => issue.id == issueId);
    if (index < 0) throw StateError('Demo issue not found.');
    if (!_supportedIssueIds.add(issueId)) return _issues[index];
    final updated = _issues[index].copyWith(
      supportCount: _issues[index].supportCount + 1,
    );
    _issues[index] = updated;
    return updated;
  }

  Future<DemoIssue> updateClassification({
    required String issueId,
    required String category,
    required String severity,
  }) async {
    final index = _issues.indexWhere((issue) => issue.id == issueId);
    if (index < 0) throw StateError('Demo issue not found.');
    final updated = _issues[index].copyWith(
      category: category,
      severity: severity,
    );
    _issues[index] = updated;
    return updated;
  }

  Future<DemoIssue> addReport({
    required String category,
    required String severity,
    required String description,
    String? location,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final issue = DemoIssue(
      id: 'citizen-${DateTime.now().microsecondsSinceEpoch}',
      title: '$category report',
      description: description,
      category: category,
      severity: severity,
      status: CivicIssueStatus.reported,
      location: location,
      reportedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      supportCount: 0,
      icon: _iconForCategory(category),
      color: _colorForSeverity(severity),
      isUserReport: true,
    );
    _issues.insert(0, issue);
    return issue;
  }

  IconData _iconForCategory(String category) => switch (category) {
    'Roads' => Icons.construction_rounded,
    'Streetlights' => Icons.lightbulb_outline_rounded,
    'Water' => Icons.water_drop_outlined,
    'Waste' => Icons.delete_outline_rounded,
    'Drainage' => Icons.waterfall_chart_outlined,
    'Public Safety' => Icons.shield_outlined,
    _ => Icons.report_problem_outlined,
  };

  Color _colorForSeverity(String severity) => switch (severity) {
    'Critical' => CivicColors.critical,
    'High' => CivicColors.warning,
    'Low' => CivicColors.success,
    _ => CivicColors.blue,
  };

  Future<DemoIssue> submitVerification({
    required String issueId,
    required bool resolved,
  }) async {
    final index = _issues.indexWhere((issue) => issue.id == issueId);
    if (index < 0) throw StateError('Demo issue not found.');
    if (!_issues[index].eligibleForVerification) {
      throw StateError('This demo issue is not eligible for verification.');
    }
    final updated = _issues[index].copyWith(
      status: resolved ? CivicIssueStatus.resolved : CivicIssueStatus.reopened,
      verificationSubmitted: true,
    );
    _issues[index] = updated;
    return updated;
  }
}
