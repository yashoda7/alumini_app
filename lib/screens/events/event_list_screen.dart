import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/firestore_service.dart';
import 'event_detail_screen.dart';
import 'event_create_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({
    super.key,
    required this.firestoreService,
    required this.canCreate,
    required this.currentUid,
  });

  final FirestoreService firestoreService;
  final bool canCreate;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventCreateScreen(
                      firestoreService: firestoreService,
                      currentUid: currentUid,
                    ),
                  ),
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
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(event.title),
                  subtitle: Text(event.location),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(
                          event: event,
                          canOpenLink: true,
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
