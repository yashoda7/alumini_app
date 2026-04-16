import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/dashboard_widgets.dart';
import '../../chat/presentation/chat_screen.dart';

class AlumniDirectoryScreen extends ConsumerStatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  ConsumerState<AlumniDirectoryScreen> createState() =>
      _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends ConsumerState<AlumniDirectoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final currentUser = ref.watch(currentUserProvider).value;
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
              stream: firestoreService.watchAlumniUsers(),
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
                final withoutSelf = currentUser == null
                    ? all
                    : all.where((u) => u.uid != currentUser.uid).toList();
                final filtered = _query.isEmpty
                    ? withoutSelf
                    : withoutSelf.where((u) {
                        final name = u.name.toLowerCase();
                        final dept = (u.department ?? '').toLowerCase();
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
                    return ModernListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade600.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.school, color: Colors.purple.shade600),
                      ),
                      title: Text(u.name),
                      subtitle: Text(
                        '${u.department ?? ''} • ${u.year ?? ''}',
                      ),
                      onTap: currentUser == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    currentUser: currentUser,
                                    otherUser: u,
                                  ),
                                ),
                              );
                            },
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
