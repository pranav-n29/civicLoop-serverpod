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

abstract class Issue
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Issue._({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.userId,
    this.photoPath,
    this.priority,
    this.department,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.assignedAt,
    this.dueDate,
    this.progressNotes,
    this.completionNotes,
    this.completionPhotoPath,
    this.resolvedAt,
    this.closedAt,
    this.reopenedAt,
    this.reopenReason,
    this.rejectionReason,
    this.rejectedAt,
    this.claimHash,
    this.claimToken,
    this.uploadToken,
  });

  factory Issue({
    int? id,
    required String title,
    required String description,
    required String category,
    required String status,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
    String? userId,
    String? photoPath,
    String? priority,
    String? department,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    DateTime? assignedAt,
    DateTime? dueDate,
    String? progressNotes,
    String? completionNotes,
    String? completionPhotoPath,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    String? reopenReason,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? claimHash,
    String? claimToken,
    String? uploadToken,
  }) = _IssueImpl;

  factory Issue.fromJson(Map<String, dynamic> jsonSerialization) {
    return Issue(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      category: jsonSerialization['category'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      userId: jsonSerialization['userId'] as String?,
      photoPath: jsonSerialization['photoPath'] as String?,
      priority: jsonSerialization['priority'] as String?,
      department: jsonSerialization['department'] as String?,
      assignedEmployeeId: jsonSerialization['assignedEmployeeId'] as String?,
      assignedEmployeeName:
          jsonSerialization['assignedEmployeeName'] as String?,
      assignedAt: jsonSerialization['assignedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['assignedAt'],
            ),
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      progressNotes: jsonSerialization['progressNotes'] as String?,
      completionNotes: jsonSerialization['completionNotes'] as String?,
      completionPhotoPath: jsonSerialization['completionPhotoPath'] as String?,
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
      reopenedAt: jsonSerialization['reopenedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reopenedAt'],
            ),
      reopenReason: jsonSerialization['reopenReason'] as String?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
      rejectedAt: jsonSerialization['rejectedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['rejectedAt'],
            ),
      claimHash: jsonSerialization['claimHash'] as String?,
      claimToken: jsonSerialization['claimToken'] as String?,
      uploadToken: jsonSerialization['uploadToken'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  String description;

  String category;

  String status;

  DateTime createdAt;

  double? latitude;

  double? longitude;

  String? userId;

  String? photoPath;

  String? priority;

  String? department;

  String? assignedEmployeeId;

  String? assignedEmployeeName;

  DateTime? assignedAt;

  DateTime? dueDate;

  String? progressNotes;

  String? completionNotes;

  String? completionPhotoPath;

  DateTime? resolvedAt;

  DateTime? closedAt;

  DateTime? reopenedAt;

  String? reopenReason;

  String? rejectionReason;

  DateTime? rejectedAt;

  String? claimHash;

  String? claimToken;

  String? uploadToken;

  /// Returns a shallow copy of this [Issue]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Issue copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? userId,
    String? photoPath,
    String? priority,
    String? department,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    DateTime? assignedAt,
    DateTime? dueDate,
    String? progressNotes,
    String? completionNotes,
    String? completionPhotoPath,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    String? reopenReason,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? claimHash,
    String? claimToken,
    String? uploadToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Issue',
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt.toJson(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (userId != null) 'userId': userId,
      if (photoPath != null) 'photoPath': photoPath,
      if (priority != null) 'priority': priority,
      if (department != null) 'department': department,
      if (assignedEmployeeId != null) 'assignedEmployeeId': assignedEmployeeId,
      if (assignedEmployeeName != null)
        'assignedEmployeeName': assignedEmployeeName,
      if (assignedAt != null) 'assignedAt': assignedAt?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      if (progressNotes != null) 'progressNotes': progressNotes,
      if (completionNotes != null) 'completionNotes': completionNotes,
      if (completionPhotoPath != null)
        'completionPhotoPath': completionPhotoPath,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (reopenedAt != null) 'reopenedAt': reopenedAt?.toJson(),
      if (reopenReason != null) 'reopenReason': reopenReason,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (rejectedAt != null) 'rejectedAt': rejectedAt?.toJson(),
      if (claimHash != null) 'claimHash': claimHash,
      if (claimToken != null) 'claimToken': claimToken,
      if (uploadToken != null) 'uploadToken': uploadToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Issue',
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt.toJson(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (userId != null) 'userId': userId,
      if (photoPath != null) 'photoPath': photoPath,
      if (priority != null) 'priority': priority,
      if (department != null) 'department': department,
      if (assignedEmployeeId != null) 'assignedEmployeeId': assignedEmployeeId,
      if (assignedEmployeeName != null)
        'assignedEmployeeName': assignedEmployeeName,
      if (assignedAt != null) 'assignedAt': assignedAt?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      if (progressNotes != null) 'progressNotes': progressNotes,
      if (completionNotes != null) 'completionNotes': completionNotes,
      if (completionPhotoPath != null)
        'completionPhotoPath': completionPhotoPath,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (reopenedAt != null) 'reopenedAt': reopenedAt?.toJson(),
      if (reopenReason != null) 'reopenReason': reopenReason,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (rejectedAt != null) 'rejectedAt': rejectedAt?.toJson(),
      if (claimHash != null) 'claimHash': claimHash,
      if (claimToken != null) 'claimToken': claimToken,
      if (uploadToken != null) 'uploadToken': uploadToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IssueImpl extends Issue {
  _IssueImpl({
    int? id,
    required String title,
    required String description,
    required String category,
    required String status,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
    String? userId,
    String? photoPath,
    String? priority,
    String? department,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    DateTime? assignedAt,
    DateTime? dueDate,
    String? progressNotes,
    String? completionNotes,
    String? completionPhotoPath,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    String? reopenReason,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? claimHash,
    String? claimToken,
    String? uploadToken,
  }) : super._(
         id: id,
         title: title,
         description: description,
         category: category,
         status: status,
         createdAt: createdAt,
         latitude: latitude,
         longitude: longitude,
         userId: userId,
         photoPath: photoPath,
         priority: priority,
         department: department,
         assignedEmployeeId: assignedEmployeeId,
         assignedEmployeeName: assignedEmployeeName,
         assignedAt: assignedAt,
         dueDate: dueDate,
         progressNotes: progressNotes,
         completionNotes: completionNotes,
         completionPhotoPath: completionPhotoPath,
         resolvedAt: resolvedAt,
         closedAt: closedAt,
         reopenedAt: reopenedAt,
         reopenReason: reopenReason,
         rejectionReason: rejectionReason,
         rejectedAt: rejectedAt,
         claimHash: claimHash,
         claimToken: claimToken,
         uploadToken: uploadToken,
       );

  /// Returns a shallow copy of this [Issue]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Issue copyWith({
    Object? id = _Undefined,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? createdAt,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    Object? userId = _Undefined,
    Object? photoPath = _Undefined,
    Object? priority = _Undefined,
    Object? department = _Undefined,
    Object? assignedEmployeeId = _Undefined,
    Object? assignedEmployeeName = _Undefined,
    Object? assignedAt = _Undefined,
    Object? dueDate = _Undefined,
    Object? progressNotes = _Undefined,
    Object? completionNotes = _Undefined,
    Object? completionPhotoPath = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? closedAt = _Undefined,
    Object? reopenedAt = _Undefined,
    Object? reopenReason = _Undefined,
    Object? rejectionReason = _Undefined,
    Object? rejectedAt = _Undefined,
    Object? claimHash = _Undefined,
    Object? claimToken = _Undefined,
    Object? uploadToken = _Undefined,
  }) {
    return Issue(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      userId: userId is String? ? userId : this.userId,
      photoPath: photoPath is String? ? photoPath : this.photoPath,
      priority: priority is String? ? priority : this.priority,
      department: department is String? ? department : this.department,
      assignedEmployeeId: assignedEmployeeId is String?
          ? assignedEmployeeId
          : this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName is String?
          ? assignedEmployeeName
          : this.assignedEmployeeName,
      assignedAt: assignedAt is DateTime? ? assignedAt : this.assignedAt,
      dueDate: dueDate is DateTime? ? dueDate : this.dueDate,
      progressNotes: progressNotes is String?
          ? progressNotes
          : this.progressNotes,
      completionNotes: completionNotes is String?
          ? completionNotes
          : this.completionNotes,
      completionPhotoPath: completionPhotoPath is String?
          ? completionPhotoPath
          : this.completionPhotoPath,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      closedAt: closedAt is DateTime? ? closedAt : this.closedAt,
      reopenedAt: reopenedAt is DateTime? ? reopenedAt : this.reopenedAt,
      reopenReason: reopenReason is String? ? reopenReason : this.reopenReason,
      rejectionReason: rejectionReason is String?
          ? rejectionReason
          : this.rejectionReason,
      rejectedAt: rejectedAt is DateTime? ? rejectedAt : this.rejectedAt,
      claimHash: claimHash is String? ? claimHash : this.claimHash,
      claimToken: claimToken is String? ? claimToken : this.claimToken,
      uploadToken: uploadToken is String? ? uploadToken : this.uploadToken,
    );
  }
}
