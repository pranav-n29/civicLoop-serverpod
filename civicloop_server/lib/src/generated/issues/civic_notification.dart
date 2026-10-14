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
      isRead: jsonSerialization['isRead'] as bool,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['readAt'],
            ),
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
    recipientId = _is.ColumnString('recipientId', this);
    issueId = _is.ColumnInt('issueId', this);
    type = _is.ColumnString('type', this);
    title = _is.ColumnString('title', this);
    message = _is.ColumnString('message', this);
    isRead = _is.ColumnBool('isRead', this);
    createdAt = _is.ColumnDateTime('createdAt', this);
    readAt = _is.ColumnDateTime('readAt', this);
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
}
