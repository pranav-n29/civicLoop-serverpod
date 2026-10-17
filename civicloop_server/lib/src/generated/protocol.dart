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
import 'package:civicloop_server/src/generated/auth/staff_user_info.dart'
    as _izhk99zn;
import 'package:civicloop_server/src/generated/issues/civic_issue_audit.dart'
    as _iylxpg2e;
import 'package:civicloop_server/src/generated/issues/civic_notification.dart'
    as _ilvkkzq8;
import 'package:civicloop_server/src/generated/issues/issue.dart' as _i5xq1slo;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
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

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'civic_issue',
      dartName: 'Issue',
      schema: 'public',
      module: 'civicloop',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'category',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'photoPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'priority',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'department',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'assignedEmployeeId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'assignedEmployeeName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'assignedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'dueDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'progressNotes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'completionNotes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'completionPhotoPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'closedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'reopenedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'reopenReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'rejectionReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'rejectedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'claimHash',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'civic_issue_audit',
      dartName: 'CivicIssueAudit',
      schema: 'public',
      module: 'civicloop',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'issueId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'actorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'actorRole',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'actorName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'previousStatus',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'newStatus',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'notes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'timestamp',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'civic_issue_audit_issue_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'issueId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'civic_notification',
      dartName: 'CivicNotification',
      schema: 'public',
      module: 'civicloop',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'recipientId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'issueId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'isRead',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'readAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'civic_notification_recipient_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'civic_user_role',
      dartName: 'CivicUserRole',
      schema: 'public',
      module: 'civicloop',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'email',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'fullName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'department',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'isActive',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'civic_user_role_user_id_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _is.getType<_ihuei1gw.IssueTriageResult?>()) {
      return (data != null ? _ihuei1gw.IssueTriageResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijq17pvt.CivicUserRole?>()) {
      return (data != null ? _ijq17pvt.CivicUserRole.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i43xi6ty.StaffUserInfo?>()) {
      return (data != null ? _i43xi6ty.StaffUserInfo.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icffvvvd.AdminDashboardStats?>()) {
      return (data != null
              ? _icffvvvd.AdminDashboardStats.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i75jwrp9.CivicIssueAudit?>()) {
      return (data != null ? _i75jwrp9.CivicIssueAudit.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9j1n8kk.CivicNotification?>()) {
      return (data != null ? _i9j1n8kk.CivicNotification.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ioojwjex.Issue?>()) {
      return (data != null ? _ioojwjex.Issue.fromJson(data) : null) as T;
    }
    if (t == List<_i5xq1slo.Issue>) {
      return (data as List).map((e) => deserialize<_i5xq1slo.Issue>(e)).toList()
          as T;
    }
    if (t == List<_iylxpg2e.CivicIssueAudit>) {
      return (data as List)
              .map((e) => deserialize<_iylxpg2e.CivicIssueAudit>(e))
              .toList()
          as T;
    }
    if (t == List<_ilvkkzq8.CivicNotification>) {
      return (data as List)
              .map((e) => deserialize<_ilvkkzq8.CivicNotification>(e))
              .toList()
          as T;
    }
    if (t == List<_izhk99zn.StaffUserInfo>) {
      return (data as List)
              .map((e) => deserialize<_izhk99zn.StaffUserInfo>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
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
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('civicloop', this);
    _iacs.Protocol().registerHostProtocol('civicloop', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ijq17pvt.CivicUserRole:
        return _ijq17pvt.CivicUserRole.t;
      case _i75jwrp9.CivicIssueAudit:
        return _i75jwrp9.CivicIssueAudit.t;
      case _i9j1n8kk.CivicNotification:
        return _i9j1n8kk.CivicNotification.t;
      case _ioojwjex.Issue:
        return _ioojwjex.Issue.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
