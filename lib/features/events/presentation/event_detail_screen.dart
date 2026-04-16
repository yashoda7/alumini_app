import 'package:flutter/material.dart';

import '../domain/event_model.dart';
import '../../../core/utils/link_utils.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    required this.canOpenLink,
  });

  final AppEvent event;
  final bool canOpenLink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(event.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(event.location),
          const SizedBox(height: 6),
          Text('Date: ${event.eventDate.toLocal()}'),
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(event.description),
          const SizedBox(height: 16),
          if (event.eventLink.trim().isNotEmpty) ...[
            ElevatedButton.icon(
              onPressed: () => openExternalLink(context, event.eventLink),
              icon: const Icon(Icons.open_in_new),
              label: Text(canOpenLink ? 'Open event link' : 'Open'),
            ),
          ],
        ],
      ),
    );
  }
}
