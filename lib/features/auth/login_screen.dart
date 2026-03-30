import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authError});

  final String? authError;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.student;
  bool _loading = false;
  String? _error;

  Future<void> _signIn(Future<void> Function(UserRole role) loginMethod) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await loginMethod(_selectedRole);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CCET Coderz Club (C3)',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Collaborate, build, discuss, and compete.'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Continue as'),
                    items: UserRole.values
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRole = value ?? UserRole.student),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _signIn(AuthService.signInWithGoogle),
                    icon: const Icon(Icons.mail),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _signIn(AuthService.signInWithGitHub),
                    icon: const Icon(Icons.code),
                    label: const Text('Continue with GitHub'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _signIn(AuthService.signInWithLinkedIn),
                    icon: const Icon(Icons.business_center),
                    label: const Text('Continue with LinkedIn'),
                  ),
                  if (widget.authError != null || _error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.authError ?? _error ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Note: Admin login works only for verified email t.gugan2005@gmail.com.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
