import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'project_upload_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key, required this.role});

  final String role;

  bool get canPickBest => role == UserRole.staff.name || role == UserRole.admin.name;

  @override
  Widget build(BuildContext context) {
    final projectsCollection = FirebaseFirestore.instance.collection(AppCollections.projects);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: projectsCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No projects yet. Upload one!'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final stars = (data['starredBy'] as List<dynamic>? ?? []);
              final isStarred = uid != null && stars.contains(uid);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text(data['title'] as String? ?? 'Untitled'),
                  subtitle: Text((data['tags'] as List<dynamic>? ?? []).join(', ')),
                  childrenPadding: const EdgeInsets.all(12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['description'] as String? ?? ''),
                    const SizedBox(height: 8),
                    Text('Author: ${data['authorName'] ?? 'Unknown'}'),
                    Text('Links: ${(data['links'] as List<dynamic>? ?? []).join(', ')}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: uid == null
                              ? null
                              : () => doc.reference.update({
                                    'starredBy': isStarred
                                        ? FieldValue.arrayRemove([uid])
                                        : FieldValue.arrayUnion([uid]),
                                  }),
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: isStarred ? Colors.amber : null,
                          ),
                        ),
                        Text('${stars.length} stars'),
                        const Spacer(),
                        if (canPickBest)
                          TextButton.icon(
                            onPressed: () async {
                              final batch = FirebaseFirestore.instance.batch();
                              final currentBest = await projectsCollection
                                  .where('isBestProjectOfWeek', isEqualTo: true)
                                  .get();
                              for (final bestDoc in currentBest.docs) {
                                batch.update(bestDoc.reference, {'isBestProjectOfWeek': false});
                              }
                              batch.update(doc.reference, {'isBestProjectOfWeek': true});
                              await batch.commit();
                            },
                            icon: const Icon(Icons.workspace_premium),
                            label: const Text('Mark Best of Week'),
                          ),
                      ],
                    ),
                    const Divider(),
                    const Text('Discussion'),
                    _DiscussionThread(projectId: doc.id),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectUploadScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
      ),
    );
  }
}

class _DiscussionThread extends StatefulWidget {
  const _DiscussionThread({required this.projectId});

  final String projectId;

  @override
  State<_DiscussionThread> createState() => _DiscussionThreadState();
}

class _DiscussionThreadState extends State<_DiscussionThread> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final commentsRef = FirebaseFirestore.instance
        .collection(AppCollections.projects)
        .doc(widget.projectId)
        .collection(AppCollections.comments)
        .orderBy('createdAt', descending: true);

    return Column(
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: commentsRef.snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            return Column(
              children: docs
                  .map((e) => ListTile(
                        dense: true,
                        title: Text(e['text'] as String? ?? ''),
                        subtitle: Text(e['authorName'] as String? ?? 'Anonymous'),
                      ))
                  .toList(),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Add a comment...'),
              ),
            ),
            IconButton(
              onPressed: uid == null
                  ? null
                  : () async {
                      if (_controller.text.trim().isEmpty) return;
                      final user = FirebaseAuth.instance.currentUser;
                      await FirebaseFirestore.instance
                          .collection(AppCollections.projects)
                          .doc(widget.projectId)
                          .collection(AppCollections.comments)
                          .add({
                        'text': _controller.text.trim(),
                        'authorId': uid,
                        'authorName': user?.displayName ?? user?.email ?? 'User',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      _controller.clear();
                    },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}
