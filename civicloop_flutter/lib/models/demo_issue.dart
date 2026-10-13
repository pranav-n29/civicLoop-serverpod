import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum CivicIssueStatus {
  reported,
  underReview,
  assigned,
  inProgress,
  resolved,
  reopened,
  rejected,
}

extension CivicIssueStatusLabel on CivicIssueStatus {
  String get label => switch (this) {
    CivicIssueStatus.reported => 'Reported',
    CivicIssueStatus.underReview => 'Under Review',
    CivicIssueStatus.assigned => 'Assigned',
    CivicIssueStatus.inProgress => 'In Progress',
    CivicIssueStatus.resolved => 'Resolved',
    CivicIssueStatus.reopened => 'Reopened',
    CivicIssueStatus.rejected => 'Rejected',
  };
}

class DemoIssue {
  final String id;
  final String title;
  final String description;
  final String category;
  final String severity;
  final CivicIssueStatus status;
  final String? location;
  final DateTime? reportedAt;
  final DateTime? updatedAt;
  final int supportCount;
  final IconData icon;
  final Color color;
  final bool hasResolutionEvidence;
  final String? resolutionNote;
  final DateTime? resolvedAt;
  final bool verificationSubmitted;
  final String? assignedResponder;
  final bool isUserReport;

  const DemoIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.location,
    required this.reportedAt,
    required this.updatedAt,
    required this.supportCount,
    required this.icon,
    required this.color,
    this.hasResolutionEvidence = false,
    this.resolutionNote,
    this.resolvedAt,
    this.verificationSubmitted = false,
    this.assignedResponder,
    this.isUserReport = false,
  });

  bool get eligibleForVerification =>
      status == CivicIssueStatus.resolved && !verificationSubmitted;

  DemoIssue copyWith({
    String? category,
    String? severity,
    CivicIssueStatus? status,
    int? supportCount,
    bool? verificationSubmitted,
    String? assignedResponder,
    String? resolutionNote,
    bool? hasResolutionEvidence,
    bool? isUserReport,
  }) {
    return DemoIssue(
      id: id,
      title: title,
      description: description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      location: location,
      reportedAt: reportedAt,
      updatedAt: updatedAt,
      supportCount: supportCount ?? this.supportCount,
      icon: icon,
      color: color,
      hasResolutionEvidence:
          hasResolutionEvidence ?? this.hasResolutionEvidence,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolvedAt: resolvedAt,
      verificationSubmitted:
          verificationSubmitted ?? this.verificationSubmitted,
      assignedResponder: assignedResponder ?? this.assignedResponder,
      isUserReport: isUserReport ?? this.isUserReport,
    );
  }
}

List<DemoIssue> defaultDemoIssues() => const [
  DemoIssue(
    id: 'oakridge-pothole',
    title: 'Pothole on Oakridge Avenue',
    description: 'A large pothole is affecting traffic near the main junction.',
    category: 'Roads',
    severity: 'High',
    status: CivicIssueStatus.inProgress,
    location: 'Oakridge Avenue • 0.2 mi away',
    reportedAt: null,
    updatedAt: null,
    supportCount: 12,
    icon: Icons.construction_rounded,
    color: CivicColors.critical,
  ),
  DemoIssue(
    id: 'ward-four-light',
    title: 'Broken streetlight near Ward 4',
    description: 'The streetlight has not turned on for several evenings.',
    category: 'Streetlight',
    severity: 'Medium',
    status: CivicIssueStatus.underReview,
    location: 'Ward 4 • 0.4 mi away',
    reportedAt: null,
    updatedAt: null,
    supportCount: 7,
    icon: Icons.lightbulb_outline_rounded,
    color: CivicColors.warning,
  ),
  DemoIssue(
    id: 'recycling-bins',
    title: 'Overflowing recycling bins',
    description: 'Recycling bins are full near the community center.',
    category: 'Sanitation',
    severity: 'Low',
    status: CivicIssueStatus.resolved,
    location: 'Community center • 0.6 mi away',
    reportedAt: null,
    updatedAt: null,
    supportCount: 4,
    icon: Icons.delete_outline_rounded,
    color: CivicColors.success,
    hasResolutionEvidence: true,
    resolutionNote: 'Bins were emptied and the collection route was updated.',
    resolvedAt: null,
  ),
];
