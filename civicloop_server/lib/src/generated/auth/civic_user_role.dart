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
      isActive: jsonSerialization['isActive'] as bool,
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

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  @_is.useResult
  CivicUserRole copyWith({
    int? id,
    String? userId,
    String? email,
    String? fullName,
    String? role,
    String? department,
    bool? isActive,
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
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  CivicUserRole copyWith({
    Object? id = _Undefined,
    String? userId,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    String? role,
    Object? department = _Undefined,
    bool? isActive,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CivicUserRoleUpdateTable
    extends _is.UpdateTable<CivicUserRoleTable> {
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
    userId = _is.ColumnString('userId', this);
    email = _is.ColumnString('email', this);
    fullName = _is.ColumnString('fullName', this);
    role = _is.ColumnString('role', this);
    department = _is.ColumnString('department', this);
    isActive = _is.ColumnBool('isActive', this);
    createdAt = _is.ColumnDateTime('createdAt', this);
    updatedAt = _is.ColumnDateTime('updatedAt', this);
  }

  late final CivicUserRoleUpdateTable updateTable;

  late final _is.ColumnString userId;
  late final _is.ColumnString email;
  late final _is.ColumnString fullName;
  late final _is.ColumnString role;
  late final _is.ColumnString department;
  late final _is.ColumnBool isActive;
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
}
