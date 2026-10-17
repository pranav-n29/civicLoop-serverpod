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

  /// Returns a shallow copy of this [CivicIssueAudit]
  /// with some or all fields replaced by the given arguments.
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

  /// Returns a shallow copy of this [CivicIssueAudit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
      previousStatus: previousStatus is String?
          ? previousStatus
          : this.previousStatus,
      newStatus: newStatus is String? ? newStatus : this.newStatus,
      notes: notes is String? ? notes : this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class CivicIssueAuditUpdateTable extends _is.UpdateTable<CivicIssueAuditTable> {
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
    issueId = _is.ColumnInt(
      'issueId',
      this,
    );
    actorId = _is.ColumnString(
      'actorId',
      this,
    );
    actorRole = _is.ColumnString(
      'actorRole',
      this,
    );
    actorName = _is.ColumnString(
      'actorName',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    previousStatus = _is.ColumnString(
      'previousStatus',
      this,
    );
    newStatus = _is.ColumnString(
      'newStatus',
      this,
    );
    notes = _is.ColumnString(
      'notes',
      this,
    );
    timestamp = _is.ColumnDateTime(
      'timestamp',
      this,
    );
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

  /// Returns a list of [CivicIssueAudit]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
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

  /// Returns the first matching [CivicIssueAudit] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<CivicIssueAudit?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? where,
    int? offset,
    _is.OrderByBuilder<CivicIssueAuditTable>? orderBy,
    _is.OrderByListBuilder<CivicIssueAuditTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CivicIssueAudit>(
      where: where?.call(CivicIssueAudit.t),
      orderBy: orderBy?.call(CivicIssueAudit.t),
      orderByList: orderByList?.call(CivicIssueAudit.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CivicIssueAudit] by its [id] or null if no such row exists.
  Future<CivicIssueAudit?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CivicIssueAudit>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CivicIssueAudit]s in the list and returns the inserted rows.
  ///
  /// The returned [CivicIssueAudit]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicIssueAudit>> insert(
    _is.DatabaseSession session,
    List<CivicIssueAudit> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CivicIssueAudit>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CivicIssueAudit] and returns the inserted row.
  ///
  /// The returned [CivicIssueAudit] will have its `id` field set.
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

  /// Upserts all [CivicIssueAudit]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [CivicIssueAudit]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicIssueAudit>> upsert(
    _is.DatabaseSession session,
    List<CivicIssueAudit> rows, {
    required _is.ColumnSelections<CivicIssueAuditTable> conflictColumns,
    _is.ColumnSelections<CivicIssueAuditTable>? updateColumns,
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CivicIssueAudit>(
      rows,
      conflictColumns: conflictColumns(CivicIssueAudit.t),
      updateColumns: updateColumns?.call(CivicIssueAudit.t),
      updateWhere: updateWhere?.call(CivicIssueAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CivicIssueAudit] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [CivicIssueAudit] will have its `id` field set.
  Future<CivicIssueAudit?> upsertRow(
    _is.DatabaseSession session,
    CivicIssueAudit row, {
    required _is.ColumnSelections<CivicIssueAuditTable> conflictColumns,
    _is.ColumnSelections<CivicIssueAuditTable>? updateColumns,
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CivicIssueAudit>(
      row,
      conflictColumns: conflictColumns(CivicIssueAudit.t),
      updateColumns: updateColumns?.call(CivicIssueAudit.t),
      updateWhere: updateWhere?.call(CivicIssueAudit.t),
      transaction: transaction,
    );
  }

  /// Updates all [CivicIssueAudit]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicIssueAudit>> update(
    _is.DatabaseSession session,
    List<CivicIssueAudit> rows, {
    _is.ColumnSelections<CivicIssueAuditTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CivicIssueAudit>(
      rows,
      columns: columns?.call(CivicIssueAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CivicIssueAudit]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CivicIssueAudit> updateRow(
    _is.DatabaseSession session,
    CivicIssueAudit row, {
    _is.ColumnSelections<CivicIssueAuditTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CivicIssueAudit>(
      row,
      columns: columns?.call(CivicIssueAudit.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CivicIssueAudit] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CivicIssueAudit?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CivicIssueAuditUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CivicIssueAudit>(
      id,
      columnValues: columnValues(CivicIssueAudit.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CivicIssueAudit]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicIssueAudit>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CivicIssueAuditUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CivicIssueAuditTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicIssueAuditTable>? orderBy,
    _is.OrderByListBuilder<CivicIssueAuditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CivicIssueAudit>(
      columnValues: columnValues(CivicIssueAudit.t.updateTable),
      where: where(CivicIssueAudit.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CivicIssueAudit.t),
      orderByList: orderByList?.call(CivicIssueAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CivicIssueAudit]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicIssueAudit>> delete(
    _is.DatabaseSession session,
    List<CivicIssueAudit> rows, {
    _is.OrderByBuilder<CivicIssueAuditTable>? orderBy,
    _is.OrderByListBuilder<CivicIssueAuditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CivicIssueAudit>(
      rows,
      orderBy: orderBy?.call(CivicIssueAudit.t),
      orderByList: orderByList?.call(CivicIssueAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CivicIssueAudit].
  Future<CivicIssueAudit> deleteRow(
    _is.DatabaseSession session,
    CivicIssueAudit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CivicIssueAudit>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicIssueAudit>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CivicIssueAuditTable> where,
    _is.OrderByBuilder<CivicIssueAuditTable>? orderBy,
    _is.OrderByListBuilder<CivicIssueAuditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CivicIssueAudit>(
      where: where(CivicIssueAudit.t),
      orderBy: orderBy?.call(CivicIssueAudit.t),
      orderByList: orderByList?.call(CivicIssueAudit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicIssueAuditTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CivicIssueAudit>(
      where: where?.call(CivicIssueAudit.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CivicIssueAudit] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CivicIssueAuditTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CivicIssueAudit>(
      where: where(CivicIssueAudit.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
