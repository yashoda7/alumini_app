import 'resource_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/resource_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceListScreen extends ConsumerWidget {
  const ResourceListScreen({super.key, required this.canUpload});

  final bool canUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Library'),
        actions: [
          if (canUpload)
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResourceUploadScreen()),
              ),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: StreamBuilder<List<Resource>>(
        stream: firestoreService.watchResources(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading resources',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          final resources = snapshot.data ?? [];

          if (resources.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('No resources yet', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Resources shared by alumni will appear here',
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
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ResourceCard(resource: resource),
              );
            },
          );
        },
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResourceDetailScreen(resource: resource),
        ),
      ),
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
                  _getTypeIcon(resource.type),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'By ${resource.authorName}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    resource.rating.toStringAsFixed(1),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            resource.description,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: resource.tags.take(3).map((tag) {
              return Chip(
                label: Text(tag, style: AppTextStyles.caption),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('${resource.viewCount}', style: AppTextStyles.caption),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.download_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('${resource.downloadCount}', style: AppTextStyles.caption),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.rate_review_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('${resource.reviewCount}', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'document':
        return Icons.description_outlined;
      case 'video':
        return Icons.play_circle_outlined;
      case 'link':
        return Icons.link_outlined;
      case 'tutorial':
        return Icons.school_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class ResourceDetailScreen extends ConsumerStatefulWidget {
  const ResourceDetailScreen({super.key, required this.resource});

  final Resource resource;

  @override
  ConsumerState<ResourceDetailScreen> createState() =>
      _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(firestoreServiceProvider)
        .incrementResourceViews(widget.resource.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: [
          IconButton(
            onPressed: _downloadResource,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: Icon(
                          _getTypeIcon(widget.resource.type),
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resource.title,
                              style: AppTextStyles.headingSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'By ${widget.resource.authorName}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.resource.rating.toStringAsFixed(1),
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '(${widget.resource.reviewCount} reviews)',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Description', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.resource.description,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Tags', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: widget.resource.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${widget.resource.viewCount} views',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.download_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${widget.resource.downloadCount} downloads',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openResource,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Resource'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            SectionHeader(
              title: 'Reviews',
              subtitle: '${widget.resource.reviewCount} reviews',
            ),
            StreamBuilder<List<ResourceReview>>(
              stream: ref
                  .read(firestoreServiceProvider)
                  .watchResourceReviews(widget.resource.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reviews = snapshot.data ?? [];

                if (reviews.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'No reviews yet',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: _showReviewDialog,
                            child: const Text('Write a Review'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...reviews.map((review) => _ReviewCard(review: review)),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: ElevatedButton(
                        onPressed: _showReviewDialog,
                        child: const Text('Write a Review'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'document':
        return Icons.description_outlined;
      case 'video':
        return Icons.play_circle_outlined;
      case 'link':
        return Icons.link_outlined;
      case 'tutorial':
        return Icons.school_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _downloadResource() async {
    final url = widget.resource.url;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid resource URL')));
      return;
    }

    final Uri uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Increment download count AFTER successful launch
      ref
          .read(firestoreServiceProvider)
          .incrementResourceDownloads(widget.resource.id);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download started')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download resource')),
      );
    }
  }

  void _openResource() async {
    final url = widget.resource.url; // make sure this field exists

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // opens in browser/app
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${widget.resource.title}')),
      );
    }
  }

  void _showReviewDialog() {
    final ratingController = TextEditingController(text: '5');
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Write a Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rating (1-5)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Comment'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final rating = int.tryParse(ratingController.text) ?? 5;
              final currentUser = ref.read(currentUserProvider).value;
              final review = ResourceReview(
                id: '',
                resourceId: widget.resource.id,
                reviewerId: currentUser?.uid ?? '',
                reviewerName: currentUser?.name ?? 'User',
                rating: rating.clamp(1, 5),
                comment: commentController.text.trim(),
                createdAt: DateTime.now(),
              );
              ref.read(firestoreServiceProvider).createResourceReview(review);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Review submitted')));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ResourceReview review;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.reviewerName, style: AppTextStyles.titleSmall),
              const SizedBox(width: AppSpacing.sm),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.comment, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
