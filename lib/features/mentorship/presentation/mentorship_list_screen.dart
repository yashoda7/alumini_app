import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/mentorship_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class MentorshipListScreen extends ConsumerWidget {
  const MentorshipListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mentorship Program')),
      body: StreamBuilder<List<MentorshipSlot>>(
        stream: firestoreService.watchMentorshipSlots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading mentorship slots',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          final slots = snapshot.data ?? [];

          if (slots.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No mentorship slots available',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Check back later for new mentorship opportunities',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MentorshipSlotCard(slot: slot),
              );
            },
          );
        },
      ),
    );
  }
}

class _MentorshipSlotCard extends ConsumerWidget {
  const _MentorshipSlotCard({required this.slot});

  final MentorshipSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isAvailable = slot.currentMentees < slot.maxMentees;

    return AppElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.mentorName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${slot.mentorDepartment} • ${slot.mentorYear} • ${slot.mentorCompany}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Full',
                  style: AppTextStyles.caption.copyWith(
                    color: isAvailable ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text(slot.expertise, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(slot.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${slot.currentMentees}/${slot.maxMentees} mentees',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (currentUser?.userType == 'student' && isAvailable)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showRequestDialog(context, ref),
                child: const Text('Request Mentorship'),
              ),
            ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context, WidgetRef ref) {
    final messageController = TextEditingController();
    final currentUser = ref.read(currentUserProvider).value;
    final firestoreService = ref.read(firestoreServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Mentorship'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a message to ${slot.mentorName}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Introduce yourself and explain why you want mentorship...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;

              final request = MentorshipRequest(
                id: '',
                slotId: slot.id,
                mentorId: slot.mentorId,
                menteeId: currentUser?.uid ?? '',
                menteeName: currentUser?.name ?? '',
                menteeDepartment: currentUser?.department ?? '',
                menteeYear: currentUser?.year ?? '',
                message: messageController.text.trim(),
                status: 'pending',
                createdAt: DateTime.now(),
              );

              await firestoreService.createMentorshipRequest(request);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mentorship request sent')),
                );
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
