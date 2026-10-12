import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => ErrorView(
          message: '$error',
          onRetry: () => ref.invalidate(notesProvider),
        ),
        data: (notes) => notes.isEmpty
            ? const Center(
                child: Text('Belum ada catatan.'),
              )
            : NotesList(notes: notes),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  const NotesList({
    super.key,
    required this.notes,
  });

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.body),
        );
      },
    );
  }
}