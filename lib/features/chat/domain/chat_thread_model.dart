import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThread {
  ChatThread({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageAt,
  });

  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessage;
  final String lastSenderId;
  final DateTime lastMessageAt;

  static DateTime _asDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static ChatThread fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChatThread(
      id: doc.id,
      participants: ((data['participants'] as List?) ?? [])
          .whereType<String>()
          .toList(),
      createdAt: _asDate(data['createdAt']),
      updatedAt: _asDate(data['updatedAt']),
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastSenderId: (data['lastSenderId'] as String?) ?? '',
      lastMessageAt: _asDate(data['lastMessageAt']),
    );
  }
}
