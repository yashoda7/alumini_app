import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/event_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/dashboard_widgets.dart';
import 'event_detail_screen.dart';
import 'event_create_screen.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key, required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EventCreateScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<AppEvent>>(
        stream: firestoreService.watchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final event = events[i];
              return ModernListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event, color: Colors.green.shade600),
                ),
                title: Text(event.title),
                subtitle: Text(
                  '${event.location} • ${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          EventDetailScreen(event: event, canOpenLink: true),
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
