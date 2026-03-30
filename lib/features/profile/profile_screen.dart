import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final providers = user?.providerData.map((e) => e.providerId).toList() ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(radius: 34, child: Text((user?.displayName ?? 'U').substring(0, 1))),
        const SizedBox(height: 8),
        Center(
          child: Text(user?.displayName ?? 'No display name', style: Theme.of(context).textTheme.titleLarge),
        ),
        Center(child: Text(user?.email ?? 'No email')),
        const SizedBox(height: 20),
        const Text('Linked Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: providers.map((p) => Chip(label: Text(p))).toList(),
        ),
        const SizedBox(height: 16),
        _linkButton('Link Google', 'google.com'),
        _linkButton('Link GitHub', 'github.com'),
        _linkButton('Link LinkedIn', 'linkedin.com'),
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(_status!, style: const TextStyle(color: Colors.green)),
        ],
      ],
    );
  }

  Widget _linkButton(String text, String provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () async {
          try {
            await AuthService.linkProvider(provider);
            if (!mounted) return;
            setState(() => _status = '$text successful');
          } catch (e) {
            if (!mounted) return;
            setState(() => _status = 'Failed: $e');
          }
        },
        child: Text(text),
      ),
    );
  }
}
