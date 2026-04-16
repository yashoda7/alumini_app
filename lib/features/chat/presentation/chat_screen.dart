import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chat_message_model.dart';
import '../../../core/models/user_model.dart';
import '../../../providers/app_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  final AppUser currentUser;
  final AppUser otherUser;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  String? _chatId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final chatId = await firestoreService.getOrCreateChatId(
      widget.currentUser.uid,
      widget.otherUser.uid,
    );

    if (!mounted) return;
    setState(() {
      _chatId = chatId;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_chatId == null) return;

    _controller.clear();

    await ref
        .read(firestoreServiceProvider)
        .sendChatMessage(
          chatId: _chatId!,
          senderId: widget.currentUser.uid,
          text: text,
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUser.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: ref
                        .read(firestoreServiceProvider)
                        .watchChatMessages(_chatId!),
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

                      final messages = snapshot.data ?? [];
                      if (messages.isEmpty) {
                        return const Center(child: Text('Say hi'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final m = messages[i];
                          final isMe = m.senderId == widget.currentUser.uid;
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              constraints: const BoxConstraints(maxWidth: 320),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: isMe
                                    ? null
                                    : Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                              ),
                              child: Text(
                                m.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // IconButton.filled(
                        //   onPressed: _send,
                        //   icon: const Icon(Icons.send),
                        // ),
                        IconButton(
                          onPressed: _send,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
