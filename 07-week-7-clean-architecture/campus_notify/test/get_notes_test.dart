import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/repositories/note_repository.dart';
import 'package:campus_notify/features/notes/domain/usecases/get_notes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GetNotes Use Case', () {
    test('berhasil mengambil daftar catatan', () async {
      // Arrange
      final notes = [
        Note(
          id: 1,
          title: 'Catatan Pertama',
          body: 'Belajar Clean Architecture',
          updatedAt: DateTime(2026, 10, 12),
        ),
        Note(
          id: 2,
          title: 'Catatan Kedua',
          body: 'Membuat unit test',
          updatedAt: DateTime(2026, 10, 12),
        ),
      ];

      final repository = FakeNoteRepository(notes: notes);

      final getNotes = GetNotes(repository);

      // Act
      final result = await getNotes();

      // Assert
      expect(result.failure, isNull);
      expect(result.notes.length, 2);
      expect(result.notes.first.title, 'Catatan Pertama');
      expect(result.notes.last.title, 'Catatan Kedua');
      expect(repository.fetchCount, 1);
    });

    test('berhasil mengambil daftar catatan kosong', () async {
      // Arrange
      final repository = FakeNoteRepository(notes: []);

      final getNotes = GetNotes(repository);

      // Act
      final result = await getNotes();

      // Assert
      expect(result.failure, isNull);
      expect(result.notes, isEmpty);
      expect(repository.fetchCount, 1);
    });

    test('mengembalikan Failure ketika pengambilan catatan gagal', () async {
      // Arrange
      final repository = FakeNoteRepository(
        failure: const LocalFailure('Gagal mengambil catatan'),
      );

      final getNotes = GetNotes(repository);

      // Act
      final result = await getNotes();

      // Assert
      expect(result.notes, isEmpty);
      expect(result.failure, isA<LocalFailure>());
      expect(result.failure?.message, 'Gagal mengambil catatan');
      expect(repository.fetchCount, 1);
    });
  });
}

// Fake repository untuk menguji domain tanpa database.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.notes = const [], this.failure});

  final List<Note> notes;
  final Failure? failure;

  int fetchCount = 0;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    fetchCount++;

    if (failure != null) {
      return (notes: <Note>[], failure: failure);
    }

    return (notes: notes, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    return (
      note: null,
      failure: const LocalFailure(
        'addNote tidak digunakan dalam pengujian GetNotes',
      ),
    );
  }
}
