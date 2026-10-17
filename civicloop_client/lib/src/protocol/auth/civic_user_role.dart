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

abstract class CivicUserRole
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CivicUserRole._({
    this.id,
    required this.userId,
    this.email,
    this.fullName,
    required this.role,
    this.department,
    required this.isActive,
    this.employeeId,
    this.approvalStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CivicUserRole({
    int? id,
    required String userId,
    String? email,
    String? fullName,
    required String role,
    String? department,
    required bool isActive,
    String? employeeId,
    String? approvalStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CivicUserRoleImpl;

  factory CivicUserRole.fromJson(Map<String, dynamic> jsonSerialization) {
    return CivicUserRole(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      email: jsonSerialization['email'] as String?,
      fullName: jsonSerialization['fullName'] as String?,
      role: jsonSerialization['role'] as String,
      department: jsonSerialization['department'] as String?,
      isActive: _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      employeeId: jsonSerialization['employeeId'] as String?,
      approvalStatus: jsonSerialization['approvalStatus'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String? email;

  String? fullName;

  String role;

  String? department;

  bool isActive;

  String? employeeId;

  String? approvalStatus;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [CivicUserRole]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CivicUserRole copyWith({
    int? id,
    String? userId,
    String? email,
    String? fullName,
    String? role,
    String? department,
    bool? isActive,
    String? employeeId,
    String? approvalStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CivicUserRole',
      if (id != null) 'id': id,
      'userId': userId,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      if (department != null) 'department': department,
      'isActive': isActive,
      if (employeeId != null) 'employeeId': employeeId,
      if (approvalStatus != null) 'approvalStatus': approvalStatus,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CivicUserRole',
      if (id != null) 'id': id,
      'userId': userId,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      if (department != null) 'department': department,
      'isActive': isActive,
      if (employeeId != null) 'employeeId': employeeId,
      if (approvalStatus != null) 'approvalStatus': approvalStatus,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CivicUserRoleImpl extends CivicUserRole {
  _CivicUserRoleImpl({
    int? id,
    required String userId,
    String? email,
    String? fullName,
    required String role,
    String? department,
    required bool isActive,
    String? employeeId,
    String? approvalStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         email: email,
         fullName: fullName,
         role: role,
         department: department,
         isActive: isActive,
         employeeId: employeeId,
         approvalStatus: approvalStatus,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CivicUserRole]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CivicUserRole copyWith({
    Object? id = _Undefined,
    String? userId,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    String? role,
    Object? department = _Undefined,
    bool? isActive,
    Object? employeeId = _Undefined,
    Object? approvalStatus = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CivicUserRole(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      email: email is String? ? email : this.email,
      fullName: fullName is String? ? fullName : this.fullName,
      role: role ?? this.role,
      department: department is String? ? department : this.department,
      isActive: isActive ?? this.isActive,
      employeeId: employeeId is String? ? employeeId : this.employeeId,
      approvalStatus: approvalStatus is String?
          ? approvalStatus
          : this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
