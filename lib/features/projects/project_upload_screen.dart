import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

class ProjectUploadScreen extends StatefulWidget {
  const ProjectUploadScreen({super.key});

  @override
  State<ProjectUploadScreen> createState() => _ProjectUploadScreenState();
}

class _ProjectUploadScreenState extends State<ProjectUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _links = TextEditingController();
  final _tags = TextEditingController();
  final _images = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection(AppCollections.projects).add({
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'links': _links.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'tags': _tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'imageUrls': _images.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'authorId': user?.uid,
      'authorName': user?.displayName ?? user?.email ?? 'User',
      'isFeatured': false,
      'isBestProjectOfWeek': false,
      'starredBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Project')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: _required),
            TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4, validator: _required),
            TextFormField(controller: _links, decoration: const InputDecoration(labelText: 'Project links (comma separated)')),
            TextFormField(controller: _images, decoration: const InputDecoration(labelText: 'Image URLs (comma separated)')),
            TextFormField(controller: _tags, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Publish Project')),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required field' : null;
}
