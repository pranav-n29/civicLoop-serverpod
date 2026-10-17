/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:civicloop_client/src/protocol/auth/staff_user_info.dart'
    as _ilwxnka6;
import 'package:civicloop_client/src/protocol/issues/civic_issue_audit.dart'
    as _isquhekr;
import 'package:civicloop_client/src/protocol/issues/civic_notification.dart'
    as _i5n288wg;
import 'package:civicloop_client/src/protocol/issues/issue.dart' as _i3nh278b;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'ai/issue_triage_result.dart' as _ihuei1gw;
import 'auth/civic_user_role.dart' as _ijq17pvt;
import 'auth/staff_user_info.dart' as _i43xi6ty;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'issues/admin_dashboard_stats.dart' as _icffvvvd;
import 'issues/civic_issue_audit.dart' as _i75jwrp9;
import 'issues/civic_notification.dart' as _i9j1n8kk;
import 'issues/issue.dart' as _ioojwjex;
export 'ai/issue_triage_result.dart';
export 'auth/civic_user_role.dart';
export 'auth/staff_user_info.dart';
export 'greetings/greeting.dart';
export 'issues/admin_dashboard_stats.dart';
export 'issues/civic_issue_audit.dart';
export 'issues/civic_notification.dart';
export 'issues/issue.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ihuei1gw.IssueTriageResult) {
      return _ihuei1gw.IssueTriageResult.fromJson(data) as T;
    }
    if (t == _ijq17pvt.CivicUserRole) {
      return _ijq17pvt.CivicUserRole.fromJson(data) as T;
    }
    if (t == _i43xi6ty.StaffUserInfo) {
      return _i43xi6ty.StaffUserInfo.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _icffvvvd.AdminDashboardStats) {
      return _icffvvvd.AdminDashboardStats.fromJson(data) as T;
    }
    if (t == _i75jwrp9.CivicIssueAudit) {
      return _i75jwrp9.CivicIssueAudit.fromJson(data) as T;
    }
    if (t == _i9j1n8kk.CivicNotification) {
      return _i9j1n8kk.CivicNotification.fromJson(data) as T;
    }
    if (t == _ioojwjex.Issue) {
      return _ioojwjex.Issue.fromJson(data) as T;
    }
    if (t == _isc.getType<_ihuei1gw.IssueTriageResult?>()) {
      return (data != null ? _ihuei1gw.IssueTriageResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ijq17pvt.CivicUserRole?>()) {
      return (data != null ? _ijq17pvt.CivicUserRole.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i43xi6ty.StaffUserInfo?>()) {
      return (data != null ? _i43xi6ty.StaffUserInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_icffvvvd.AdminDashboardStats?>()) {
      return (data != null
              ? _icffvvvd.AdminDashboardStats.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i75jwrp9.CivicIssueAudit?>()) {
      return (data != null ? _i75jwrp9.CivicIssueAudit.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9j1n8kk.CivicNotification?>()) {
      return (data != null ? _i9j1n8kk.CivicNotification.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ioojwjex.Issue?>()) {
      return (data != null ? _ioojwjex.Issue.fromJson(data) : null) as T;
    }
    if (t == List<_i3nh278b.Issue>) {
      return (data as List).map((e) => deserialize<_i3nh278b.Issue>(e)).toList()
          as T;
    }
    if (t == List<_isquhekr.CivicIssueAudit>) {
      return (data as List)
              .map((e) => deserialize<_isquhekr.CivicIssueAudit>(e))
              .toList()
          as T;
    }
    if (t == List<_i5n288wg.CivicNotification>) {
      return (data as List)
              .map((e) => deserialize<_i5n288wg.CivicNotification>(e))
              .toList()
          as T;
    }
    if (t == List<_ilwxnka6.StaffUserInfo>) {
      return (data as List)
              .map((e) => deserialize<_ilwxnka6.StaffUserInfo>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ihuei1gw.IssueTriageResult => 'IssueTriageResult',
      _ijq17pvt.CivicUserRole => 'CivicUserRole',
      _i43xi6ty.StaffUserInfo => 'StaffUserInfo',
      _izw8z7ou.Greeting => 'Greeting',
      _icffvvvd.AdminDashboardStats => 'AdminDashboardStats',
      _i75jwrp9.CivicIssueAudit => 'CivicIssueAudit',
      _i9j1n8kk.CivicNotification => 'CivicNotification',
      _ioojwjex.Issue => 'Issue',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('civicloop.', '');
    }

    switch (data) {
      case _ihuei1gw.IssueTriageResult():
        return 'IssueTriageResult';
      case _ijq17pvt.CivicUserRole():
        return 'CivicUserRole';
      case _i43xi6ty.StaffUserInfo():
        return 'StaffUserInfo';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _icffvvvd.AdminDashboardStats():
        return 'AdminDashboardStats';
      case _i75jwrp9.CivicIssueAudit():
        return 'CivicIssueAudit';
      case _i9j1n8kk.CivicNotification():
        return 'CivicNotification';
      case _ioojwjex.Issue():
        return 'Issue';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'IssueTriageResult') {
      return deserialize<_ihuei1gw.IssueTriageResult>(data['data']);
    }
    if (dataClassName == 'CivicUserRole') {
      return deserialize<_ijq17pvt.CivicUserRole>(data['data']);
    }
    if (dataClassName == 'StaffUserInfo') {
      return deserialize<_i43xi6ty.StaffUserInfo>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'AdminDashboardStats') {
      return deserialize<_icffvvvd.AdminDashboardStats>(data['data']);
    }
    if (dataClassName == 'CivicIssueAudit') {
      return deserialize<_i75jwrp9.CivicIssueAudit>(data['data']);
    }
    if (dataClassName == 'CivicNotification') {
      return deserialize<_i9j1n8kk.CivicNotification>(data['data']);
    }
    if (dataClassName == 'Issue') {
      return deserialize<_ioojwjex.Issue>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('civicloop', this);
    _iacc.Protocol().registerHostProtocol('civicloop', this);
  }

  @override
  String getModuleName() => 'civicloop';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
