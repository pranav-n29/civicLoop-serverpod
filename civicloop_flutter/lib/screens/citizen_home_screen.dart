import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import '../services/mock_issue_service.dart';
import 'my_reports_screen.dart';
import '../models/demo_issue.dart';
import 'issue_details_screen.dart';
import 'nearby_issues_screen.dart';
import 'profile_screen.dart';

const _navy = CivicColors.navy;
const _blue = CivicColors.blue;
const _background = CivicColors.background;
const _muted = CivicColors.secondaryText;
const _border = CivicColors.border;
const _success = CivicColors.success;

class CivicHomeScreen extends StatefulWidget {
  final Widget reportScreen;
  final MockIssueService issueService;

  CivicHomeScreen({
    super.key,
    required this.reportScreen,
    MockIssueService? issueService,
  }) : issueService = issueService ?? MockIssueService();

  @override
  State<CivicHomeScreen> createState() => _CivicHomeScreenState();
}

class _CivicHomeScreenState extends State<CivicHomeScreen> {
  int _selectedTab = 0;
  String _selectedFilter = 'All (14)';
  List<_IssueData> _issues = const [];

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    final issues = await widget.issueService.getIssues();
    if (!mounted) return;
    setState(() {
      _issues = issues.map(_IssueData.fromDemoIssue).toList();
    });
  }

  List<_IssueData> get _visibleIssues {
    if (_selectedFilter == 'High Severity (3)') {
      return _issues.where((issue) => issue.status == 'High severity').toList();
    }
    if (_selectedFilter == 'Roads (6)') {
      return _issues.where((issue) => issue.category == 'Roads').toList();
    }
    return _issues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHome(),
            NearbyIssuesScreen(service: widget.issueService),
            MyReportsScreen(service: widget.issueService),
            const ProfileScreen(),
          ],
        ),
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _openReport,
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Report'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDBEAFE),
        height: 72,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'My Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 112),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGreeting(),
              const SizedBox(height: 14),
              _buildPartnershipCard(),
              const SizedBox(height: 14),
              _buildPulseCard(),
              const SizedBox(height: 22),
              _buildSectionTitle(
                'Happening Around You',
                '(< 0.8 mi)',
                'View All (14)',
              ),
              const SizedBox(height: 12),
              _buildFilters(),
              const SizedBox(height: 12),
              ..._visibleIssues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _IssueCard(
                    issue: issue,
                    onTap: () => _openIssue(issue),
                  ),
                ),
              ),
              if (_visibleIssues.isEmpty)
                const _EmptyIssuesCard(message: 'No issues match this filter.'),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(22, 12, 18, 11),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'CivicLoop',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: ' • Home',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: TextStyle(color: _navy),
            ),
          ),
          IconButton(
            onPressed: _showNotifications,
            tooltip: 'Notifications',
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.notifications_none_rounded, color: _navy),
            ),
          ),
          IconButton(
            onPressed: _showLocationState,
            tooltip: 'Location',
            icon: const Icon(Icons.verified_outlined, color: _success),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tuesday, Oct 24',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Good morning, Sarah',
                style: TextStyle(
                  color: _navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  _showDemoMessage('Search is available in the connected app.'),
              icon: const Icon(Icons.search_rounded, color: _navy),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: _showLocationState,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: _blue, size: 8),
                SizedBox(width: 8),
                Icon(Icons.location_on_outlined, color: _blue, size: 16),
                SizedBox(width: 5),
                Text(
                  'Downtown Oakridge (Ward 4)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Live Pulse',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 7),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _muted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnershipCard() {
    return CivicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CIVIC PARTNERSHIP',
            style: TextStyle(
              color: _blue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Your neighborhood,\nbetter together.',
            style: TextStyle(
              color: _navy,
              fontSize: 18,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See active municipal fixes, report local hazards, and verify completed resolutions in real time.',
            style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
          ),
          const SizedBox(height: 11),
          InkWell(
            onTap: _openReport,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x332563EB),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white,
                    size: 23,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report an Issue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Instant AI triage & auto-dispatch',
                          style: TextStyle(
                            color: Color(0xFFDDE9FF),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: _blue, size: 15),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Takes ~45 seconds • Direct route to Oakridge Public Works',
                  style: TextStyle(color: _navy, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCard() {
    return CivicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: _blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oakridge Pulse',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Updated 12m ago • Demo statistics',
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              _TinyTag(text: 'OCTOBER'),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Fixed',
                  value: '42',
                  detail: '+14% wk',
                  color: _success,
                  icon: Icons.check_circle_outline,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: 'Active',
                  value: '18',
                  detail: '3 in QA',
                  color: _blue,
                  icon: Icons.groups_outlined,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: 'Avg Speed',
                  value: '3.2d',
                  detail: 'City target <4d',
                  color: _navy,
                  icon: Icons.timelapse_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ward Resolution Rate',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '70% this month',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: const LinearProgressIndicator(
                    value: .7,
                    minHeight: 6,
                    color: _blue,
                    backgroundColor: Color(0xFFDDE6F3),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '60 Goal',
                      style: TextStyle(color: _muted, fontSize: 9),
                    ),
                    Text(
                      '42 Resolved',
                      style: TextStyle(color: _muted, fontSize: 9),
                    ),
                    Text(
                      '18 Remaining',
                      style: TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String suffix, String action) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: _blue,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    const filters = ['All (14)', 'High Severity (3)', 'Roads (6)'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              labelStyle: TextStyle(
                color: selected ? Colors.white : _navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: Colors.white,
              selectedColor: _navy,
              side: BorderSide(color: selected ? _navy : _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => widget.reportScreen),
    );
  }

  void _openIssue(_IssueData issue) {
    final demoIssue = defaultDemoIssues().firstWhere(
      (candidate) => candidate.title == issue.title,
      orElse: () => DemoIssue(
        id: issue.id,
        title: issue.title,
        description: issue.description,
        category: issue.category,
        severity: issue.severity,
        status: issue.civicStatus,
        location: issue.distance,
        reportedAt: null,
        updatedAt: null,
        supportCount: 0,
        icon: issue.icon,
        color: issue.color,
        isUserReport: true,
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IssueDetailsScreen(
          issue: demoIssue,
          service: widget.issueService,
        ),
      ),
    );
  }

  void _showNotifications() => _showDemoMessage(
    'Notifications are demo-only until connected to the civic backend.',
  );

  void _showLocationState() => _showDemoMessage(
    'Location is currently set to Downtown Oakridge (Ward 4).',
  );

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TinyTag extends StatelessWidget {
  final String text;
  const _TinyTag({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: _background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color color;
  final IconData icon;
  const _StatBox({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: _background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: _muted, fontSize: 9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          detail,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _IssueData {
  final String id;
  final String title;
  final String category;
  final String distance;
  final String status;
  final Color color;
  final IconData icon;
  final CivicIssueStatus civicStatus;
  final String description;
  final String severity;
  const _IssueData({
    required this.id,
    required this.title,
    required this.category,
    required this.distance,
    required this.status,
    required this.color,
    required this.icon,
    required this.civicStatus,
    required this.description,
    required this.severity,
  });

  factory _IssueData.fromDemoIssue(DemoIssue issue) => _IssueData(
    id: issue.id,
    title: issue.title,
    category: issue.category,
    distance: issue.location ?? 'Location unavailable',
    status: issue.status.label,
    color: issue.color,
    icon: issue.icon,
    civicStatus: issue.status,
    description: issue.description,
    severity: issue.severity,
  );
}

class _IssueCard extends StatelessWidget {
  final _IssueData issue;
  final VoidCallback onTap;
  const _IssueCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: issue.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(issue.icon, color: issue.color, size: 22),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${issue.category} • ${issue.distance}',
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    issue.status,
                    style: TextStyle(
                      color: issue.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted),
          ],
        ),
      ),
    ),
  );
}

class _EmptyIssuesCard extends StatelessWidget {
  final String message;
  const _EmptyIssuesCard({required this.message});
  @override
  Widget build(BuildContext context) => CivicCard(
    child: Text(message, style: const TextStyle(color: _muted)),
  );
}
