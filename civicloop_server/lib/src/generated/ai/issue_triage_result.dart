/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class IssueTriageResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  IssueTriageResult._({
    required this.suggestedTitle,
    required this.category,
    required this.priority,
    required this.department,
    required this.summary,
  });

  factory IssueTriageResult({
    required String suggestedTitle,
    required String category,
    required String priority,
    required String department,
    required String summary,
  }) = _IssueTriageResultImpl;

  factory IssueTriageResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return IssueTriageResult(
      suggestedTitle: jsonSerialization['suggestedTitle'] as String,
      category: jsonSerialization['category'] as String,
      priority: jsonSerialization['priority'] as String,
      department: jsonSerialization['department'] as String,
      summary: jsonSerialization['summary'] as String,
    );
  }

  String suggestedTitle;

  String category;

  String priority;

  String department;

  String summary;

  /// Returns a shallow copy of this [IssueTriageResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IssueTriageResult copyWith({
    String? suggestedTitle,
    String? category,
    String? priority,
    String? department,
    String? summary,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IssueTriageResult',
      'suggestedTitle': suggestedTitle,
      'category': category,
      'priority': priority,
      'department': department,
      'summary': summary,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IssueTriageResult',
      'suggestedTitle': suggestedTitle,
      'category': category,
      'priority': priority,
      'department': department,
      'summary': summary,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _IssueTriageResultImpl extends IssueTriageResult {
  _IssueTriageResultImpl({
    required String suggestedTitle,
    required String category,
    required String priority,
    required String department,
    required String summary,
  }) : super._(
         suggestedTitle: suggestedTitle,
         category: category,
         priority: priority,
         department: department,
         summary: summary,
       );

  /// Returns a shallow copy of this [IssueTriageResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IssueTriageResult copyWith({
    String? suggestedTitle,
    String? category,
    String? priority,
    String? department,
    String? summary,
  }) {
    return IssueTriageResult(
      suggestedTitle: suggestedTitle ?? this.suggestedTitle,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      department: department ?? this.department,
      summary: summary ?? this.summary,
    );
  }
}
