import '../domain/forum_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ForumPostScreen extends ConsumerStatefulWidget {
  const ForumPostScreen({super.key});

  @override
  ConsumerState<ForumPostScreen> createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends ConsumerState<ForumPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Career Advice',
    'Technical',
    'Interview Prep',
    'Networking',
    'Industry Insights',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Discussion')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Start a discussion with the alumni community',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What do you want to discuss?',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Share your thoughts, questions, or insights...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _createPost,
              child: const Text('Post Discussion'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider).value;
    final post = ForumPost(
      id: '',
      authorId: currentUser?.uid ?? '',
      authorName: currentUser?.name ?? 'User',
      authorDepartment: currentUser?.department ?? '',
      authorYear: currentUser?.year ?? '',
      authorType: currentUser?.userType ?? 'student',
      category: _selectedCategory,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      views: 0,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      likedBy: [],
    );

    await ref.read(firestoreServiceProvider).createForumPost(post);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discussion posted successfully')),
      );
      Navigator.pop(context);
    }
  }
}
