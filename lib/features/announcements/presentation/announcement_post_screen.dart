import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/announcement_model.dart';
import '../../../providers/app_providers.dart';

class AnnouncementPostScreen extends ConsumerStatefulWidget {
  const AnnouncementPostScreen({super.key});

  @override
  ConsumerState<AnnouncementPostScreen> createState() =>
      _AnnouncementPostScreenState();
}

class _AnnouncementPostScreenState
    extends ConsumerState<AnnouncementPostScreen> {
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
        createdBy: ref.read(currentUserProvider).value?.uid ?? '',
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createAnnouncement(a);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                          decoration: const InputDecoration(
                            labelText: 'Message',
                          ),
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
