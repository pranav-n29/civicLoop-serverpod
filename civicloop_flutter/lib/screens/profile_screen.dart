import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/civic_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  String _neighborhood = 'Downtown Oakridge';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        CivicSpacing.page,
        8,
        CivicSpacing.page,
        28,
      ),
      children: [
        const CivicCard(
          color: CivicColors.warningTint,
          child: Text(
            'DEMO PROFILE • these preferences are local to this app session and are not an authenticated account.',
          ),
        ),
        const SizedBox(height: 14),
        CivicCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: CivicColors.blueTint,
                child: Icon(
                  Icons.person_outline,
                  color: CivicColors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community member',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Demo citizen profile',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CivicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Neighborhood preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _neighborhood,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Neighborhood'),
                items: const [
                  DropdownMenuItem(
                    value: 'Downtown Oakridge',
                    child: Text('Downtown Oakridge'),
                  ),
                  DropdownMenuItem(
                    value: 'Ward 4',
                    child: Text('Ward 4'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _neighborhood = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Issue updates'),
                subtitle: const Text('Demo notification preference'),
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
