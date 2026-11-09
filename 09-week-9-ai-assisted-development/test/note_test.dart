import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week9_offline_notes/data/local/note.dart';
import 'package:week9_offline_notes/data/repositories/note_repository.dart';
import 'package:week9_offline_notes/pages/notes_page.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
    : super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) {
      throw Exception('db locked (simulasi)');
    }

    return items;
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    if (throwError) {
      throw Exception('db locked (simulasi)');
    }
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return items;
    }
    return items.where((n) => n.title.toLowerCase().contains(trimmed)).toList();
  }

  @override
  Future<int> countDirty() {
    return Future.value(items.where((n) => n.dirty).length);
  }
}

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final note = Note.fromMap({'title': 'Belanja'});

    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = Note(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );

    final restored = Note.fromMap(note.toMap());

    expect(restored.dirty, isTrue);
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(
            items: [Note(title: 'Tes', updatedAt: DateTime.now())],
          ),
        ),
      ],
    );

    addTearDown(container.dispose);

    final subscription = container.listen(
      notesProvider,
      (_, _) {},
      fireImmediately: true,
    );

    addTearDown(subscription.close);

    final notes = await container.read(notesProvider.future);

    expect(notes.length, 1);
    expect(notes.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(throwError: true),
        ),
      ],
    );

    addTearDown(container.dispose);

    final subscription = container.listen(
      notesProvider,
      (_, _) {},
      fireImmediately: true,
    );

    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(notesProvider);

    expect(state.hasError, isTrue);
    expect(state.error.toString(), contains('db locked (simulasi)'));
  });

  test('searchNotes menemukan catatan yang cocok berdasarkan judul (partial match)', () async {
    final repo = FakeNoteRepository(
      items: [
        Note(id: 1, title: 'Beli Susu', updatedAt: DateTime.now()),
        Note(id: 2, title: 'Kuliah Mobile', updatedAt: DateTime.now()),
        Note(id: 3, title: 'Belanja Mingguan', updatedAt: DateTime.now()),
      ],
    );

    final result = await repo.searchNotes('Beli');
    expect(result.length, 1);
    expect(result.first.title, 'Beli Susu');
  });

  test('searchNotes bersifat case-insensitive', () async {
    final repo = FakeNoteRepository(
      items: [
        Note(
          id: 1,
          title: 'FLUTTER CLEAN ARCHITECTURE',
          updatedAt: DateTime.now(),
        ),
        Note(id: 2, title: 'Dart dasar', updatedAt: DateTime.now()),
      ],
    );

    final result = await repo.searchNotes('flutter');
    expect(result.length, 1);
    expect(result.first.title, 'FLUTTER CLEAN ARCHITECTURE');
  });

  test('searchNotes mengembalikan list kosong (empty state) jika query tidak cocok', () async {
    final repo = FakeNoteRepository(
      items: [Note(id: 1, title: 'Catatan 1', updatedAt: DateTime.now())],
    );

    final result = await repo.searchNotes('xyz tidak ada');
    expect(result.isEmpty, isTrue);
  });

  test(
    'provider notesProvider reaktif terhadap perubahan searchQueryProvider',
    () async {
      final repo = FakeNoteRepository(
        items: [
          Note(id: 1, title: 'Pertemuan 9 AI', updatedAt: DateTime.now()),
          Note(id: 2, title: 'Tugas Mobile', updatedAt: DateTime.now()),
        ],
      );

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      container.listen(notesProvider, (_, _) {}, fireImmediately: true);

      // Initial state (query kosong) -> semua data
      final initialNotes = await container.read(notesProvider.future);
      expect(initialNotes.length, 2);

      // Ubah search query
      container.read(searchQueryProvider.notifier).setQuery('AI');
      final filteredNotes = await container.read(notesProvider.future);
      expect(filteredNotes.length, 1);
      expect(filteredNotes.first.title, 'Pertemuan 9 AI');
    },
  );
}
