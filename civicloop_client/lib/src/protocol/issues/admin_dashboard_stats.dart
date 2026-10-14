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

abstract class AdminDashboardStats
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminDashboardStats._({
    required this.totalReports,
    required this.openReports,
    required this.assignedReports,
    required this.inProgressReports,
    required this.resolvedReports,
    required this.closedReports,
    required this.reopenedReports,
    required this.rejectedReports,
    required this.overdueReports,
  });

  factory AdminDashboardStats({
    required int totalReports,
    required int openReports,
    required int assignedReports,
    required int inProgressReports,
    required int resolvedReports,
    required int closedReports,
    required int reopenedReports,
    required int rejectedReports,
    required int overdueReports,
  }) = _AdminDashboardStatsImpl;

  factory AdminDashboardStats.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return AdminDashboardStats(
      totalReports: jsonSerialization['totalReports'] as int,
      openReports: jsonSerialization['openReports'] as int,
      assignedReports: jsonSerialization['assignedReports'] as int,
      inProgressReports: jsonSerialization['inProgressReports'] as int,
      resolvedReports: jsonSerialization['resolvedReports'] as int,
      closedReports: jsonSerialization['closedReports'] as int,
      reopenedReports: jsonSerialization['reopenedReports'] as int,
      rejectedReports: jsonSerialization['rejectedReports'] as int,
      overdueReports: jsonSerialization['overdueReports'] as int,
    );
  }

  int totalReports;
  int openReports;
  int assignedReports;
  int inProgressReports;
  int resolvedReports;
  int closedReports;
  int reopenedReports;
  int rejectedReports;
  int overdueReports;

  @_isc.useResult
  AdminDashboardStats copyWith({
    int? totalReports,
    int? openReports,
    int? assignedReports,
    int? inProgressReports,
    int? resolvedReports,
    int? closedReports,
    int? reopenedReports,
    int? rejectedReports,
    int? overdueReports,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDashboardStats',
      'totalReports': totalReports,
      'openReports': openReports,
      'assignedReports': assignedReports,
      'inProgressReports': inProgressReports,
      'resolvedReports': resolvedReports,
      'closedReports': closedReports,
      'reopenedReports': reopenedReports,
      'rejectedReports': rejectedReports,
      'overdueReports': overdueReports,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminDashboardStats',
      'totalReports': totalReports,
      'openReports': openReports,
      'assignedReports': assignedReports,
      'inProgressReports': inProgressReports,
      'resolvedReports': resolvedReports,
      'closedReports': closedReports,
      'reopenedReports': reopenedReports,
      'rejectedReports': rejectedReports,
      'overdueReports': overdueReports,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminDashboardStatsImpl extends AdminDashboardStats {
  _AdminDashboardStatsImpl({
    required int totalReports,
    required int openReports,
    required int assignedReports,
    required int inProgressReports,
    required int resolvedReports,
    required int closedReports,
    required int reopenedReports,
    required int rejectedReports,
    required int overdueReports,
  }) : super._(
          totalReports: totalReports,
          openReports: openReports,
          assignedReports: assignedReports,
          inProgressReports: inProgressReports,
          resolvedReports: resolvedReports,
          closedReports: closedReports,
          reopenedReports: reopenedReports,
          rejectedReports: rejectedReports,
          overdueReports: overdueReports,
        );

  @override
  AdminDashboardStats copyWith({
    int? totalReports,
    int? openReports,
    int? assignedReports,
    int? inProgressReports,
    int? resolvedReports,
    int? closedReports,
    int? reopenedReports,
    int? rejectedReports,
    int? overdueReports,
  }) {
    return AdminDashboardStats(
      totalReports: totalReports ?? this.totalReports,
      openReports: openReports ?? this.openReports,
      assignedReports: assignedReports ?? this.assignedReports,
      inProgressReports: inProgressReports ?? this.inProgressReports,
      resolvedReports: resolvedReports ?? this.resolvedReports,
      closedReports: closedReports ?? this.closedReports,
      reopenedReports: reopenedReports ?? this.reopenedReports,
      rejectedReports: rejectedReports ?? this.rejectedReports,
      overdueReports: overdueReports ?? this.overdueReports,
    );
  }
}
