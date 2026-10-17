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
import 'dart:async' as _ida;
import 'dart:typed_data' as _idt;
import 'package:civicloop_client/src/protocol/ai/issue_triage_result.dart'
    as _iqxh22ub;
import 'package:civicloop_client/src/protocol/auth/civic_user_role.dart'
    as _io8za3h0;
import 'package:civicloop_client/src/protocol/auth/staff_user_info.dart'
    as _ilwxnka6;
import 'package:civicloop_client/src/protocol/greetings/greeting.dart'
    as _iqmv00gx;
import 'package:civicloop_client/src/protocol/issues/admin_dashboard_stats.dart'
    as _ipc0lkwn;
import 'package:civicloop_client/src/protocol/issues/civic_issue_audit.dart'
    as _isquhekr;
import 'package:civicloop_client/src/protocol/issues/civic_notification.dart'
    as _i5n288wg;
import 'package:civicloop_client/src/protocol/issues/issue.dart' as _i3nh278b;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// Endpoint for AI-assisted civic issue triage.
/// {@category Endpoint}
class EndpointAi extends _isc.EndpointRef {
  EndpointAi(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ai';

  /// Analyzes an issue [description] and returns structured triage metadata
  /// including suggested title, category, priority (low, medium, high, critical),
  /// responsible department, and a summary.
  ///
  /// Throws [ArgumentError] if the description is invalid or empty.
  /// Throws [AiConfigurationException] if no AI provider credentials are configured.
  /// Throws [AiProviderException] if the AI provider encounters an error.
  /// Throws [AiValidationException] if the AI output fails validation.
  _ida.Future<_iqxh22ub.IssueTriageResult> triageIssue(String description) =>
      caller.callServerEndpoint<_iqxh22ub.IssueTriageResult>(
        'ai',
        'triageIssue',
        {'description': description},
      );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_iqmv00gx.Greeting> hello(String name) =>
      caller.callServerEndpoint<_iqmv00gx.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Endpoint for creating, listing, retrieving, and managing civic issues,
/// lifecycle state transitions, role-based workflows, audit history, and notifications.
/// {@category Endpoint}
class EndpointIssue extends _isc.EndpointRef {
  EndpointIssue(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'issue';

  /// Creates a new civic issue.
  ///
  /// Validates required text fields, ignores any client-supplied ID, status,
  /// or createdAt timestamp, sets [createdAt] to current server time and
  /// [status] to 'open', and persists the record to the database.
  /// Generates and returns an upload authorization token for photo upload.
  /// For anonymous reports, generates a secure claim token and stores its SHA-256 hash.
  _ida.Future<_i3nh278b.Issue> createIssue(_i3nh278b.Issue issue) =>
      caller.callServerEndpoint<_i3nh278b.Issue>(
        'issue',
        'createIssue',
        {'issue': issue},
      );

  /// Retrieves all civic issues ordered newest first for public viewing.
  _ida.Future<List<_i3nh278b.Issue>> getIssues() =>
      caller.callServerEndpoint<List<_i3nh278b.Issue>>(
        'issue',
        'getIssues',
        {},
      );

  /// Retrieves all civic issues submitted by the currently authenticated user.
  _ida.Future<List<_i3nh278b.Issue>> getMyIssues() =>
      caller.callServerEndpoint<List<_i3nh278b.Issue>>(
        'issue',
        'getMyIssues',
        {},
      );

  /// Retrieves a civic issue by its [id].
  ///
  /// Supports optional [claimToken] for anonymous reporters.
  _ida.Future<_i3nh278b.Issue?> getIssueById(
    int id, {
    String? claimToken,
  }) => caller.callServerEndpoint<_i3nh278b.Issue?>(
    'issue',
    'getIssueById',
    {
      'id': id,
      'claimToken': claimToken,
    },
  );

  /// Updates the status of an existing civic issue (kept for compatibility with officials).
  _ida.Future<_i3nh278b.Issue?> updateIssueStatus(
    int id,
    String status,
  ) => caller.callServerEndpoint<_i3nh278b.Issue?>(
    'issue',
    'updateIssueStatus',
    {
      'id': id,
      'status': status,
    },
  );

  /// Admin endpoint to retrieve all cases with filtering, search, and pagination.
  _ida.Future<List<_i3nh278b.Issue>> getAdminIssues({
    String? status,
    String? category,
    String? department,
    String? priority,
    String? assignedEmployeeId,
    String? search,
    int? limit,
    int? offset,
  }) => caller.callServerEndpoint<List<_i3nh278b.Issue>>(
    'issue',
    'getAdminIssues',
    {
      'status': status,
      'category': category,
      'department': department,
      'priority': priority,
      'assignedEmployeeId': assignedEmployeeId,
      'search': search,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Admin endpoint to retrieve aggregated dashboard statistics.
  _ida.Future<_ipc0lkwn.AdminDashboardStats> getAdminStats() =>
      caller.callServerEndpoint<_ipc0lkwn.AdminDashboardStats>(
        'issue',
        'getAdminStats',
        {},
      );

  /// Admin assigns or reassigns an issue to an employee.
  _ida.Future<_i3nh278b.Issue> assignIssue(
    int issueId,
    String employeeUserId, {
    DateTime? dueDate,
    String? priority,
    String? department,
    String? notes,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'assignIssue',
    {
      'issueId': issueId,
      'employeeUserId': employeeUserId,
      'dueDate': dueDate,
      'priority': priority,
      'department': department,
      'notes': notes,
    },
  );

  /// Admin rejects an invalid or duplicate issue with required reason.
  _ida.Future<_i3nh278b.Issue> rejectIssue(
    int issueId,
    String reason,
  ) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'rejectIssue',
    {
      'issueId': issueId,
      'reason': reason,
    },
  );

  /// Employee endpoint to retrieve cases assigned to the authenticated employee.
  _ida.Future<List<_i3nh278b.Issue>> getEmployeeAssignedIssues() =>
      caller.callServerEndpoint<List<_i3nh278b.Issue>>(
        'issue',
        'getEmployeeAssignedIssues',
        {},
      );

  /// Employee marks case as in-progress.
  _ida.Future<_i3nh278b.Issue> startWork(
    int issueId, {
    String? notes,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'startWork',
    {
      'issueId': issueId,
      'notes': notes,
    },
  );

  /// Employee adds a progress note.
  _ida.Future<_i3nh278b.Issue> addProgressNote(
    int issueId,
    String note,
  ) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'addProgressNote',
    {
      'issueId': issueId,
      'note': note,
    },
  );

  /// Employee submits resolution with completion notes and optional completion photo.
  _ida.Future<_i3nh278b.Issue> resolveIssue(
    int issueId,
    String completionNotes, {
    String? completionPhotoPath,
    _idt.ByteData? completionPhotoData,
    String? completionPhotoFileName,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'resolveIssue',
    {
      'issueId': issueId,
      'completionNotes': completionNotes,
      'completionPhotoPath': completionPhotoPath,
      'completionPhotoData': completionPhotoData,
      'completionPhotoFileName': completionPhotoFileName,
    },
  );

  /// Citizen confirms fixed and closes the case.
  _ida.Future<_i3nh278b.Issue> confirmCitizenClosure(
    int issueId, {
    String? claimToken,
    String? feedbackNotes,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'confirmCitizenClosure',
    {
      'issueId': issueId,
      'claimToken': claimToken,
      'feedbackNotes': feedbackNotes,
    },
  );

  /// Citizen disputes resolution and reopens the case with required reason.
  _ida.Future<_i3nh278b.Issue> reopenIssue(
    int issueId,
    String reason, {
    String? claimToken,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'reopenIssue',
    {
      'issueId': issueId,
      'reason': reason,
      'claimToken': claimToken,
    },
  );

  /// Retrieves chronological audit history for an issue.
  _ida.Future<List<_isquhekr.CivicIssueAudit>> getIssueAuditHistory(
    int issueId, {
    String? claimToken,
  }) => caller.callServerEndpoint<List<_isquhekr.CivicIssueAudit>>(
    'issue',
    'getIssueAuditHistory',
    {
      'issueId': issueId,
      'claimToken': claimToken,
    },
  );

  /// Retrieves in-app notifications for the authenticated user.
  _ida.Future<List<_i5n288wg.CivicNotification>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) => caller.callServerEndpoint<List<_i5n288wg.CivicNotification>>(
    'issue',
    'getNotifications',
    {
      'unreadOnly': unreadOnly,
      'limit': limit,
    },
  );

  /// Marks a specific notification as read.
  _ida.Future<bool> markNotificationRead(int notificationId) =>
      caller.callServerEndpoint<bool>(
        'issue',
        'markNotificationRead',
        {'notificationId': notificationId},
      );

  /// Marks all notifications for caller as read.
  _ida.Future<int> markAllNotificationsRead() => caller.callServerEndpoint<int>(
    'issue',
    'markAllNotificationsRead',
    {},
  );

  /// Retrieves caller's profile and trusted role information.
  _ida.Future<_ilwxnka6.StaffUserInfo?> getCurrentUserProfile() =>
      caller.callServerEndpoint<_ilwxnka6.StaffUserInfo?>(
        'issue',
        'getCurrentUserProfile',
        {},
      );

  /// Admin retrieves directory of all staff with active workloads.
  _ida.Future<List<_ilwxnka6.StaffUserInfo>> getStaffUsers() =>
      caller.callServerEndpoint<List<_ilwxnka6.StaffUserInfo>>(
        'issue',
        'getStaffUsers',
        {},
      );

  /// Admin provisions or changes a staff user's role.
  _ida.Future<_io8za3h0.CivicUserRole> provisionStaff(
    String targetUserId,
    String role, {
    String? department,
    String? fullName,
    String? email,
  }) => caller.callServerEndpoint<_io8za3h0.CivicUserRole>(
    'issue',
    'provisionStaff',
    {
      'targetUserId': targetUserId,
      'role': role,
      'department': department,
      'fullName': fullName,
      'email': email,
    },
  );

  /// Admin enables or disables a staff member.
  _ida.Future<_io8za3h0.CivicUserRole> setStaffActiveStatus(
    String targetUserId,
    bool isActive,
  ) => caller.callServerEndpoint<_io8za3h0.CivicUserRole>(
    'issue',
    'setStaffActiveStatus',
    {
      'targetUserId': targetUserId,
      'isActive': isActive,
    },
  );

  /// Bootstrap initial administrator account.
  _ida.Future<_io8za3h0.CivicUserRole> bootstrapFirstAdmin(
    String secretKey,
    String adminUserId, {
    String? email,
    String? fullName,
  }) => caller.callServerEndpoint<_io8za3h0.CivicUserRole>(
    'issue',
    'bootstrapFirstAdmin',
    {
      'secretKey': secretKey,
      'adminUserId': adminUserId,
      'email': email,
      'fullName': fullName,
    },
  );

  _ida.Future<_i3nh278b.Issue> attachIssuePhoto(
    int issueId,
    String fileName,
    _idt.ByteData photoData, {
    String? uploadToken,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'attachIssuePhoto',
    {
      'issueId': issueId,
      'fileName': fileName,
      'photoData': photoData,
      'uploadToken': uploadToken,
    },
  );

  _ida.Future<String> getPhotoUploadDescription(
    int issueId,
    String fileName, {
    String? uploadToken,
  }) => caller.callServerEndpoint<String>(
    'issue',
    'getPhotoUploadDescription',
    {
      'issueId': issueId,
      'fileName': fileName,
      'uploadToken': uploadToken,
    },
  );

  _ida.Future<_i3nh278b.Issue> verifyAndAttachPhoto(
    int issueId,
    String path, {
    String? uploadToken,
  }) => caller.callServerEndpoint<_i3nh278b.Issue>(
    'issue',
    'verifyAndAttachPhoto',
    {
      'issueId': issueId,
      'path': path,
      'uploadToken': uploadToken,
    },
  );

  _ida.Future<String?> getIssuePhotoUrl(int issueId) =>
      caller.callServerEndpoint<String?>(
        'issue',
        'getIssuePhotoUrl',
        {'issueId': issueId},
      );

  _ida.Future<_idt.ByteData?> getIssuePhoto(int issueId) =>
      caller.callServerEndpoint<_idt.ByteData?>(
        'issue',
        'getIssuePhoto',
        {'issueId': issueId},
      );

  _ida.Future<String?> getCompletionPhotoUrl(int issueId) =>
      caller.callServerEndpoint<String?>(
        'issue',
        'getCompletionPhotoUrl',
        {'issueId': issueId},
      );

  _ida.Future<_idt.ByteData?> getCompletionPhoto(int issueId) =>
      caller.callServerEndpoint<_idt.ByteData?>(
        'issue',
        'getCompletionPhoto',
        {'issueId': issueId},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    ai = EndpointAi(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    greeting = EndpointGreeting(this);
    issue = EndpointIssue(this);
    modules = Modules(this);
  }

  late final EndpointAi ai;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointGreeting greeting;

  late final EndpointIssue issue;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'ai': ai,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'greeting': greeting,
    'issue': issue,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
