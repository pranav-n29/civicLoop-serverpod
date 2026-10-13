import 'package:flutter/material.dart';

import '../services/mock_workflow_service.dart';
import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';
import 'admin_dashboard_screen.dart';
import 'responder_dashboard_screen.dart';

class RoleSelectorScreen extends StatelessWidget {
  final MockWorkflowService workflowService;
  final Widget citizenHome;

  RoleSelectorScreen({
    super.key,
    MockWorkflowService? workflowService,
    required this.citizenHome,
  }) : workflowService = workflowService ?? MockWorkflowService();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(CivicSpacing.page),
        children: [
          const SizedBox(height: 36),
          const Icon(Icons.hub_rounded, color: CivicColors.blue, size: 52),
          const SizedBox(height: 18),
          Text('CivicLoop', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Choose a demo workspace',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          const CivicCard(
            color: CivicColors.warningTint,
            child: Text(
              'Demo role selector • this is not secure authentication. Backend roles are not implemented yet.',
            ),
          ),
          const SizedBox(height: 20),
          _RoleCard(
            icon: Icons.person_outline,
            title: 'Citizen',
            description: 'Report issues and verify resolutions.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => citizenHome,
              ),
            ),
          ),
          _RoleCard(
            icon: Icons.dashboard_outlined,
            title: 'Admin',
            description: 'Review, prioritize, and assign reports.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDashboardScreen(service: workflowService),
              ),
            ),
          ),
          _RoleCard(
            icon: Icons.engineering_outlined,
            title: 'Responder',
            description: 'Work assigned issues and submit evidence.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ResponderDashboardScreen(service: workflowService),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: CivicCard(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: CivicColors.blueTint,
          child: Icon(icon, color: CivicColors.blue),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    ),
  );
}
