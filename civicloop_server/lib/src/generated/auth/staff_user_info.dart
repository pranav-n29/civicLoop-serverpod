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

abstract class StaffUserInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  StaffUserInfo._({
    required this.userId,
    this.email,
    this.fullName,
    required this.role,
    this.department,
    required this.isActive,
    required this.activeAssignedCasesCount,
  });

  factory StaffUserInfo({
    required String userId,
    String? email,
    String? fullName,
    required String role,
    String? department,
    required bool isActive,
    required int activeAssignedCasesCount,
  }) = _StaffUserInfoImpl;

  factory StaffUserInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffUserInfo(
      userId: jsonSerialization['userId'] as String,
      email: jsonSerialization['email'] as String?,
      fullName: jsonSerialization['fullName'] as String?,
      role: jsonSerialization['role'] as String,
      department: jsonSerialization['department'] as String?,
      isActive: jsonSerialization['isActive'] as bool,
      activeAssignedCasesCount:
          jsonSerialization['activeAssignedCasesCount'] as int,
    );
  }

  String userId;
  String? email;
  String? fullName;
  String role;
  String? department;
  bool isActive;
  int activeAssignedCasesCount;

  @_is.useResult
  StaffUserInfo copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? role,
    String? department,
    bool? isActive,
    int? activeAssignedCasesCount,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StaffUserInfo',
      'userId': userId,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      if (department != null) 'department': department,
      'isActive': isActive,
      'activeAssignedCasesCount': activeAssignedCasesCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StaffUserInfo',
      'userId': userId,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      if (department != null) 'department': department,
      'isActive': isActive,
      'activeAssignedCasesCount': activeAssignedCasesCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StaffUserInfoImpl extends StaffUserInfo {
  _StaffUserInfoImpl({
    required String userId,
    String? email,
    String? fullName,
    required String role,
    String? department,
    required bool isActive,
    required int activeAssignedCasesCount,
  }) : super._(
          userId: userId,
          email: email,
          fullName: fullName,
          role: role,
          department: department,
          isActive: isActive,
          activeAssignedCasesCount: activeAssignedCasesCount,
        );

  @override
  StaffUserInfo copyWith({
    String? userId,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    String? role,
    Object? department = _Undefined,
    bool? isActive,
    int? activeAssignedCasesCount,
  }) {
    return StaffUserInfo(
      userId: userId ?? this.userId,
      email: email is String? ? email : this.email,
      fullName: fullName is String? ? fullName : this.fullName,
      role: role ?? this.role,
      department: department is String? ? department : this.department,
      isActive: isActive ?? this.isActive,
      activeAssignedCasesCount:
          activeAssignedCasesCount ?? this.activeAssignedCasesCount,
    );
  }
}
