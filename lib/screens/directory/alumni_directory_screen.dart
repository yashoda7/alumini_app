import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_screen.dart';

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({
    super.key,
    required this.firestoreService,
    required this.currentUser,
  });

  final FirestoreService firestoreService;
  final AppUser currentUser;

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alumni Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name / department',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                setState(() {
                  _query = v.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: widget.firestoreService.watchAlumniUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final withoutSelf = all
                    .where((u) => u.uid != widget.currentUser.uid)
                    .toList();
                final filtered = _query.isEmpty
                    ? withoutSelf
                    : withoutSelf.where((u) {
                        final name = u.name.toLowerCase();
                        final dept = u.department.toLowerCase();
                        return name.contains(_query) || dept.contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No alumni found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final u = filtered[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: Text(u.name),
                        subtitle: Text('${u.department} • ${u.year}'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                currentUser: widget.currentUser,
                                otherUser: u,
                                firestoreService: widget.firestoreService,
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
          ),
        ],
      ),
    );
  }
}
