import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/event_model.dart';
import '../../../providers/app_providers.dart';

class EventCreateScreen extends ConsumerStatefulWidget {
  const EventCreateScreen({super.key});

  @override
  ConsumerState<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends ConsumerState<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _title = '';
  String _location = '';
  String _eventLink = '';
  String _description = '';
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked == null) return;
    setState(() {
      _eventDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _eventDate.hour,
        _eventDate.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
    });

    try {
      final event = AppEvent(
        id: '',
        title: _title,
        description: _description,
        location: _location,
        eventLink: _eventLink,
        eventDate: _eventDate,
        createdBy: ref.read(currentUserProvider).value?.uid ?? '',
        createdAt: DateTime.now(),
      );
      await ref.read(firestoreServiceProvider).createEvent(event);

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
      appBar: AppBar(title: const Text('Create Event')),
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
                            labelText: 'Location',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter location';
                            }
                            return null;
                          },
                          onSaved: (v) => _location = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Event link',
                            hintText: 'https://...',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter event link';
                            }
                            return null;
                          },
                          onSaved: (v) => _eventLink = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.date_range),
                          label: Text('Event date: ${_eventDate.toLocal()}'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 5,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter description';
                            }
                            return null;
                          },
                          onSaved: (v) => _description = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: Text(_loading ? 'Creating...' : 'Create'),
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
