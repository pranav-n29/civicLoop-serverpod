import 'package:civicloop_client/civicloop_client.dart';
import 'package:flutter/material.dart';

import '../client.dart';

/// Modal dialog for user authentication and profile status.
class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const AuthDialog(),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  bool _isSignedIn = false;
  String? _userIdentifier;
  bool _showSignInWidget = false;
  StaffUserInfo? _staffProfile;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateAuthState);
    _updateAuthState();
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateAuthState);
    super.dispose();
  }

  void _updateAuthState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
      _userIdentifier = client.auth.authInfo?.authUserId.toString();
    });
    if (_isSignedIn) {
      _fetchProfile();
    } else {
      setState(() => _staffProfile = null);
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await client.issue.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _staffProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  String get _roleDisplay {
    if (_staffProfile != null) {
      final r = _staffProfile!.role.toLowerCase();
      if (r == 'admin') return 'Municipal Administrator';
      if (r == 'employee') return 'Field Operations Worker';
      return 'Verified Citizen';
    }
    final scopes = client.auth.authInfo?.scopeNames ?? const <String>{};
    if (scopes.contains('admin') || scopes.contains('official')) {
      return 'Municipal Administrator';
    }
    if (_userIdentifier != null) {
      final id = _userIdentifier!.toLowerCase();
      if (id.endsWith('@official.civicloop') || id == 'admin') {
        return 'Municipal Administrator';
      }
      if (id.startsWith('worker-') || id.startsWith('employee-')) {
        return 'Field Operations Worker';
      }
    }
    return 'Verified Citizen';
  }

  Color get _roleColor {
    final r = _roleDisplay.toLowerCase();
    if (r.contains('admin')) return Colors.indigo;
    if (r.contains('field')) return Colors.teal;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isSignedIn ? Icons.account_circle : Icons.person_outline,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
          Text(_isSignedIn ? 'Account Profile' : 'Sign In / Account'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSignedIn) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primary.withAlpha(60)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Authenticated Session',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User Identifier:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SelectableText(
                        _userIdentifier ?? 'Authenticated User',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_staffProfile?.fullName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Name: ${_staffProfile!.fullName!}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      if (_staffProfile?.department != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Department: ${_staffProfile!.department!}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _roleColor.withAlpha(120)),
                        ),
                        child: Text(
                          'Role: $_roleDisplay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _roleColor,
                          ),
                        ),
                      ),
                      if (_isLoadingProfile) ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your session determines dashboard views and permissions across the CivicLoop platform.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    onPressed: () async {
                      await client.auth.signOutDevice();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Signed out successfully. You can still report issues anonymously.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ] else ...[
                if (!_showSignInWidget) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'CivicLoop supports anonymous civic reporting. You can submit issues without an account, or sign in to track personal reports and manage case operations.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In with Email'),
                      onPressed: () {
                        setState(() {
                          _showSignInWidget = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hackathon Demo Roles:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '• Admin: Use an account with the official domain (@official.civicloop) or scope admin.\n• Field Worker: Accounts provisioned as employee.\n• Citizen: Any standard user email or anonymous report.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SignInWidget(
                    client: client,
                    onAuthenticated: () {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Successfully authenticated.'),
                          ),
                        );
                      }
                    },
                    onError: (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Authentication error: $error'),
                            backgroundColor: colors.error,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showSignInWidget = false;
                      });
                    },
                    child: const Text('Back to options'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
