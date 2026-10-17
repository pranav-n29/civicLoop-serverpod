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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 16 : 24,
        vertical: 20,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 16 : 22,
        vertical: 16,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        screenWidth < 400 ? 16 : 22,
        18,
        screenWidth < 400 ? 16 : 22,
        0,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Row(
        children: [
          Icon(
            _isSignedIn ? Icons.account_circle : Icons.person_outline,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _isSignedIn ? 'Account Profile' : 'Sign In / Account',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Expanded(
                            child: Text(
                              'Authenticated Session',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                  _ResponsiveEmailAuthWidget(
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
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_back, size: 16),
                      onPressed: () {
                        setState(() {
                          _showSignInWidget = false;
                        });
                      },
                      label: const Text('Back to options'),
                    ),
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

/// Fully responsive email authentication form that wraps buttons and links,
/// accommodates small screen widths, and supports login, registration,
/// verification, and password reset flows with EmailAuthController.
class _ResponsiveEmailAuthWidget extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final ValueChanged<String>? onError;

  const _ResponsiveEmailAuthWidget({
    required this.onAuthenticated,
    this.onError,
  });

  @override
  State<_ResponsiveEmailAuthWidget> createState() =>
      _ResponsiveEmailAuthWidgetState();
}

class _ResponsiveEmailAuthWidgetState
    extends State<_ResponsiveEmailAuthWidget> {
  late final EmailAuthController _controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = EmailAuthController(
      client: client,
      onAuthenticated: widget.onAuthenticated,
      onError: (err) {
        widget.onError?.call(err.toString());
      },
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_controller.errorMessage != null &&
            _controller.state == EmailAuthState.error) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: colors.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _controller.errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        switch (_controller.currentScreen) {
          EmailFlowScreen.login => _buildLoginForm(theme, colors),
          EmailFlowScreen.startRegistration => _buildStartRegistrationForm(
            theme,
            colors,
          ),
          EmailFlowScreen.verifyRegistration => _buildVerifyRegistrationForm(
            theme,
            colors,
          ),
          EmailFlowScreen.completeRegistration =>
            _buildCompleteRegistrationForm(theme, colors),
          EmailFlowScreen.requestPasswordReset =>
            _buildRequestPasswordResetForm(theme, colors),
          EmailFlowScreen.verifyPasswordReset => _buildVerifyPasswordResetForm(
            theme,
            colors,
          ),
          EmailFlowScreen.completePasswordReset =>
            _buildCompletePasswordResetForm(theme, colors),
        },
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sign In',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your email and password to access your account.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () =>
                _controller.navigateTo(EmailFlowScreen.requestPasswordReset),
            child: const Text(
              'Forgot password?',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 4),
        FilledButton(
          onPressed: _controller.isLoading ? null : () => _controller.login(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Sign In'),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            TextButton(
              onPressed: () =>
                  _controller.navigateTo(EmailFlowScreen.startRegistration),
              child: const Text('Sign up', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartRegistrationForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create Account',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your email address to receive a verification code.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _controller.isLoading
              ? null
              : () => _controller.startRegistration(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Continue'),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            TextButton(
              onPressed: () => _controller.navigateTo(EmailFlowScreen.login),
              child: const Text('Sign in', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifyRegistrationForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Verify Email',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the verification code sent to ${_controller.emailController.text.trim()}.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.verificationCodeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Verification Code',
            prefixIcon: const Icon(Icons.pin, size: 20),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _controller.isLoading
              ? null
              : () => _controller.verifyRegistrationCode(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Verify Code'),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton(
              onPressed: _controller.isLoading
                  ? null
                  : () => _controller.resendVerificationCode(),
              child: const Text('Resend code', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () =>
                  _controller.navigateTo(EmailFlowScreen.startRegistration),
              child: const Text('Change email', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompleteRegistrationForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Set Password',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a password for your account.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _controller.isLoading
              ? null
              : () => _controller.finishRegistration(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Complete Registration'),
        ),
      ],
    );
  }

  Widget _buildRequestPasswordResetForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Reset Password',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your email to receive a password reset code.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _controller.isLoading
              ? null
              : () => _controller.startPasswordReset(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Reset Code'),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => _controller.navigateTo(EmailFlowScreen.login),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyPasswordResetForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Verify Reset Code',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the code sent to your email to verify password reset.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.verificationCodeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Verification Code',
            prefixIcon: const Icon(Icons.pin, size: 20),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _controller.isLoading
              ? null
              : () => _controller.verifyPasswordResetCode(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Verify Code'),
        ),
      ],
    );
  }

  Widget _buildCompletePasswordResetForm(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'New Password',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your new password.',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _controller.isLoading
              ? null
              : () => _controller.finishPasswordReset(),
          child: _controller.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Reset Password & Sign In'),
        ),
      ],
    );
  }
}
