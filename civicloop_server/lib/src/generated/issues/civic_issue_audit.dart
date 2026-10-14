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

abstract class CivicIssueAudit
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      timestamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  static final t = CivicIssueAuditTable();

  static const db = CivicIssueAuditRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  @_is.useResult
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

  static CivicIssueAuditInclude include() {
    return CivicIssueAuditInclude._();
  }

  static CivicIssueAuditIncludeList includeList({
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicIssueAuditTable>? orderBy,
    _is.OrderByListBuilder<CivicIssueAuditTable>? orderByList,
    CivicIssueAuditInclude? include,
  }) {
    return CivicIssueAuditIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CivicIssueAudit.t),
      orderByList: orderByList?.call(CivicIssueAudit.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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

class CivicIssueAuditUpdateTable
    extends _is.UpdateTable<CivicIssueAuditTable> {
  CivicIssueAuditUpdateTable(super.table);

  _is.ColumnValue<int, int> issueId(int value) => _is.ColumnValue(
        table.issueId,
        value,
      );

  _is.ColumnValue<String, String> actorId(String value) => _is.ColumnValue(
        table.actorId,
        value,
      );

  _is.ColumnValue<String, String> actorRole(String value) => _is.ColumnValue(
        table.actorRole,
        value,
      );

  _is.ColumnValue<String, String> actorName(String? value) => _is.ColumnValue(
        table.actorName,
        value,
      );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
        table.action,
        value,
      );

  _is.ColumnValue<String, String> previousStatus(String? value) =>
      _is.ColumnValue(
        table.previousStatus,
        value,
      );

  _is.ColumnValue<String, String> newStatus(String? value) => _is.ColumnValue(
        table.newStatus,
        value,
      );

  _is.ColumnValue<String, String> notes(String? value) => _is.ColumnValue(
        table.notes,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _is.ColumnValue(
        table.timestamp,
        value,
      );
}

class CivicIssueAuditTable extends _is.Table<int?> {
  CivicIssueAuditTable({super.tableRelation})
      : super(tableName: 'civic_issue_audit') {
    updateTable = CivicIssueAuditUpdateTable(this);
    issueId = _is.ColumnInt('issueId', this);
    actorId = _is.ColumnString('actorId', this);
    actorRole = _is.ColumnString('actorRole', this);
    actorName = _is.ColumnString('actorName', this);
    action = _is.ColumnString('action', this);
    previousStatus = _is.ColumnString('previousStatus', this);
    newStatus = _is.ColumnString('newStatus', this);
    notes = _is.ColumnString('notes', this);
    timestamp = _is.ColumnDateTime('timestamp', this);
  }

  late final CivicIssueAuditUpdateTable updateTable;

  late final _is.ColumnInt issueId;
  late final _is.ColumnString actorId;
  late final _is.ColumnString actorRole;
  late final _is.ColumnString actorName;
  late final _is.ColumnString action;
  late final _is.ColumnString previousStatus;
  late final _is.ColumnString newStatus;
  late final _is.ColumnString notes;
  late final _is.ColumnDateTime timestamp;

  @override
  List<_is.Column> get columns => [
        id,
        issueId,
        actorId,
        actorRole,
        actorName,
        action,
        previousStatus,
        newStatus,
        notes,
        timestamp,
      ];
}

class CivicIssueAuditInclude extends _is.IncludeObject {
  CivicIssueAuditInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CivicIssueAudit.t;
}

class CivicIssueAuditIncludeList extends _is.IncludeList {
  CivicIssueAuditIncludeList._({
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CivicIssueAudit.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CivicIssueAudit.t;
}

class CivicIssueAuditRepository {
  const CivicIssueAuditRepository._();

  Future<List<CivicIssueAudit>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicIssueAuditTable>? orderBy,
    _is.OrderByListBuilder<CivicIssueAuditTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CivicIssueAudit>(
      where: where?.call(CivicIssueAudit.t),
      orderBy: orderBy?.call(CivicIssueAudit.t),
      orderByList: orderByList?.call(CivicIssueAudit.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  Future<CivicIssueAudit> insertRow(
    _is.DatabaseSession session,
    CivicIssueAudit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CivicIssueAudit>(
      row,
      transaction: transaction,
    );
  }
}
