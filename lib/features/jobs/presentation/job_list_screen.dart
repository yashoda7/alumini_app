import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/job_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/dashboard_widgets.dart';
import 'job_detail_screen.dart';
import 'job_post_screen.dart';

class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key, required this.canPost});

  final bool canPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Job Posts')),
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JobPostScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<JobPost>>(
        stream: firestoreService.watchJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(child: Text('No job posts yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final job = jobs[i];
              return ModernListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work, color: Colors.blue),
                ),
                title: Text(job.title),
                subtitle: Text(
                  '${job.company} • ${job.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          JobDetailScreen(job: job, canApply: !canPost),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
