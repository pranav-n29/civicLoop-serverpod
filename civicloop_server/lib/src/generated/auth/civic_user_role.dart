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

abstract class CivicUserRole
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      isActive: _is.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      employeeId: jsonSerialization['employeeId'] as String?,
      approvalStatus: jsonSerialization['approvalStatus'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CivicUserRoleTable();

  static const db = CivicUserRoleRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CivicUserRole]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static CivicUserRoleInclude include() {
    return CivicUserRoleInclude._();
  }

  static CivicUserRoleIncludeList includeList({
    _is.WhereExpressionBuilder<CivicUserRoleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicUserRoleTable>? orderBy,
    _is.OrderByListBuilder<CivicUserRoleTable>? orderByList,
    CivicUserRoleInclude? include,
  }) {
    return CivicUserRoleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CivicUserRole.t),
      orderByList: orderByList?.call(CivicUserRole.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class CivicUserRoleUpdateTable extends _is.UpdateTable<CivicUserRoleTable> {
  CivicUserRoleUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> email(String? value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<String, String> fullName(String? value) => _is.ColumnValue(
    table.fullName,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<String, String> department(String? value) => _is.ColumnValue(
    table.department,
    value,
  );

  _is.ColumnValue<bool, bool> isActive(bool value) => _is.ColumnValue(
    table.isActive,
    value,
  );

  _is.ColumnValue<String, String> employeeId(String? value) => _is.ColumnValue(
    table.employeeId,
    value,
  );

  _is.ColumnValue<String, String> approvalStatus(String? value) =>
      _is.ColumnValue(
        table.approvalStatus,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CivicUserRoleTable extends _is.Table<int?> {
  CivicUserRoleTable({super.tableRelation})
    : super(tableName: 'civic_user_role') {
    updateTable = CivicUserRoleUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    email = _is.ColumnString(
      'email',
      this,
    );
    fullName = _is.ColumnString(
      'fullName',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
    );
    department = _is.ColumnString(
      'department',
      this,
    );
    isActive = _is.ColumnBool(
      'isActive',
      this,
    );
    employeeId = _is.ColumnString(
      'employeeId',
      this,
    );
    approvalStatus = _is.ColumnString(
      'approvalStatus',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CivicUserRoleUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString email;

  late final _is.ColumnString fullName;

  late final _is.ColumnString role;

  late final _is.ColumnString department;

  late final _is.ColumnBool isActive;

  late final _is.ColumnString employeeId;

  late final _is.ColumnString approvalStatus;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    email,
    fullName,
    role,
    department,
    isActive,
    employeeId,
    approvalStatus,
    createdAt,
    updatedAt,
  ];
}

class CivicUserRoleInclude extends _is.IncludeObject {
  CivicUserRoleInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CivicUserRole.t;
}

class CivicUserRoleIncludeList extends _is.IncludeList {
  CivicUserRoleIncludeList._({
    _is.WhereExpressionBuilder<CivicUserRoleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CivicUserRole.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CivicUserRole.t;
}

class CivicUserRoleRepository {
  const CivicUserRoleRepository._();

  /// Returns a list of [CivicUserRole]s matching the given query parameters.
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
  Future<List<CivicUserRole>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicUserRoleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicUserRoleTable>? orderBy,
    _is.OrderByListBuilder<CivicUserRoleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CivicUserRole>(
      where: where?.call(CivicUserRole.t),
      orderBy: orderBy?.call(CivicUserRole.t),
      orderByList: orderByList?.call(CivicUserRole.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CivicUserRole] matching the given query parameters.
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
  Future<CivicUserRole?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicUserRoleTable>? where,
    int? offset,
    _is.OrderByBuilder<CivicUserRoleTable>? orderBy,
    _is.OrderByListBuilder<CivicUserRoleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CivicUserRole>(
      where: where?.call(CivicUserRole.t),
      orderBy: orderBy?.call(CivicUserRole.t),
      orderByList: orderByList?.call(CivicUserRole.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CivicUserRole] by its [id] or null if no such row exists.
  Future<CivicUserRole?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CivicUserRole>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CivicUserRole]s in the list and returns the inserted rows.
  ///
  /// The returned [CivicUserRole]s will have their `id` fields set.
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
  Future<List<CivicUserRole>> insert(
    _is.DatabaseSession session,
    List<CivicUserRole> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CivicUserRole>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CivicUserRole] and returns the inserted row.
  ///
  /// The returned [CivicUserRole] will have its `id` field set.
  Future<CivicUserRole> insertRow(
    _is.DatabaseSession session,
    CivicUserRole row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CivicUserRole>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CivicUserRole]s in the list and returns the resulting rows.
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
  /// The returned [CivicUserRole]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicUserRole>> upsert(
    _is.DatabaseSession session,
    List<CivicUserRole> rows, {
    required _is.ColumnSelections<CivicUserRoleTable> conflictColumns,
    _is.ColumnSelections<CivicUserRoleTable>? updateColumns,
    _is.WhereExpressionBuilder<CivicUserRoleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CivicUserRole>(
      rows,
      conflictColumns: conflictColumns(CivicUserRole.t),
      updateColumns: updateColumns?.call(CivicUserRole.t),
      updateWhere: updateWhere?.call(CivicUserRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CivicUserRole] and returns the resulting row.
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
  /// The returned [CivicUserRole] will have its `id` field set.
  Future<CivicUserRole?> upsertRow(
    _is.DatabaseSession session,
    CivicUserRole row, {
    required _is.ColumnSelections<CivicUserRoleTable> conflictColumns,
    _is.ColumnSelections<CivicUserRoleTable>? updateColumns,
    _is.WhereExpressionBuilder<CivicUserRoleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CivicUserRole>(
      row,
      conflictColumns: conflictColumns(CivicUserRole.t),
      updateColumns: updateColumns?.call(CivicUserRole.t),
      updateWhere: updateWhere?.call(CivicUserRole.t),
      transaction: transaction,
    );
  }

  /// Updates all [CivicUserRole]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicUserRole>> update(
    _is.DatabaseSession session,
    List<CivicUserRole> rows, {
    _is.ColumnSelections<CivicUserRoleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CivicUserRole>(
      rows,
      columns: columns?.call(CivicUserRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CivicUserRole]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CivicUserRole> updateRow(
    _is.DatabaseSession session,
    CivicUserRole row, {
    _is.ColumnSelections<CivicUserRoleTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CivicUserRole>(
      row,
      columns: columns?.call(CivicUserRole.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CivicUserRole] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CivicUserRole?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CivicUserRoleUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CivicUserRole>(
      id,
      columnValues: columnValues(CivicUserRole.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CivicUserRole]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CivicUserRole>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CivicUserRoleUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CivicUserRoleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CivicUserRoleTable>? orderBy,
    _is.OrderByListBuilder<CivicUserRoleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CivicUserRole>(
      columnValues: columnValues(CivicUserRole.t.updateTable),
      where: where(CivicUserRole.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CivicUserRole.t),
      orderByList: orderByList?.call(CivicUserRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CivicUserRole]s in the list and returns the deleted rows.
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
  Future<List<CivicUserRole>> delete(
    _is.DatabaseSession session,
    List<CivicUserRole> rows, {
    _is.OrderByBuilder<CivicUserRoleTable>? orderBy,
    _is.OrderByListBuilder<CivicUserRoleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CivicUserRole>(
      rows,
      orderBy: orderBy?.call(CivicUserRole.t),
      orderByList: orderByList?.call(CivicUserRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CivicUserRole].
  Future<CivicUserRole> deleteRow(
    _is.DatabaseSession session,
    CivicUserRole row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CivicUserRole>(
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
  Future<List<CivicUserRole>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CivicUserRoleTable> where,
    _is.OrderByBuilder<CivicUserRoleTable>? orderBy,
    _is.OrderByListBuilder<CivicUserRoleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CivicUserRole>(
      where: where(CivicUserRole.t),
      orderBy: orderBy?.call(CivicUserRole.t),
      orderByList: orderByList?.call(CivicUserRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CivicUserRoleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CivicUserRole>(
      where: where?.call(CivicUserRole.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CivicUserRole] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CivicUserRoleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CivicUserRole>(
      where: where(CivicUserRole.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
