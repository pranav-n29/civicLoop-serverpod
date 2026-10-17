import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';
import 'admin_dashboard_screen.dart';
import 'auth_dialog.dart';
import 'create_issue_screen.dart';
import 'employee_dashboard_screen.dart';
import 'issue_feed_screen.dart';
import 'my_issues_screen.dart';
import 'notifications_dialog.dart';
import 'notifications_screen.dart';

/// Main navigation shell for CivicLoop with role-based dashboards.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Key _feedKey = UniqueKey();
  Key _myIssuesKey = UniqueKey();
  Key _adminOpsKey = UniqueKey();
  Key _adminStaffKey = UniqueKey();
  Key _employeeKey = UniqueKey();
  Key _notificationsKey = UniqueKey();

  StaffUserInfo? _userProfile;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_handleAuthChange);
    _refreshRoleAndNotifications();
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    _currentIndex = 0;
    _refreshRoleAndNotifications();
  }

  Future<void> _refreshRoleAndNotifications() async {
    if (!mounted) return;
    if (client.auth.isAuthenticated) {
      try {
        final profile = await client.issue.getCurrentUserProfile();
        final notifs = await client.issue.getNotifications(unreadOnly: true);
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _unreadNotificationsCount = notifs.length;
          });
        }
      } catch (e) {
        // If server denies access (e.g. format mismatch, unprovisioned domain, deactivated)
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('access denied') ||
            errStr.contains('deactivated') ||
            errStr.contains('unauthorized') ||
            errStr.contains('insufficientaccess')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Authentication Notice: $e'),
                backgroundColor: Colors.red.shade800,
              ),
            );
          }
          await client.auth.signOutDevice();
          if (mounted) {
            setState(() {
              _userProfile = null;
              _unreadNotificationsCount = 0;
              _currentIndex = 0;
            });
          }
          return;
        }
        if (mounted) setState(() {});
      }
    } else {
      if (mounted) {
        setState(() {
          _userProfile = null;
          _unreadNotificationsCount = 0;
          _currentIndex = 0;
        });
      }
    }
  }

  String get _currentRole {
    if (!client.auth.isAuthenticated) return 'anonymous';
    // Strictly rely on backend verified role
    if (_userProfile != null) {
      final r = _userProfile!.role.toLowerCase();
      // Municipal administrators access Admin Dashboard directly without approval
      if (r == 'admin') return 'admin';
      if (_userProfile!.approvalStatus == 'pending') {
        return 'pending';
      }
      if (!_userProfile!.isActive &&
          _userProfile!.approvalStatus != 'approved') {
        return 'pending';
      }
      if (!_userProfile!.isActive) {
        return 'deactivated';
      }
      if (r == 'employee') return 'employee';
      return 'citizen';
    }
    final scopes = client.auth.authInfo?.scopeNames ?? const <String>{};
    if (scopes.contains('admin') || scopes.contains('official')) return 'admin';
    return 'citizen';
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _refreshCurrentTab() {
    setState(() {
      _feedKey = UniqueKey();
      _myIssuesKey = UniqueKey();
      _adminOpsKey = UniqueKey();
      _adminStaffKey = UniqueKey();
      _employeeKey = UniqueKey();
      _notificationsKey = UniqueKey();
    });
    _refreshRoleAndNotifications();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final role = _currentRole;
    final isSignedIn = client.auth.isAuthenticated;
    final userIdentifier = client.auth.authInfo?.authUserId.toString();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 400;

    if (role == 'pending') {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: isNarrow ? 6 : 10,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: colors.onPrimaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              const Flexible(
                child: Text(
                  'CivicLoop',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Check Status',
              onPressed: _refreshRoleAndNotifications,
            ),
            Padding(
              padding: EdgeInsets.only(right: isNarrow ? 4 : 8),
              child: ActionChip(
                visualDensity: VisualDensity.compact,
                avatar: const Icon(
                  Icons.hourglass_top,
                  size: 16,
                  color: Colors.orange,
                ),
                label: const Text(
                  'Pending',
                  style: TextStyle(fontSize: 11, color: Colors.orange),
                ),
                onPressed: () => AuthDialog.show(context),
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 48,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Account Pending Approval',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Field Operations Worker account has been registered and is pending administrator approval before you can access field tasks.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Details',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 16),
                          _buildDetailRow(
                            'Email',
                            _userProfile?.email ?? userIdentifier ?? '—',
                          ),
                          if (_userProfile?.employeeId != null)
                            _buildDetailRow(
                              'Employee ID',
                              _userProfile!.employeeId!,
                            ),
                          _buildDetailRow(
                            'Requested Role',
                            _userProfile?.role == 'admin'
                                ? 'Municipal Administrator'
                                : 'Field Operations Worker',
                          ),
                          _buildDetailRow(
                            'Status',
                            'Pending Administrative Review',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Approval Status'),
                    onPressed: _refreshRoleAndNotifications,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    onPressed: () async {
                      await client.auth.signOutDevice();
                      _refreshRoleAndNotifications();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (role == 'deactivated') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('CivicLoop'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 48, color: colors.error),
                const SizedBox(height: 12),
                Text(
                  'Account Deactivated',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account has been deactivated by a municipal administrator. Please contact IT support if you believe this is in error.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  onPressed: () async {
                    await client.auth.signOutDevice();
                    _refreshRoleAndNotifications();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Configure role-specific tabs and views
    final List<Widget> tabViews;
    final List<NavigationDestination> destinations;

    if (role == 'admin') {
      tabViews = [
        AdminDashboardScreen(key: _adminOpsKey, fixedTab: 0),
        AdminDashboardScreen(key: _adminStaffKey, fixedTab: 1),
        NotificationsScreen(
          key: _notificationsKey,
          onNotificationsUpdated: _refreshRoleAndNotifications,
        ),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Case Operations',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Staff & Workloads',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ];
    } else if (role == 'employee') {
      tabViews = [
        EmployeeDashboardScreen(key: _employeeKey),
        IssueFeedScreen(
          key: _feedKey,
          onNavigateToCreate: null,
        ),
        NotificationsScreen(
          key: _notificationsKey,
          onNotificationsUpdated: _refreshRoleAndNotifications,
        ),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.engineering_outlined),
          selectedIcon: Icon(Icons.engineering),
          label: 'Field Tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.dynamic_feed_outlined),
          selectedIcon: Icon(Icons.dynamic_feed_rounded),
          label: 'Public Feed',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ];
    } else {
      // Citizen (authenticated or anonymous)
      tabViews = [
        IssueFeedScreen(
          key: _feedKey,
          onNavigateToCreate: () => _onTabSelected(2),
        ),
        MyIssuesScreen(
          key: _myIssuesKey,
          onNavigateToCreate: () => _onTabSelected(2),
        ),
        CreateIssueScreen(
          onIssueCreated: () {
            setState(() {
              _feedKey = UniqueKey();
              _myIssuesKey = UniqueKey();
              _currentIndex = 0;
            });
          },
        ),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.dynamic_feed_outlined),
          selectedIcon: Icon(Icons.dynamic_feed_rounded),
          label: 'Issue Feed',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_ind_outlined),
          selectedIcon: Icon(Icons.assignment_ind_rounded),
          label: 'My Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Report Issue',
        ),
      ];
    }

    final safeIndex = (_currentIndex >= 0 && _currentIndex < tabViews.length)
        ? _currentIndex
        : 0;

    String chipLabel;
    Color chipColor;
    if (!isSignedIn) {
      chipLabel = 'Anonymous';
      chipColor = colors.onSurfaceVariant;
    } else if (role == 'admin') {
      chipLabel = 'Admin: ${userIdentifier ?? ""}';
      chipColor = Colors.indigo;
    } else if (role == 'employee') {
      chipLabel = 'Staff: ${userIdentifier ?? ""}';
      chipColor = Colors.teal;
    } else {
      chipLabel = 'Citizen: ${userIdentifier ?? ""}';
      chipColor = Colors.blue;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isNarrow ? 6 : 10,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_city_rounded,
                color: colors.onPrimaryContainer,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CivicLoop',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    role == 'admin'
                        ? 'Admin'
                        : (role == 'employee'
                              ? 'Field Ops'
                              : (screenWidth < 360
                                    ? 'Triage'
                                    : (screenWidth < 600
                                          ? 'Issue Triage'
                                          : 'Urban Issue Triage & Management'))),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notifications Bell
          if (isSignedIn)
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notifications',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => NotificationsDialog(
                        onNotificationsUpdated: _refreshRoleAndNotifications,
                      ),
                    );
                  },
                ),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadNotificationsCount > 9
                            ? '9+'
                            : '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _refreshCurrentTab,
          ),
          Padding(
            padding: EdgeInsets.only(right: isNarrow ? 4 : 8),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              avatar: Icon(
                isSignedIn ? Icons.account_circle : Icons.person_outline,
                size: 16,
                color: chipColor,
              ),
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth < 360
                      ? 56
                      : (screenWidth < 420 ? 72 : 100),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: chipColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onPressed: () => AuthDialog.show(context),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: safeIndex,
        children: tabViews,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _onTabSelected,
        destinations: destinations,
      ),
    );
  }
}
