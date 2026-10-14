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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import 'ai/issue_triage_result.dart' as _ihuei1gw;
import 'auth/civic_user_role.dart' as _icur;
import 'auth/staff_user_info.dart' as _isui;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'issues/admin_dashboard_stats.dart' as _iads;
import 'issues/civic_issue_audit.dart' as _icia;
import 'issues/civic_notification.dart' as _icin;
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
      } on _is.DeserializationClassNameNotFoundException catch (_) {}
    }

    if (t == _ihuei1gw.IssueTriageResult) {
      return _ihuei1gw.IssueTriageResult.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ioojwjex.Issue) {
      return _ioojwjex.Issue.fromJson(data) as T;
    }
    if (t == _icur.CivicUserRole) {
      return _icur.CivicUserRole.fromJson(data) as T;
    }
    if (t == _icia.CivicIssueAudit) {
      return _icia.CivicIssueAudit.fromJson(data) as T;
    }
    if (t == _icin.CivicNotification) {
      return _icin.CivicNotification.fromJson(data) as T;
    }
    if (t == _iads.AdminDashboardStats) {
      return _iads.AdminDashboardStats.fromJson(data) as T;
    }
    if (t == _isui.StaffUserInfo) {
      return _isui.StaffUserInfo.fromJson(data) as T;
    }

    if (t == _is.getType<_ihuei1gw.IssueTriageResult?>()) {
      return (data != null ? _ihuei1gw.IssueTriageResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ioojwjex.Issue?>()) {
      return (data != null ? _ioojwjex.Issue.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icur.CivicUserRole?>()) {
      return (data != null ? _icur.CivicUserRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icia.CivicIssueAudit?>()) {
      return (data != null ? _icia.CivicIssueAudit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icin.CivicNotification?>()) {
      return (data != null ? _icin.CivicNotification.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iads.AdminDashboardStats?>()) {
      return (data != null ? _iads.AdminDashboardStats.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isui.StaffUserInfo?>()) {
      return (data != null ? _isui.StaffUserInfo.fromJson(data) : null) as T;
    }

    if (t == List<_ioojwjex.Issue>) {
      return (data as List).map((e) => deserialize<_ioojwjex.Issue>(e)).toList()
          as T;
    }
    if (t == List<_icur.CivicUserRole>) {
      return (data as List)
          .map((e) => deserialize<_icur.CivicUserRole>(e))
          .toList() as T;
    }
    if (t == List<_icia.CivicIssueAudit>) {
      return (data as List)
          .map((e) => deserialize<_icia.CivicIssueAudit>(e))
          .toList() as T;
    }
    if (t == List<_icin.CivicNotification>) {
      return (data as List)
          .map((e) => deserialize<_icin.CivicNotification>(e))
          .toList() as T;
    }
    if (t == List<_isui.StaffUserInfo>) {
      return (data as List)
          .map((e) => deserialize<_isui.StaffUserInfo>(e))
          .toList() as T;
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
      _izw8z7ou.Greeting => 'Greeting',
      _ioojwjex.Issue => 'Issue',
      _icur.CivicUserRole => 'CivicUserRole',
      _icia.CivicIssueAudit => 'CivicIssueAudit',
      _icin.CivicNotification => 'CivicNotification',
      _iads.AdminDashboardStats => 'AdminDashboardStats',
      _isui.StaffUserInfo => 'StaffUserInfo',
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
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ioojwjex.Issue():
        return 'Issue';
      case _icur.CivicUserRole():
        return 'CivicUserRole';
      case _icia.CivicIssueAudit():
        return 'CivicIssueAudit';
      case _icin.CivicNotification():
        return 'CivicNotification';
      case _iads.AdminDashboardStats():
        return 'AdminDashboardStats';
      case _isui.StaffUserInfo():
        return 'StaffUserInfo';
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
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'Issue') {
      return deserialize<_ioojwjex.Issue>(data['data']);
    }
    if (dataClassName == 'CivicUserRole') {
      return deserialize<_icur.CivicUserRole>(data['data']);
    }
    if (dataClassName == 'CivicIssueAudit') {
      return deserialize<_icia.CivicIssueAudit>(data['data']);
    }
    if (dataClassName == 'CivicNotification') {
      return deserialize<_icin.CivicNotification>(data['data']);
    }
    if (dataClassName == 'AdminDashboardStats') {
      return deserialize<_iads.AdminDashboardStats>(data['data']);
    }
    if (dataClassName == 'StaffUserInfo') {
      return deserialize<_isui.StaffUserInfo>(data['data']);
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
      case _ioojwjex.Issue:
        return _ioojwjex.Issue.t;
      case _icur.CivicUserRole:
        return _icur.CivicUserRole.t;
      case _icia.CivicIssueAudit:
        return _icia.CivicIssueAudit.t;
      case _icin.CivicNotification:
        return _icin.CivicNotification.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'civicloop';

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
