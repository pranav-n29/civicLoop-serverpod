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

abstract class CivicNotification
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CivicNotification._({
    this.id,
    required this.recipientId,
    required this.issueId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory CivicNotification({
    int? id,
    required String recipientId,
    required int issueId,
    required String type,
    required String title,
    required String message,
    required bool isRead,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _CivicNotificationImpl;

  factory CivicNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return CivicNotification(
      id: jsonSerialization['id'] as int?,
      recipientId: jsonSerialization['recipientId'] as String,
      issueId: jsonSerialization['issueId'] as int,
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String,
      message: jsonSerialization['message'] as String,
      isRead: jsonSerialization['isRead'] as bool,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['readAt'],
            ),
    );
  }

  int? id;

  String recipientId;

  int issueId;

  String type;

  String title;

  String message;

  bool isRead;

  DateTime createdAt;

  DateTime? readAt;

  @_isc.useResult
  CivicNotification copyWith({
    int? id,
    String? recipientId,
    int? issueId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CivicNotification',
      if (id != null) 'id': id,
      'recipientId': recipientId,
      'issueId': issueId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CivicNotification',
      if (id != null) 'id': id,
      'recipientId': recipientId,
      'issueId': issueId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CivicNotificationImpl extends CivicNotification {
  _CivicNotificationImpl({
    int? id,
    required String recipientId,
    required int issueId,
    required String type,
    required String title,
    required String message,
    required bool isRead,
    required DateTime createdAt,
    DateTime? readAt,
  }) : super._(
          id: id,
          recipientId: recipientId,
          issueId: issueId,
          type: type,
          title: title,
          message: message,
          isRead: isRead,
          createdAt: createdAt,
          readAt: readAt,
        );

  @override
  CivicNotification copyWith({
    Object? id = _Undefined,
    String? recipientId,
    int? issueId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Object? readAt = _Undefined,
  }) {
    return CivicNotification(
      id: id is int? ? id : this.id,
      recipientId: recipientId ?? this.recipientId,
      issueId: issueId ?? this.issueId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
    );
  }
}
