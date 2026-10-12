import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notes_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';

// Data layer: repository menerima database opener.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// Domain layer: use case menerima kontrak repository.
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// Presentation layer: menyediakan state untuk halaman Notes.
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();

  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }

  return result.notes;
});