import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';

class ContestListScreen extends StatelessWidget {
  const ContestListScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final contests = FirebaseFirestore.instance
        .collection(AppCollections.contests)
        .orderBy('startDate')
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: contests,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No contests announced yet.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final contest = docs[index];
              final participants = contest['participants'] as List<dynamic>? ?? [];
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final joined = uid != null && participants.contains(uid);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(contest['title'] as String? ?? 'Contest'),
                  subtitle: Text(
                    '${contest['description'] ?? ''}\n${_formatDate(contest['startDate'])}',
                  ),
                  isThreeLine: true,
                  trailing: FilledButton(
                    onPressed: uid == null
                        ? null
                        : () => contest.reference.update({
                              'participants': joined
                                  ? FieldValue.arrayRemove([uid])
                                  : FieldValue.arrayUnion([uid]),
                            }),
                    child: Text(joined ? 'Leave' : 'Participate'),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContestDetailScreen(contestId: contest.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw is! Timestamp) return 'Date TBD';
    return DateFormat('dd MMM yyyy, hh:mm a').format(raw.toDate());
  }
}

class ContestDetailScreen extends StatelessWidget {
  const ContestDetailScreen({super.key, required this.contestId});

  final String contestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contest Details')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection(AppCollections.contests)
            .doc(contestId)
            .get(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final participants = data['participants'] as List<dynamic>? ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(data['description'] ?? ''),
              const SizedBox(height: 10),
              Text('Rules: ${data['rules'] ?? 'Will be announced soon'}'),
              const SizedBox(height: 10),
              Text('Participants: ${participants.length}'),
            ],
          );
        },
      ),
    );
  }
}
