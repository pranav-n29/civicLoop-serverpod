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
import 'dart:typed_data' as _idt;
import 'package:civicloop_server/src/generated/issues/issue.dart' as _i5xq1slo;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../ai/ai_endpoint.dart' as _i4qeki52;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../issues/issue_endpoint.dart' as _i2bx2j6j;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'ai': _i4qeki52.AiEndpoint()
        ..initialize(
          server,
          'ai',
          null,
        ),
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'issue': _i2bx2j6j.IssueEndpoint()
        ..initialize(
          server,
          'issue',
          null,
        ),
    };
    connectors['ai'] = _is.EndpointConnector(
      name: 'ai',
      endpoint: endpoints['ai']!,
      methodConnectors: {
        'triageIssue': _is.MethodConnector(
          name: 'triageIssue',
          params: {
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ai'] as _i4qeki52.AiEndpoint).triageIssue(
                session,
                params['description'],
              ),
        ),
      },
    );
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['issue'] = _is.EndpointConnector(
      name: 'issue',
      endpoint: endpoints['issue']!,
      methodConnectors: {
        'createIssue': _is.MethodConnector(
          name: 'createIssue',
          params: {
            'issue': _is.ParameterDescription(
              name: 'issue',
              type: _is.getType<_i5xq1slo.Issue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).createIssue(
                    session,
                    params['issue'],
                  ),
        ),
        'getIssues': _is.MethodConnector(
          name: 'getIssues',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getIssues(session),
        ),
        'getMyIssues': _is.MethodConnector(
          name: 'getMyIssues',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getMyIssues(session),
        ),
        'getIssueById': _is.MethodConnector(
          name: 'getIssueById',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'claimToken': _is.ParameterDescription(
              name: 'claimToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).getIssueById(
                    session,
                    params['id'],
                    claimToken: params['claimToken'],
                  ),
        ),
        'updateIssueStatus': _is.MethodConnector(
          name: 'updateIssueStatus',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .updateIssueStatus(
                    session,
                    params['id'],
                    params['status'],
                  ),
        ),
        'getAdminIssues': _is.MethodConnector(
          name: 'getAdminIssues',
          params: {
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'category': _is.ParameterDescription(
              name: 'category',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'department': _is.ParameterDescription(
              name: 'department',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'priority': _is.ParameterDescription(
              name: 'priority',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'assignedEmployeeId': _is.ParameterDescription(
              name: 'assignedEmployeeId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'search': _is.ParameterDescription(
              name: 'search',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getAdminIssues(
                    session,
                    status: params['status'],
                    category: params['category'],
                    department: params['department'],
                    priority: params['priority'],
                    assignedEmployeeId: params['assignedEmployeeId'],
                    search: params['search'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getAdminStats': _is.MethodConnector(
          name: 'getAdminStats',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getAdminStats(session),
        ),
        'assignIssue': _is.MethodConnector(
          name: 'assignIssue',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'employeeUserId': _is.ParameterDescription(
              name: 'employeeUserId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'dueDate': _is.ParameterDescription(
              name: 'dueDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
            'priority': _is.ParameterDescription(
              name: 'priority',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'department': _is.ParameterDescription(
              name: 'department',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'notes': _is.ParameterDescription(
              name: 'notes',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).assignIssue(
                    session,
                    params['issueId'],
                    params['employeeUserId'],
                    dueDate: params['dueDate'],
                    priority: params['priority'],
                    department: params['department'],
                    notes: params['notes'],
                  ),
        ),
        'rejectIssue': _is.MethodConnector(
          name: 'rejectIssue',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).rejectIssue(
                    session,
                    params['issueId'],
                    params['reason'],
                  ),
        ),
        'getEmployeeAssignedIssues': _is.MethodConnector(
          name: 'getEmployeeAssignedIssues',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getEmployeeAssignedIssues(session),
        ),
        'startWork': _is.MethodConnector(
          name: 'startWork',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'notes': _is.ParameterDescription(
              name: 'notes',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).startWork(
                    session,
                    params['issueId'],
                    notes: params['notes'],
                  ),
        ),
        'addProgressNote': _is.MethodConnector(
          name: 'addProgressNote',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .addProgressNote(
                    session,
                    params['issueId'],
                    params['note'],
                  ),
        ),
        'resolveIssue': _is.MethodConnector(
          name: 'resolveIssue',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'completionNotes': _is.ParameterDescription(
              name: 'completionNotes',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'completionPhotoPath': _is.ParameterDescription(
              name: 'completionPhotoPath',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'completionPhotoData': _is.ParameterDescription(
              name: 'completionPhotoData',
              type: _is.getType<_idt.ByteData?>(),
              nullable: true,
            ),
            'completionPhotoFileName': _is.ParameterDescription(
              name: 'completionPhotoFileName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).resolveIssue(
                    session,
                    params['issueId'],
                    params['completionNotes'],
                    completionPhotoPath: params['completionPhotoPath'],
                    completionPhotoData: params['completionPhotoData'],
                    completionPhotoFileName: params['completionPhotoFileName'],
                  ),
        ),
        'confirmCitizenClosure': _is.MethodConnector(
          name: 'confirmCitizenClosure',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'claimToken': _is.ParameterDescription(
              name: 'claimToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'feedbackNotes': _is.ParameterDescription(
              name: 'feedbackNotes',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .confirmCitizenClosure(
                    session,
                    params['issueId'],
                    claimToken: params['claimToken'],
                    feedbackNotes: params['feedbackNotes'],
                  ),
        ),
        'reopenIssue': _is.MethodConnector(
          name: 'reopenIssue',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'claimToken': _is.ParameterDescription(
              name: 'claimToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).reopenIssue(
                    session,
                    params['issueId'],
                    params['reason'],
                    claimToken: params['claimToken'],
                  ),
        ),
        'getIssueAuditHistory': _is.MethodConnector(
          name: 'getIssueAuditHistory',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'claimToken': _is.ParameterDescription(
              name: 'claimToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getIssueAuditHistory(
                    session,
                    params['issueId'],
                    claimToken: params['claimToken'],
                  ),
        ),
        'getNotifications': _is.MethodConnector(
          name: 'getNotifications',
          params: {
            'unreadOnly': _is.ParameterDescription(
              name: 'unreadOnly',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getNotifications(
                    session,
                    unreadOnly: params['unreadOnly'],
                    limit: params['limit'],
                  ),
        ),
        'markNotificationRead': _is.MethodConnector(
          name: 'markNotificationRead',
          params: {
            'notificationId': _is.ParameterDescription(
              name: 'notificationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .markNotificationRead(
                    session,
                    params['notificationId'],
                  ),
        ),
        'markAllNotificationsRead': _is.MethodConnector(
          name: 'markAllNotificationsRead',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .markAllNotificationsRead(session),
        ),
        'getCurrentUserProfile': _is.MethodConnector(
          name: 'getCurrentUserProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getCurrentUserProfile(session),
        ),
        'getStaffUsers': _is.MethodConnector(
          name: 'getStaffUsers',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getStaffUsers(session),
        ),
        'provisionStaff': _is.MethodConnector(
          name: 'provisionStaff',
          params: {
            'targetUserId': _is.ParameterDescription(
              name: 'targetUserId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'department': _is.ParameterDescription(
              name: 'department',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'fullName': _is.ParameterDescription(
              name: 'fullName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .provisionStaff(
                    session,
                    params['targetUserId'],
                    params['role'],
                    department: params['department'],
                    fullName: params['fullName'],
                    email: params['email'],
                  ),
        ),
        'setStaffActiveStatus': _is.MethodConnector(
          name: 'setStaffActiveStatus',
          params: {
            'targetUserId': _is.ParameterDescription(
              name: 'targetUserId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'isActive': _is.ParameterDescription(
              name: 'isActive',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .setStaffActiveStatus(
                    session,
                    params['targetUserId'],
                    params['isActive'],
                  ),
        ),
        'bootstrapFirstAdmin': _is.MethodConnector(
          name: 'bootstrapFirstAdmin',
          params: {
            'secretKey': _is.ParameterDescription(
              name: 'secretKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'adminUserId': _is.ParameterDescription(
              name: 'adminUserId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'fullName': _is.ParameterDescription(
              name: 'fullName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .bootstrapFirstAdmin(
                    session,
                    params['secretKey'],
                    params['adminUserId'],
                    email: params['email'],
                    fullName: params['fullName'],
                  ),
        ),
        'attachIssuePhoto': _is.MethodConnector(
          name: 'attachIssuePhoto',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fileName': _is.ParameterDescription(
              name: 'fileName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'photoData': _is.ParameterDescription(
              name: 'photoData',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
            'uploadToken': _is.ParameterDescription(
              name: 'uploadToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .attachIssuePhoto(
                    session,
                    params['issueId'],
                    params['fileName'],
                    params['photoData'],
                    uploadToken: params['uploadToken'],
                  ),
        ),
        'getPhotoUploadDescription': _is.MethodConnector(
          name: 'getPhotoUploadDescription',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fileName': _is.ParameterDescription(
              name: 'fileName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'uploadToken': _is.ParameterDescription(
              name: 'uploadToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getPhotoUploadDescription(
                    session,
                    params['issueId'],
                    params['fileName'],
                    uploadToken: params['uploadToken'],
                  ),
        ),
        'verifyAndAttachPhoto': _is.MethodConnector(
          name: 'verifyAndAttachPhoto',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'path': _is.ParameterDescription(
              name: 'path',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'uploadToken': _is.ParameterDescription(
              name: 'uploadToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .verifyAndAttachPhoto(
                    session,
                    params['issueId'],
                    params['path'],
                    uploadToken: params['uploadToken'],
                  ),
        ),
        'getIssuePhotoUrl': _is.MethodConnector(
          name: 'getIssuePhotoUrl',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getIssuePhotoUrl(
                    session,
                    params['issueId'],
                  ),
        ),
        'getIssuePhoto': _is.MethodConnector(
          name: 'getIssuePhoto',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['issue'] as _i2bx2j6j.IssueEndpoint).getIssuePhoto(
                    session,
                    params['issueId'],
                  ),
        ),
        'getCompletionPhotoUrl': _is.MethodConnector(
          name: 'getCompletionPhotoUrl',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getCompletionPhotoUrl(
                    session,
                    params['issueId'],
                  ),
        ),
        'getCompletionPhoto': _is.MethodConnector(
          name: 'getCompletionPhoto',
          params: {
            'issueId': _is.ParameterDescription(
              name: 'issueId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['issue'] as _i2bx2j6j.IssueEndpoint)
                  .getCompletionPhoto(
                    session,
                    params['issueId'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
