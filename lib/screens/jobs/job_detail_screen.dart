import 'package:flutter/material.dart';

import '../../models/job_model.dart';
import '../../utils/link_utils.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({
    super.key,
    required this.job,
    required this.canApply,
  });

  final JobPost job;
  final bool canApply;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      bottomNavigationBar: canApply
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: job.applyLink.trim().isEmpty
                      ? null
                      : () => openExternalLink(context, job.applyLink),
                  child: const Text('Apply'),
                ),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(job.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(job.company),
          const SizedBox(height: 16),
          if (job.location.isNotEmpty) _InfoRow(label: 'Location', value: job.location),
          if (job.package.isNotEmpty) _InfoRow(label: 'Package', value: job.package),
          if (job.experience.isNotEmpty)
            _InfoRow(label: 'Experience', value: job.experience),
          _InfoRow(
            label: 'Immediate joining',
            value: job.immediateJoining ? 'Yes' : 'No',
          ),
          const SizedBox(height: 12),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(job.description),
          const SizedBox(height: 12),
          if (job.requiredSkills.isNotEmpty) ...[
            Text('Required skills',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.requiredSkills
                  .map(
                    (s) => Chip(label: Text(s)),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          if (!canApply && job.applyLink.trim().isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => openExternalLink(context, job.applyLink),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open apply link'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
