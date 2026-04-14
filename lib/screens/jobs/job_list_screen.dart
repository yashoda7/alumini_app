import 'package:flutter/material.dart';

import '../../models/job_model.dart';
import '../../services/firestore_service.dart';
import 'job_detail_screen.dart';
import 'job_post_screen.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({
    super.key,
    required this.firestoreService,
    required this.canPost,
    required this.currentUid,
  });

  final FirestoreService firestoreService;
  final bool canPost;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Posts')),
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JobPostScreen(
                      firestoreService: firestoreService,
                      currentUid: currentUid,
                    ),
                  ),
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
              return Card(
                child: ListTile(
                  title: Text(job.title),
                  subtitle: Text(
                    '${job.company} • ${job.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobDetailScreen(
                          job: job,
                          canApply: !canPost,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
