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

abstract class Issue implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Issue._({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.userId,
    this.photoPath,
    this.priority,
    this.department,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.assignedAt,
    this.dueDate,
    this.progressNotes,
    this.completionNotes,
    this.completionPhotoPath,
    this.resolvedAt,
    this.closedAt,
    this.reopenedAt,
    this.reopenReason,
    this.rejectionReason,
    this.rejectedAt,
    this.claimHash,
    this.claimToken,
    this.uploadToken,
  });

  factory Issue({
    int? id,
    required String title,
    required String description,
    required String category,
    required String status,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
    String? userId,
    String? photoPath,
    String? priority,
    String? department,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    DateTime? assignedAt,
    DateTime? dueDate,
    String? progressNotes,
    String? completionNotes,
    String? completionPhotoPath,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    String? reopenReason,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? claimHash,
    String? claimToken,
    String? uploadToken,
  }) = _IssueImpl;

  factory Issue.fromJson(Map<String, dynamic> jsonSerialization) {
    return Issue(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      category: jsonSerialization['category'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      userId: jsonSerialization['userId'] as String?,
      photoPath: jsonSerialization['photoPath'] as String?,
      priority: jsonSerialization['priority'] as String?,
      department: jsonSerialization['department'] as String?,
      assignedEmployeeId: jsonSerialization['assignedEmployeeId'] as String?,
      assignedEmployeeName:
          jsonSerialization['assignedEmployeeName'] as String?,
      assignedAt: jsonSerialization['assignedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['assignedAt']),
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      progressNotes: jsonSerialization['progressNotes'] as String?,
      completionNotes: jsonSerialization['completionNotes'] as String?,
      completionPhotoPath: jsonSerialization['completionPhotoPath'] as String?,
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
      reopenedAt: jsonSerialization['reopenedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['reopenedAt']),
      reopenReason: jsonSerialization['reopenReason'] as String?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
      rejectedAt: jsonSerialization['rejectedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['rejectedAt']),
      claimHash: jsonSerialization['claimHash'] as String?,
      claimToken: jsonSerialization['claimToken'] as String?,
      uploadToken: jsonSerialization['uploadToken'] as String?,
    );
  }

  static final t = IssueTable();

  static const db = IssueRepository._();

  @override
  int? id;

  String title;

  String description;

  String category;

  String status;

  DateTime createdAt;

  double? latitude;

  double? longitude;

  String? userId;

  String? photoPath;

  String? priority;

  String? department;

  String? assignedEmployeeId;

  String? assignedEmployeeName;

  DateTime? assignedAt;

  DateTime? dueDate;

  String? progressNotes;

  String? completionNotes;

  String? completionPhotoPath;

  DateTime? resolvedAt;

  DateTime? closedAt;

  DateTime? reopenedAt;

  String? reopenReason;

  String? rejectionReason;

  DateTime? rejectedAt;

  String? claimHash;

  String? claimToken;

  String? uploadToken;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Issue]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Issue copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? userId,
    String? photoPath,
    String? priority,
    String? department,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    DateTime? assignedAt,
    DateTime? dueDate,
    String? progressNotes,
    String? completionNotes,
    String? completionPhotoPath,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    String? reopenReason,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? claimHash,
    String? claimToken,
    String? uploadToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Issue',
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt.toJson(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (userId != null) 'userId': userId,
      if (photoPath != null) 'photoPath': photoPath,
      if (priority != null) 'priority': priority,
      if (department != null) 'department': department,
      if (assignedEmployeeId != null) 'assignedEmployeeId': assignedEmployeeId,
      if (assignedEmployeeName != null)
        'assignedEmployeeName': assignedEmployeeName,
      if (assignedAt != null) 'assignedAt': assignedAt?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      if (progressNotes != null) 'progressNotes': progressNotes,
      if (completionNotes != null) 'completionNotes': completionNotes,
      if (completionPhotoPath != null)
        'completionPhotoPath': completionPhotoPath,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (reopenedAt != null) 'reopenedAt': reopenedAt?.toJson(),
      if (reopenReason != null) 'reopenReason': reopenReason,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (rejectedAt != null) 'rejectedAt': rejectedAt?.toJson(),
      if (claimHash != null) 'claimHash': claimHash,
      if (claimToken != null) 'claimToken': claimToken,
      if (uploadToken != null) 'uploadToken': uploadToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Issue',
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': createdAt.toJson(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (userId != null) 'userId': userId,
      if (photoPath != null) 'photoPath': photoPath,
      if (priority != null) 'priority': priority,
      if (department != null) 'department': department,
      if (assignedEmployeeId != null) 'assignedEmployeeId': assignedEmployeeId,
      if (assignedEmployeeName != null)
        'assignedEmployeeName': assignedEmployeeName,
      if (assignedAt != null) 'assignedAt': assignedAt?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      if (progressNotes != null) 'progressNotes': progressNotes,
      if (completionNotes != null) 'completionNotes': completionNotes,
      if (completionPhotoPath != null)
        'completionPhotoPath': completionPhotoPath,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (reopenedAt != null) 'reopenedAt': reopenedAt?.toJson(),
      if (reopenReason != null) 'reopenReason': reopenReason,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (rejectedAt != null) 'rejectedAt': rejectedAt?.toJson(),
      if (claimHash != null) 'claimHash': claimHash,
      if (claimToken != null) 'claimToken': claimToken,
      if (uploadToken != null) 'uploadToken': uploadToken,
    };
  }

  static IssueInclude include() {
    return IssueInclude._();
  }

  static IssueIncludeList includeList({
    _is.WhereExpressionBuilder<IssueTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IssueTable>? orderBy,
    _is.OrderByListBuilder<IssueTable>? orderByList,
    IssueInclude? include,
  }) {
    return IssueIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Issue.t),
      orderByList: orderByList?.call(Issue.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IssueImpl extends Issue {
  _IssueImpl({
    int? id,
    required String title,
    required String description,
    required String category,
    required String status,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
    String? userId,
    String? photoPath,
    String? priority,
    String? department,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    DateTime? assignedAt,
    DateTime? dueDate,
    String? progressNotes,
    String? completionNotes,
    String? completionPhotoPath,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenedAt,
    String? reopenReason,
    String? rejectionReason,
    DateTime? rejectedAt,
    String? claimHash,
    String? claimToken,
    String? uploadToken,
  }) : super._(
         id: id,
         title: title,
         description: description,
         category: category,
         status: status,
         createdAt: createdAt,
         latitude: latitude,
         longitude: longitude,
         userId: userId,
         photoPath: photoPath,
         priority: priority,
         department: department,
         assignedEmployeeId: assignedEmployeeId,
         assignedEmployeeName: assignedEmployeeName,
         assignedAt: assignedAt,
         dueDate: dueDate,
         progressNotes: progressNotes,
         completionNotes: completionNotes,
         completionPhotoPath: completionPhotoPath,
         resolvedAt: resolvedAt,
         closedAt: closedAt,
         reopenedAt: reopenedAt,
         reopenReason: reopenReason,
         rejectionReason: rejectionReason,
         rejectedAt: rejectedAt,
         claimHash: claimHash,
         claimToken: claimToken,
         uploadToken: uploadToken,
       );

  /// Returns a shallow copy of this [Issue]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Issue copyWith({
    Object? id = _Undefined,
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? createdAt,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    Object? userId = _Undefined,
    Object? photoPath = _Undefined,
    Object? priority = _Undefined,
    Object? department = _Undefined,
    Object? assignedEmployeeId = _Undefined,
    Object? assignedEmployeeName = _Undefined,
    Object? assignedAt = _Undefined,
    Object? dueDate = _Undefined,
    Object? progressNotes = _Undefined,
    Object? completionNotes = _Undefined,
    Object? completionPhotoPath = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? closedAt = _Undefined,
    Object? reopenedAt = _Undefined,
    Object? reopenReason = _Undefined,
    Object? rejectionReason = _Undefined,
    Object? rejectedAt = _Undefined,
    Object? claimHash = _Undefined,
    Object? claimToken = _Undefined,
    Object? uploadToken = _Undefined,
  }) {
    return Issue(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      userId: userId is String? ? userId : this.userId,
      photoPath: photoPath is String? ? photoPath : this.photoPath,
      priority: priority is String? ? priority : this.priority,
      department: department is String? ? department : this.department,
      assignedEmployeeId: assignedEmployeeId is String?
          ? assignedEmployeeId
          : this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName is String?
          ? assignedEmployeeName
          : this.assignedEmployeeName,
      assignedAt: assignedAt is DateTime? ? assignedAt : this.assignedAt,
      dueDate: dueDate is DateTime? ? dueDate : this.dueDate,
      progressNotes: progressNotes is String?
          ? progressNotes
          : this.progressNotes,
      completionNotes: completionNotes is String?
          ? completionNotes
          : this.completionNotes,
      completionPhotoPath: completionPhotoPath is String?
          ? completionPhotoPath
          : this.completionPhotoPath,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      closedAt: closedAt is DateTime? ? closedAt : this.closedAt,
      reopenedAt: reopenedAt is DateTime? ? reopenedAt : this.reopenedAt,
      reopenReason: reopenReason is String? ? reopenReason : this.reopenReason,
      rejectionReason: rejectionReason is String?
          ? rejectionReason
          : this.rejectionReason,
      rejectedAt: rejectedAt is DateTime? ? rejectedAt : this.rejectedAt,
      claimHash: claimHash is String? ? claimHash : this.claimHash,
      claimToken: claimToken is String? ? claimToken : this.claimToken,
      uploadToken: uploadToken is String? ? uploadToken : this.uploadToken,
    );
  }
}

class IssueUpdateTable extends _is.UpdateTable<IssueTable> {
  IssueUpdateTable(super.table);

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> category(String value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<double, double> latitude(double? value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double? value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<String, String> userId(String? value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> photoPath(String? value) => _is.ColumnValue(
    table.photoPath,
    value,
  );

  _is.ColumnValue<String, String> priority(String? value) => _is.ColumnValue(
    table.priority,
    value,
  );

  _is.ColumnValue<String, String> department(String? value) => _is.ColumnValue(
    table.department,
    value,
  );

  _is.ColumnValue<String, String> assignedEmployeeId(String? value) =>
      _is.ColumnValue(
        table.assignedEmployeeId,
        value,
      );

  _is.ColumnValue<String, String> assignedEmployeeName(String? value) =>
      _is.ColumnValue(
        table.assignedEmployeeName,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> assignedAt(DateTime? value) =>
      _is.ColumnValue(
        table.assignedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> dueDate(DateTime? value) =>
      _is.ColumnValue(
        table.dueDate,
        value,
      );

  _is.ColumnValue<String, String> progressNotes(String? value) =>
      _is.ColumnValue(
        table.progressNotes,
        value,
      );

  _is.ColumnValue<String, String> completionNotes(String? value) =>
      _is.ColumnValue(
        table.completionNotes,
        value,
      );

  _is.ColumnValue<String, String> completionPhotoPath(String? value) =>
      _is.ColumnValue(
        table.completionPhotoPath,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> closedAt(DateTime? value) =>
      _is.ColumnValue(
        table.closedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> reopenedAt(DateTime? value) =>
      _is.ColumnValue(
        table.reopenedAt,
        value,
      );

  _is.ColumnValue<String, String> reopenReason(String? value) =>
      _is.ColumnValue(
        table.reopenReason,
        value,
      );

  _is.ColumnValue<String, String> rejectionReason(String? value) =>
      _is.ColumnValue(
        table.rejectionReason,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> rejectedAt(DateTime? value) =>
      _is.ColumnValue(
        table.rejectedAt,
        value,
      );

  _is.ColumnValue<String, String> claimHash(String? value) => _is.ColumnValue(
    table.claimHash,
    value,
  );
}

class IssueTable extends _is.Table<int?> {
  IssueTable({super.tableRelation}) : super(tableName: 'civic_issue') {
    updateTable = IssueUpdateTable(this);
    title = _is.ColumnString(
      'title',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    photoPath = _is.ColumnString(
      'photoPath',
      this,
    );
    priority = _is.ColumnString(
      'priority',
      this,
    );
    department = _is.ColumnString(
      'department',
      this,
    );
    assignedEmployeeId = _is.ColumnString(
      'assignedEmployeeId',
      this,
    );
    assignedEmployeeName = _is.ColumnString(
      'assignedEmployeeName',
      this,
    );
    assignedAt = _is.ColumnDateTime(
      'assignedAt',
      this,
    );
    dueDate = _is.ColumnDateTime(
      'dueDate',
      this,
    );
    progressNotes = _is.ColumnString(
      'progressNotes',
      this,
    );
    completionNotes = _is.ColumnString(
      'completionNotes',
      this,
    );
    completionPhotoPath = _is.ColumnString(
      'completionPhotoPath',
      this,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
    closedAt = _is.ColumnDateTime(
      'closedAt',
      this,
    );
    reopenedAt = _is.ColumnDateTime(
      'reopenedAt',
      this,
    );
    reopenReason = _is.ColumnString(
      'reopenReason',
      this,
    );
    rejectionReason = _is.ColumnString(
      'rejectionReason',
      this,
    );
    rejectedAt = _is.ColumnDateTime(
      'rejectedAt',
      this,
    );
    claimHash = _is.ColumnString(
      'claimHash',
      this,
    );
  }

  late final IssueUpdateTable updateTable;

  late final _is.ColumnString title;

  late final _is.ColumnString description;

  late final _is.ColumnString category;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnString userId;

  late final _is.ColumnString photoPath;

  late final _is.ColumnString priority;

  late final _is.ColumnString department;

  late final _is.ColumnString assignedEmployeeId;

  late final _is.ColumnString assignedEmployeeName;

  late final _is.ColumnDateTime assignedAt;

  late final _is.ColumnDateTime dueDate;

  late final _is.ColumnString progressNotes;

  late final _is.ColumnString completionNotes;

  late final _is.ColumnString completionPhotoPath;

  late final _is.ColumnDateTime resolvedAt;

  late final _is.ColumnDateTime closedAt;

  late final _is.ColumnDateTime reopenedAt;

  late final _is.ColumnString reopenReason;

  late final _is.ColumnString rejectionReason;

  late final _is.ColumnDateTime rejectedAt;

  late final _is.ColumnString claimHash;

  @override
  List<_is.Column> get columns => [
    id,
    title,
    description,
    category,
    status,
    createdAt,
    latitude,
    longitude,
    userId,
    photoPath,
    priority,
    department,
    assignedEmployeeId,
    assignedEmployeeName,
    assignedAt,
    dueDate,
    progressNotes,
    completionNotes,
    completionPhotoPath,
    resolvedAt,
    closedAt,
    reopenedAt,
    reopenReason,
    rejectionReason,
    rejectedAt,
    claimHash,
  ];
}

class IssueInclude extends _is.IncludeObject {
  IssueInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Issue.t;
}

class IssueIncludeList extends _is.IncludeList {
  IssueIncludeList._({
    _is.WhereExpressionBuilder<IssueTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Issue.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Issue.t;
}

class IssueRepository {
  const IssueRepository._();

  /// Returns a list of [Issue]s matching the given query parameters.
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
  Future<List<Issue>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IssueTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IssueTable>? orderBy,
    _is.OrderByListBuilder<IssueTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Issue>(
      where: where?.call(Issue.t),
      orderBy: orderBy?.call(Issue.t),
      orderByList: orderByList?.call(Issue.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Issue] matching the given query parameters.
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
  Future<Issue?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IssueTable>? where,
    int? offset,
    _is.OrderByBuilder<IssueTable>? orderBy,
    _is.OrderByListBuilder<IssueTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Issue>(
      where: where?.call(Issue.t),
      orderBy: orderBy?.call(Issue.t),
      orderByList: orderByList?.call(Issue.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Issue] by its [id] or null if no such row exists.
  Future<Issue?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Issue>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Issue]s in the list and returns the inserted rows.
  ///
  /// The returned [Issue]s will have their `id` fields set.
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
  Future<List<Issue>> insert(
    _is.DatabaseSession session,
    List<Issue> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Issue>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Issue] and returns the inserted row.
  ///
  /// The returned [Issue] will have its `id` field set.
  Future<Issue> insertRow(
    _is.DatabaseSession session,
    Issue row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Issue>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Issue]s in the list and returns the resulting rows.
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
  /// The returned [Issue]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Issue>> upsert(
    _is.DatabaseSession session,
    List<Issue> rows, {
    required _is.ColumnSelections<IssueTable> conflictColumns,
    _is.ColumnSelections<IssueTable>? updateColumns,
    _is.WhereExpressionBuilder<IssueTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Issue>(
      rows,
      conflictColumns: conflictColumns(Issue.t),
      updateColumns: updateColumns?.call(Issue.t),
      updateWhere: updateWhere?.call(Issue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Issue] and returns the resulting row.
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
  /// The returned [Issue] will have its `id` field set.
  Future<Issue?> upsertRow(
    _is.DatabaseSession session,
    Issue row, {
    required _is.ColumnSelections<IssueTable> conflictColumns,
    _is.ColumnSelections<IssueTable>? updateColumns,
    _is.WhereExpressionBuilder<IssueTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Issue>(
      row,
      conflictColumns: conflictColumns(Issue.t),
      updateColumns: updateColumns?.call(Issue.t),
      updateWhere: updateWhere?.call(Issue.t),
      transaction: transaction,
    );
  }

  /// Updates all [Issue]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Issue>> update(
    _is.DatabaseSession session,
    List<Issue> rows, {
    _is.ColumnSelections<IssueTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Issue>(
      rows,
      columns: columns?.call(Issue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Issue]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Issue> updateRow(
    _is.DatabaseSession session,
    Issue row, {
    _is.ColumnSelections<IssueTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Issue>(
      row,
      columns: columns?.call(Issue.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Issue] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Issue?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<IssueUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Issue>(
      id,
      columnValues: columnValues(Issue.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Issue]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Issue>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IssueUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IssueTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IssueTable>? orderBy,
    _is.OrderByListBuilder<IssueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Issue>(
      columnValues: columnValues(Issue.t.updateTable),
      where: where(Issue.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Issue.t),
      orderByList: orderByList?.call(Issue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Issue]s in the list and returns the deleted rows.
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
  Future<List<Issue>> delete(
    _is.DatabaseSession session,
    List<Issue> rows, {
    _is.OrderByBuilder<IssueTable>? orderBy,
    _is.OrderByListBuilder<IssueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Issue>(
      rows,
      orderBy: orderBy?.call(Issue.t),
      orderByList: orderByList?.call(Issue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Issue].
  Future<Issue> deleteRow(
    _is.DatabaseSession session,
    Issue row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Issue>(
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
  Future<List<Issue>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IssueTable> where,
    _is.OrderByBuilder<IssueTable>? orderBy,
    _is.OrderByListBuilder<IssueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Issue>(
      where: where(Issue.t),
      orderBy: orderBy?.call(Issue.t),
      orderByList: orderByList?.call(Issue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IssueTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Issue>(
      where: where?.call(Issue.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Issue] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IssueTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Issue>(
      where: where(Issue.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
