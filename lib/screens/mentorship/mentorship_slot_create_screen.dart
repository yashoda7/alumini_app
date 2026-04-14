import 'package:flutter/material.dart';

import '../../models/mentorship_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class MentorshipSlotCreateScreen extends StatefulWidget {
  const MentorshipSlotCreateScreen({
    super.key,
    required this.user,
    required this.firestoreService,
  });

  final AppUser user;
  final FirestoreService firestoreService;

  @override
  State<MentorshipSlotCreateScreen> createState() =>
      _MentorshipSlotCreateScreenState();
}

class _MentorshipSlotCreateScreenState
    extends State<MentorshipSlotCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expertiseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _companyController = TextEditingController();
  int _maxMentees = 5;

  @override
  void dispose() {
    _expertiseController.dispose();
    _descriptionController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Mentorship Slot'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Share your expertise and mentor students',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company/Organization',
                hintText: 'Where do you work?',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your company';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _expertiseController,
              decoration: const InputDecoration(
                labelText: 'Area of Expertise',
                hintText: 'e.g., Software Engineering, Data Science, Product Management',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your expertise';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what you can help mentees with...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Maximum Mentees',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSpacing.sm),
            Slider(
              value: _maxMentees.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: '$_maxMentees mentees',
              onChanged: (value) {
                setState(() {
                  _maxMentees = value.round();
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _createSlot,
              child: const Text('Create Mentorship Slot'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSlot() async {
    if (!_formKey.currentState!.validate()) return;

    final slot = MentorshipSlot(
      id: '',
      mentorId: widget.user.uid,
      mentorName: widget.user.name,
      mentorDepartment: widget.user.department,
      mentorCompany: _companyController.text.trim(),
      mentorYear: widget.user.year,
      expertise: _expertiseController.text.trim(),
      description: _descriptionController.text.trim(),
      maxMentees: _maxMentees,
      currentMentees: 0,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await widget.firestoreService.createMentorshipSlot(slot);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mentorship slot created successfully')),
      );
      Navigator.pop(context);
    }
  }
}
