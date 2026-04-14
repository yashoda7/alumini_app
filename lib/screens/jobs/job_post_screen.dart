import 'package:flutter/material.dart';

import '../../models/job_model.dart';
import '../../services/firestore_service.dart';

class JobPostScreen extends StatefulWidget {
  const JobPostScreen({
    super.key,
    required this.firestoreService,
    required this.currentUid,
  });

  final FirestoreService firestoreService;
  final String currentUid;

  @override
  State<JobPostScreen> createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _title = '';
  String _company = '';
  String _location = '';
  String _package = '';
  String _experience = '';
  String _skillsCsv = '';
  bool _immediateJoining = false;
  String _description = '';
  String _applyLink = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
    });

    try {
      final job = JobPost(
        id: '',
        title: _title,
        company: _company,
        location: _location,
        package: _package,
        experience: _experience,
        requiredSkills: _skillsCsv
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        immediateJoining: _immediateJoining,
        description: _description,
        applyLink: _applyLink,
        createdBy: widget.currentUid,
        createdAt: DateTime.now(),
      );
      await widget.firestoreService.createJob(job);

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
      appBar: AppBar(title: const Text('Post Job')),
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
                          decoration: const InputDecoration(labelText: 'Company'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter company';
                            }
                            return null;
                          },
                          onSaved: (v) => _company = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Location'),
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
                            labelText: 'Package (e.g. 6 LPA)',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter package';
                            }
                            return null;
                          },
                          onSaved: (v) => _package = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Experience (e.g. 0-1 years)',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter experience requirement';
                            }
                            return null;
                          },
                          onSaved: (v) => _experience = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Required skills (comma separated)',
                            hintText: 'Flutter, Firebase, Git',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter at least 1 skill';
                            }
                            return null;
                          },
                          onSaved: (v) => _skillsCsv = v!.trim(),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Immediate joining required?'),
                          value: _immediateJoining,
                          onChanged: (v) {
                            setState(() {
                              _immediateJoining = v;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Description'),
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
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Apply link',
                            hintText: 'https://...',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter apply link';
                            }
                            return null;
                          },
                          onSaved: (v) => _applyLink = v!.trim(),
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
