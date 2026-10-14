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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class CivicIssueAudit
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CivicIssueAudit._({
    this.id,
    required this.issueId,
    required this.actorId,
    required this.actorRole,
    this.actorName,
    required this.action,
    this.previousStatus,
    this.newStatus,
    this.notes,
    required this.timestamp,
  });

  factory CivicIssueAudit({
    int? id,
    required int issueId,
    required String actorId,
    required String actorRole,
    String? actorName,
    required String action,
    String? previousStatus,
    String? newStatus,
    String? notes,
    required DateTime timestamp,
  }) = _CivicIssueAuditImpl;

  factory CivicIssueAudit.fromJson(Map<String, dynamic> jsonSerialization) {
    return CivicIssueAudit(
      id: jsonSerialization['id'] as int?,
      issueId: jsonSerialization['issueId'] as int,
      actorId: jsonSerialization['actorId'] as String,
      actorRole: jsonSerialization['actorRole'] as String,
      actorName: jsonSerialization['actorName'] as String?,
      action: jsonSerialization['action'] as String,
      previousStatus: jsonSerialization['previousStatus'] as String?,
      newStatus: jsonSerialization['newStatus'] as String?,
      notes: jsonSerialization['notes'] as String?,
      timestamp: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  int? id;

  int issueId;

  String actorId;

  String actorRole;

  String? actorName;

  String action;

  String? previousStatus;

  String? newStatus;

  String? notes;

  DateTime timestamp;

  @_isc.useResult
  CivicIssueAudit copyWith({
    int? id,
    int? issueId,
    String? actorId,
    String? actorRole,
    String? actorName,
    String? action,
    String? previousStatus,
    String? newStatus,
    String? notes,
    DateTime? timestamp,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CivicIssueAudit',
      if (id != null) 'id': id,
      'issueId': issueId,
      'actorId': actorId,
      'actorRole': actorRole,
      if (actorName != null) 'actorName': actorName,
      'action': action,
      if (previousStatus != null) 'previousStatus': previousStatus,
      if (newStatus != null) 'newStatus': newStatus,
      if (notes != null) 'notes': notes,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CivicIssueAudit',
      if (id != null) 'id': id,
      'issueId': issueId,
      'actorId': actorId,
      'actorRole': actorRole,
      if (actorName != null) 'actorName': actorName,
      'action': action,
      if (previousStatus != null) 'previousStatus': previousStatus,
      if (newStatus != null) 'newStatus': newStatus,
      if (notes != null) 'notes': notes,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CivicIssueAuditImpl extends CivicIssueAudit {
  _CivicIssueAuditImpl({
    int? id,
    required int issueId,
    required String actorId,
    required String actorRole,
    String? actorName,
    required String action,
    String? previousStatus,
    String? newStatus,
    String? notes,
    required DateTime timestamp,
  }) : super._(
          id: id,
          issueId: issueId,
          actorId: actorId,
          actorRole: actorRole,
          actorName: actorName,
          action: action,
          previousStatus: previousStatus,
          newStatus: newStatus,
          notes: notes,
          timestamp: timestamp,
        );

  @override
  CivicIssueAudit copyWith({
    Object? id = _Undefined,
    int? issueId,
    String? actorId,
    String? actorRole,
    Object? actorName = _Undefined,
    String? action,
    Object? previousStatus = _Undefined,
    Object? newStatus = _Undefined,
    Object? notes = _Undefined,
    DateTime? timestamp,
  }) {
    return CivicIssueAudit(
      id: id is int? ? id : this.id,
      issueId: issueId ?? this.issueId,
      actorId: actorId ?? this.actorId,
      actorRole: actorRole ?? this.actorRole,
      actorName: actorName is String? ? actorName : this.actorName,
      action: action ?? this.action,
      previousStatus:
          previousStatus is String? ? previousStatus : this.previousStatus,
      newStatus: newStatus is String? ? newStatus : this.newStatus,
      notes: notes is String? ? notes : this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
