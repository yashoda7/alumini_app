import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chat_thread_model.dart';
import '../../../core/models/user_model.dart';
import '../../../providers/app_providers.dart';
import 'chat_screen.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final Map<String, Future<AppUser?>> _userFutures = {};

  Future<AppUser?> _getUser(String uid) {
    return _userFutures.putIfAbsent(
      uid,
      () => ref.read(firestoreServiceProvider).getUser(uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<ChatThread>>(
        stream: firestoreService.watchUserChats(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(snapshot.error.toString()),
              ),
            );
          }

          final threads = snapshot.data ?? [];
          if (threads.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final t = threads[i];
              final otherId = t.participants.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => '',
              );

              return FutureBuilder<AppUser?>(
                future: _getUser(otherId),
                builder: (context, userSnap) {
                  final other = userSnap.data;
                  final title = (other?.name ?? 'User');
                  final subtitleInfo = other == null
                      ? ''
                      : '${other.department} • ${other.year}';
                  final last = t.lastMessage.isEmpty
                      ? 'Tap to open chat'
                      : t.lastMessage;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(title),
                      subtitle: Text(
                        subtitleInfo.isEmpty ? last : '$subtitleInfo\n$last',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: subtitleInfo.isNotEmpty,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: other == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    currentUser: currentUser,
                                    otherUser: other,
                                  ),
                                ),
                              );
                            },
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
