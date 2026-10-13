import 'package:flutter/material.dart';
import 'screens/ai_analysis_screen.dart';
import 'screens/citizen_home_screen.dart';
import 'screens/role_selector_screen.dart';
import 'services/mock_issue_service.dart';
import 'theme/app_theme.dart';
import 'widgets/civic_card.dart';
import 'widgets/civic_components.dart';

void main() {
  runApp(const CivicLoopApp());
}

const navy = CivicColors.navy;
const blue = CivicColors.blue;
const canvas = CivicColors.background;
const muted = CivicColors.secondaryText;

class CivicLoopApp extends StatelessWidget {
  const CivicLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final issueService = MockIssueService();
    return MaterialApp(
      title: 'CivicLoop',
      debugShowCheckedModeBanner: false,
      theme: CivicTheme.light,
      home: RoleSelectorScreen(
        citizenHome: CivicHomeScreen(
          issueService: issueService,
          reportScreen: _ReportIssueScreen(service: issueService),
        ),
      ),
    );
  }
}

class _LegacyHomeScreen extends StatefulWidget {
  const _LegacyHomeScreen();

  @override
  State<_LegacyHomeScreen> createState() => _LegacyHomeScreenState();
}

class _LegacyHomeScreenState extends State<_LegacyHomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            _homeContent(),
            const _SimplePage(
              icon: Icons.map_outlined,
              title: 'Nearby issues',
              subtitle: 'Discover civic issues around your neighborhood.',
            ),
            const _SimplePage(
              icon: Icons.assignment_outlined,
              title: 'My reports',
              subtitle: 'Track the issues you have reported.',
            ),
            const _SimplePage(
              icon: Icons.person_outline,
              title: 'Your profile',
              subtitle: 'Your account and community activity.',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openReport,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report issue'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDBEAFE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CIVICLOOP',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            letterSpacing: 1.5,
                            color: navy,
                          ),
                        ),
                        Text(
                          'YOUR CITY, YOUR VOICE',
                          style: TextStyle(
                            color: muted,
                            fontSize: 10,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notifications are demo-only until a backend is connected.',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Your neighborhood,',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: navy,
                  height: 1.15,
                ),
              ),
              const Text(
                'better together.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: blue,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Small actions. Visible progress. Stronger communities.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF173B73), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.radar_rounded,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'COMMUNITY PULSE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DEMO DATA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 23),
                    const Text(
                      '12 active issues',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your community is making progress.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.72,
                        minHeight: 7,
                        backgroundColor: Color(0x557CA6E8),
                        color: Color(0xFF86EFAC),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Community resolution progress',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '72%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const _SectionHeading(
                title: 'Community impact',
                subtitle: 'A little progress goes a long way.',
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Expanded(
                    child: _ImpactCard(
                      icon: Icons.task_alt_rounded,
                      value: '37',
                      label: 'Resolved',
                      color: Color(0xFF15803D),
                      tint: Color(0xFFDCFCE7),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _ImpactCard(
                      icon: Icons.groups_2_outlined,
                      value: '184',
                      label: 'Citizens involved',
                      color: Color(0xFF1D4ED8),
                      tint: Color(0xFFDBEAFE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _SectionHeading(
                title: 'Needs attention',
                subtitle: 'Issues your community has reported.',
              ),
              const SizedBox(height: 15),
              const _IssueCard(
                icon: Icons.construction_rounded,
                category: 'Road damage',
                description: 'Pothole near the main junction',
                distance: '120 m away',
                priority: 'HIGH',
                color: Color(0xFFDC2626),
                tint: Color(0xFFFEE2E2),
              ),
              const SizedBox(height: 12),
              const _IssueCard(
                icon: Icons.lightbulb_outline_rounded,
                category: 'Street lighting',
                description: 'Streetlight not working',
                distance: '280 m away',
                priority: 'MEDIUM',
                color: Color(0xFFB45309),
                tint: Color(0xFFFEF3C7),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5EAF2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.handshake_outlined, color: blue, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Better together',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Support an existing issue instead of reporting it twice.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _openReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ReportIssueScreen(service: MockIssueService()),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color tint;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IconData icon;
  final String category;
  final String description;
  final String distance;
  final String priority;
  final Color color;
  final Color tint;

  const _IssueCard({
    required this.icon,
    required this.category,
    required this.description,
    required this.distance,
    required this.priority,
    required this.color,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Text(
                  '📍 $distance',
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SimplePage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: blue),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportIssueScreen extends StatefulWidget {
  final MockIssueService service;
  const _ReportIssueScreen({required this.service});

  @override
  State<_ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<_ReportIssueScreen> {
  final descriptionController = TextEditingController();
  String category = 'Roads';
  String severity = 'Medium';
  String? location;
  bool _loading = false;
  String? _photoLabel;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'Help improve your neighborhood.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Share the details. Your community can help move it forward.',
            style: TextStyle(color: muted, height: 1.5),
          ),
          const SizedBox(height: 25),
          CivicCard(
            color: CivicColors.blueTint,
            child: Column(
              children: [
                Icon(Icons.add_a_photo_outlined, size: 38, color: blue),
                SizedBox(height: 10),
                Text(
                  'Photo evidence',
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _photoLabel ?? 'No photo selected. Demo interface only.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                CivicSecondaryButton(
                  label: _photoLabel == null ? 'Select photo' : 'Change photo',
                  icon: Icons.photo_library_outlined,
                  onPressed: () =>
                      setState(() => _photoLabel = 'Demo photo selected'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Issue category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Roads', child: Text('Roads')),
              DropdownMenuItem(
                value: 'Streetlights',
                child: Text('Streetlights'),
              ),
              DropdownMenuItem(value: 'Water', child: Text('Water')),
              DropdownMenuItem(value: 'Waste', child: Text('Waste')),
              DropdownMenuItem(value: 'Drainage', child: Text('Drainage')),
              DropdownMenuItem(
                value: 'Public Safety',
                child: Text('Public Safety'),
              ),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => category = value);
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Priority (your assessment)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Low', label: Text('Low')),
              ButtonSegment(value: 'Medium', label: Text('Medium')),
              ButtonSegment(value: 'High', label: Text('High')),
              ButtonSegment(value: 'Critical', label: Text('Critical')),
            ],
            selected: {severity},
            onSelectionChanged: (value) {
              setState(() => severity = value.first);
            },
          ),
          const SizedBox(height: 18),
          Text(
            'What happened?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the issue and where you noticed it...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 22),
          CivicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  location ?? 'Location not selected',
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 8),
                CivicSecondaryButton(
                  label: location == null
                      ? 'Choose location'
                      : 'Change location',
                  icon: Icons.location_on_outlined,
                  onPressed: () async {
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Choose a demo location'),
                        children: [
                          for (final value in [
                            'Oakridge Avenue',
                            'Ward 4',
                            'Community center',
                          ])
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, value),
                              child: Text(value),
                            ),
                        ],
                      ),
                    );
                    if (selected != null) setState(() => location = selected);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          CivicPrimaryButton(
            loading: _loading,
            onPressed: _loading
                ? null
                : () async {
                    final description = descriptionController.text.trim();

                    if (description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please describe the issue first.'),
                        ),
                      );
                      return;
                    }

                    setState(() => _loading = true);
                    try {
                      final created = await widget.service.addReport(
                        category: category,
                        severity: severity,
                        description: description,
                        location: location,
                      );
                      if (!context.mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => AiAnalysisScreen(
                            category: category,
                            severity: severity,
                            description: description,
                            service: widget.service,
                            createdIssue: created,
                          ),
                        ),
                      );
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not create demo report: $error',
                            ),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },

            icon: Icons.auto_awesome_rounded,
            label: 'Analyze report',
          ),
        ],
      ),
    );
  }
}
