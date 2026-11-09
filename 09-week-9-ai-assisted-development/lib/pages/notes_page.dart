import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/note_repository.dart';
import '../data/local/note.dart';
import '../data/sync.dart';
import '../providers/offline_provider.dart';
import 'posts_page.dart';
import '../widgets/note_tile.dart';

import 'package:go_router/go_router.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final notesProvider = FutureProvider<List<Note>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(noteRepositoryProvider).searchNotes(query);
});

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Isi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop({'title': title, 'body': body});
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final repository = ref.read(noteRepositoryProvider);

    await repository.addNote(
      title: result['title']!,
      body: result['body'] ?? '',
    );

    ref.invalidate(notesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: forceOffline
                ? 'Sync tidak tersedia saat offline'
                : 'Sync Notes',
            icon: const Icon(Icons.sync),
            onPressed: forceOffline
                ? null
                : () async {
                    final repository = ref.read(noteRepositoryProvider);

                    final syncedCount = await syncNotes(repository);

                    ref.invalidate(notesProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            syncedCount == 0
                                ? 'Tidak ada catatan yang perlu '
                                      'disinkronkan.'
                                : '$syncedCount catatan berhasil '
                                      'disinkronkan.',
                          ),
                        ),
                      );
                    }
                  },
          ),
          IconButton(
            tooltip: 'Lihat Posts',
            icon: const Icon(Icons.article_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PostsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Force Offline'),
            subtitle: Text(
              forceOffline ? 'Simulasi offline aktif' : 'Simulasi online aktif',
            ),
            value: forceOffline,
            onChanged: (value) {
              ref.read(forceOfflineProvider.notifier).setOffline(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari judul catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (notes) {
                final dirtyCount = notes.where((note) => note.dirty).length;
                final query = ref.watch(searchQueryProvider).trim();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            'Dirty Notes: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Badge(label: Text('$dirtyCount')),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: notes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    query.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.note_alt_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    query.isNotEmpty
                                        ? 'Catatan dengan judul "$query" tidak ditemukan.'
                                        : 'Belum ada catatan.',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                return NoteTile(
                                  note: note,
                                  onTap: () {
                                    context.push('/note/${note.id}');
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $e'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(notesProvider);
                      },
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNote(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
