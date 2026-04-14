import 'package:flutter/material.dart';

import '../../models/announcement_model.dart';
import '../../services/firestore_service.dart';

class AnnouncementPostScreen extends StatefulWidget {
  const AnnouncementPostScreen({
    super.key,
    required this.firestoreService,
    required this.currentUid,
  });

  final FirestoreService firestoreService;
  final String currentUid;

  @override
  State<AnnouncementPostScreen> createState() => _AnnouncementPostScreenState();
}

class _AnnouncementPostScreenState extends State<AnnouncementPostScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _title = '';
  String _message = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
    });

    try {
      final a = Announcement(
        id: '',
        title: _title,
        message: _message,
        createdBy: widget.currentUid,
        createdAt: DateTime.now(),
      );

      await widget.firestoreService.createAnnouncement(a);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Announcement')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter title';
                            }
                            return null;
                          },
                          onSaved: (v) => _title = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Message'),
                          maxLines: 6,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter message';
                            }
                            return null;
                          },
                          onSaved: (v) => _message = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: Text(_loading ? 'Posting...' : 'Post'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
