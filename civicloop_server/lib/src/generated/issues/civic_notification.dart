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

abstract class CivicNotification
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      isRead: _is.BoolJsonExtension.fromJson(jsonSerialization['isRead']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
    );
  }

  static final t = CivicNotificationTable();

  static const db = CivicNotificationRepository._();

  @override
  int? id;

  String recipientId;

  int issueId;

  String type;

  String title;

  String message;

  bool isRead;

  DateTime createdAt;

  DateTime? readAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CivicNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static CivicNotificationInclude include() {
    return CivicNotificationInclude._();
  }

  static CivicNotificationIncludeList includeList({
    _is.WhereExpressionBuilder<CivicNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicNotificationTable>? orderBy,
    _is.OrderByListBuilder<CivicNotificationTable>? orderByList,
    CivicNotificationInclude? include,
  }) {
    return CivicNotificationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CivicNotification.t),
      orderByList: orderByList?.call(CivicNotification.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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

  /// Returns a shallow copy of this [CivicNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

class CivicNotificationUpdateTable
    extends _is.UpdateTable<CivicNotificationTable> {
  CivicNotificationUpdateTable(super.table);

  _is.ColumnValue<String, String> recipientId(String value) => _is.ColumnValue(
    table.recipientId,
    value,
  );

  _is.ColumnValue<int, int> issueId(int value) => _is.ColumnValue(
    table.issueId,
    value,
  );

  _is.ColumnValue<String, String> type(String value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> message(String value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<bool, bool> isRead(bool value) => _is.ColumnValue(
    table.isRead,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> readAt(DateTime? value) =>
      _is.ColumnValue(
        table.readAt,
        value,
      );
}

class CivicNotificationTable extends _is.Table<int?> {
  CivicNotificationTable({super.tableRelation})
    : super(tableName: 'civic_notification') {
    updateTable = CivicNotificationUpdateTable(this);
    recipientId = _is.ColumnString(
      'recipientId',
      this,
    );
    issueId = _is.ColumnInt(
      'issueId',
      this,
    );
    type = _is.ColumnString(
      'type',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    isRead = _is.ColumnBool(
      'isRead',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    readAt = _is.ColumnDateTime(
      'readAt',
      this,
    );
  }

  late final CivicNotificationUpdateTable updateTable;

  late final _is.ColumnString recipientId;

  late final _is.ColumnInt issueId;

  late final _is.ColumnString type;

  late final _is.ColumnString title;

  late final _is.ColumnString message;

  late final _is.ColumnBool isRead;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime readAt;

  @override
  List<_is.Column> get columns => [
    id,
    recipientId,
    issueId,
    type,
    title,
    message,
    isRead,
    createdAt,
    readAt,
  ];
}

class CivicNotificationInclude extends _is.IncludeObject {
  CivicNotificationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CivicNotification.t;
}

class CivicNotificationIncludeList extends _is.IncludeList {
  CivicNotificationIncludeList._({
    _is.WhereExpressionBuilder<CivicNotificationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CivicNotification.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CivicNotification.t;
}

class CivicNotificationRepository {
  const CivicNotificationRepository._();

  /// Returns a list of [CivicNotification]s matching the given query parameters.
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
  Future<List<CivicNotification>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicNotificationTable>? orderBy,
    _is.OrderByListBuilder<CivicNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CivicNotification>(
      where: where?.call(CivicNotification.t),
      orderBy: orderBy?.call(CivicNotification.t),
      orderByList: orderByList?.call(CivicNotification.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CivicNotification] matching the given query parameters.
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
  Future<CivicNotification?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicNotificationTable>? where,
    int? offset,
    _is.OrderByBuilder<CivicNotificationTable>? orderBy,
    _is.OrderByListBuilder<CivicNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CivicNotification>(
      where: where?.call(CivicNotification.t),
      orderBy: orderBy?.call(CivicNotification.t),
      orderByList: orderByList?.call(CivicNotification.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CivicNotification] by its [id] or null if no such row exists.
  Future<CivicNotification?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CivicNotification>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CivicNotification]s in the list and returns the inserted rows.
  ///
  /// The returned [CivicNotification]s will have their `id` fields set.
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
  Future<List<CivicNotification>> insert(
    _is.DatabaseSession session,
    List<CivicNotification> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CivicNotification>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CivicNotification] and returns the inserted row.
  ///
  /// The returned [CivicNotification] will have its `id` field set.
  Future<CivicNotification> insertRow(
    _is.DatabaseSession session,
    CivicNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CivicNotification>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CivicNotification]s in the list and returns the resulting rows.
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
  /// The returned [CivicNotification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicNotification>> upsert(
    _is.DatabaseSession session,
    List<CivicNotification> rows, {
    required _is.ColumnSelections<CivicNotificationTable> conflictColumns,
    _is.ColumnSelections<CivicNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<CivicNotificationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CivicNotification>(
      rows,
      conflictColumns: conflictColumns(CivicNotification.t),
      updateColumns: updateColumns?.call(CivicNotification.t),
      updateWhere: updateWhere?.call(CivicNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CivicNotification] and returns the resulting row.
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
  /// The returned [CivicNotification] will have its `id` field set.
  Future<CivicNotification?> upsertRow(
    _is.DatabaseSession session,
    CivicNotification row, {
    required _is.ColumnSelections<CivicNotificationTable> conflictColumns,
    _is.ColumnSelections<CivicNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<CivicNotificationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CivicNotification>(
      row,
      conflictColumns: conflictColumns(CivicNotification.t),
      updateColumns: updateColumns?.call(CivicNotification.t),
      updateWhere: updateWhere?.call(CivicNotification.t),
      transaction: transaction,
    );
  }

  /// Updates all [CivicNotification]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicNotification>> update(
    _is.DatabaseSession session,
    List<CivicNotification> rows, {
    _is.ColumnSelections<CivicNotificationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CivicNotification>(
      rows,
      columns: columns?.call(CivicNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CivicNotification]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CivicNotification> updateRow(
    _is.DatabaseSession session,
    CivicNotification row, {
    _is.ColumnSelections<CivicNotificationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CivicNotification>(
      row,
      columns: columns?.call(CivicNotification.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CivicNotification] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CivicNotification?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CivicNotificationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CivicNotification>(
      id,
      columnValues: columnValues(CivicNotification.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CivicNotification]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicNotification>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CivicNotificationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CivicNotificationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicNotificationTable>? orderBy,
    _is.OrderByListBuilder<CivicNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CivicNotification>(
      columnValues: columnValues(CivicNotification.t.updateTable),
      where: where(CivicNotification.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CivicNotification.t),
      orderByList: orderByList?.call(CivicNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CivicNotification]s in the list and returns the deleted rows.
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
  Future<List<CivicNotification>> delete(
    _is.DatabaseSession session,
    List<CivicNotification> rows, {
    _is.OrderByBuilder<CivicNotificationTable>? orderBy,
    _is.OrderByListBuilder<CivicNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CivicNotification>(
      rows,
      orderBy: orderBy?.call(CivicNotification.t),
      orderByList: orderByList?.call(CivicNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CivicNotification].
  Future<CivicNotification> deleteRow(
    _is.DatabaseSession session,
    CivicNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CivicNotification>(
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
  Future<List<CivicNotification>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CivicNotificationTable> where,
    _is.OrderByBuilder<CivicNotificationTable>? orderBy,
    _is.OrderByListBuilder<CivicNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CivicNotification>(
      where: where(CivicNotification.t),
      orderBy: orderBy?.call(CivicNotification.t),
      orderByList: orderByList?.call(CivicNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicNotificationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CivicNotification>(
      where: where?.call(CivicNotification.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CivicNotification] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CivicNotificationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CivicNotification>(
      where: where(CivicNotification.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
