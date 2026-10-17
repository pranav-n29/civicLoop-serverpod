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
  Key _adminKey = UniqueKey();
  Key _employeeKey = UniqueKey();

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
      } catch (_) {
        if (mounted) setState(() {});
      }
    } else {
      if (mounted) {
        setState(() {
          _userProfile = null;
          _unreadNotificationsCount = 0;
        });
      }
    }
  }

  String get _currentRole {
    if (!client.auth.isAuthenticated) return 'anonymous';
    if (_userProfile != null) return _userProfile!.role.toLowerCase();
    final scopes = client.auth.authInfo?.scopeNames ?? const <String>{};
    if (scopes.contains('admin') || scopes.contains('official')) return 'admin';
    final uid = client.auth.authInfo?.authUserId.toString().toLowerCase() ?? '';
    if (uid.endsWith('@official.civicloop') || uid == 'admin') return 'admin';
    if (uid.startsWith('worker-') || uid.startsWith('employee-')) {
      return 'employee';
    }
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
      _adminKey = UniqueKey();
      _employeeKey = UniqueKey();
    });
    _refreshRoleAndNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final role = _currentRole;
    final isSignedIn = client.auth.isAuthenticated;
    final userIdentifier = client.auth.authInfo?.authUserId.toString();

    // Configure role-specific tabs and views
    final List<Widget> tabViews;
    final List<NavigationDestination> destinations;

    if (role == 'admin') {
      tabViews = [
        AdminDashboardScreen(key: _adminKey),
        IssueFeedScreen(
          key: _feedKey,
          onNavigateToCreate: () => _onTabSelected(3),
        ),
        MyIssuesScreen(
          key: _myIssuesKey,
          onNavigateToCreate: () => _onTabSelected(3),
        ),
        CreateIssueScreen(
          onIssueCreated: () {
            setState(() {
              _adminKey = UniqueKey();
              _feedKey = UniqueKey();
              _myIssuesKey = UniqueKey();
              _currentIndex = 0;
            });
          },
        ),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin Center',
        ),
        NavigationDestination(
          icon: Icon(Icons.dynamic_feed_outlined),
          selectedIcon: Icon(Icons.dynamic_feed_rounded),
          label: 'Public Feed',
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
    } else if (role == 'employee') {
      tabViews = [
        EmployeeDashboardScreen(key: _employeeKey),
        IssueFeedScreen(
          key: _feedKey,
          onNavigateToCreate: () => _onTabSelected(2),
        ),
        CreateIssueScreen(
          onIssueCreated: () {
            setState(() {
              _employeeKey = UniqueKey();
              _feedKey = UniqueKey();
              _currentIndex = 0;
            });
          },
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
          icon: Icon(Icons.add_circle_outline_rounded),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Report Issue',
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

    final safeIndex = _currentIndex < tabViews.length ? _currentIndex : 0;

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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 400;

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
                                    : (isNarrow
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
                  maxWidth: screenWidth < 360 ? 60 : (isNarrow ? 76 : 100),
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
