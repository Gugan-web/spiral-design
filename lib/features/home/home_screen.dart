import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../auth/auth_service.dart';
import '../contests/contest_list_screen.dart';
import '../profile/profile_screen.dart';
import '../projects/project_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.role});

  final String role;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(role: widget.role),
      ProjectListScreen(role: widget.role),
      ContestListScreen(role: widget.role),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CCET Coderz Club (C3)'),
        actions: [
          IconButton(
            onPressed: AuthService.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Contests'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final projectsCollection = FirebaseFirestore.instance.collection(AppCollections.projects);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Featured Projects', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: projectsCollection.where('isFeatured', isEqualTo: true).limit(10).snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return const Card(child: ListTile(title: Text('No featured projects yet.')));
            return Column(
              children: docs
                  .map(
                    (doc) => Card(
                      child: ListTile(
                        title: Text(doc['title'] as String? ?? 'Untitled'),
                        subtitle: Text(doc['description'] as String? ?? ''),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text('Best Project of the Week', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: projectsCollection.where('isBestProjectOfWeek', isEqualTo: true).limit(1).snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            final project = docs.isNotEmpty ? docs.first : null;
            if (project == null) {
              return const Card(child: ListTile(title: Text('No best project selected this week.')));
            }
            return Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                title: Text(project['title'] as String? ?? 'Untitled'),
                subtitle: Text(project['description'] as String? ?? ''),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Signed in as: ${role.toUpperCase()}'),
      ],
    );
  }
}
