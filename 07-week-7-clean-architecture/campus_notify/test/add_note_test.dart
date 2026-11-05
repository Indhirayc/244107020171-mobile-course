
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/repositories/note_repository.dart';
import 'package:campus_notify/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddNote Use Case', () {
    test('menolak judul kosong', () async {
      // Arrange
      final repository = FakeNoteRepository();
      final addNote = AddNote(repository);

      // Act
      final result = await addNote(title: '');

      // Assert
      expect(result.note, isNull);
      expect(result.failure, isA<LocalFailure>());
      expect(
        result.failure?.message,
        'Judul catatan tidak boleh kosong',
      );
      expect(repository.addCount, 0);
    });

    test('menolak judul yang hanya berisi spasi', () async {
      // Arrange
      final repository = FakeNoteRepository();
      final addNote = AddNote(repository);

      // Act
      final result = await addNote(title: '   ');

      // Assert
      expect(result.note, isNull);
      expect(result.failure, isA<LocalFailure>());
      expect(repository.addCount, 0);
    });

    test('menerima judul valid dan meneruskannya setelah trim', () async {
      // Arrange
      final repository = FakeNoteRepository();
      final addNote = AddNote(repository);

      // Act
      final result = await addNote(
        title: '  Belajar Flutter  ',
        body: 'Mempelajari Clean Architecture',
      );

      // Assert
      expect(result.failure, isNull);
      expect(result.note, isNotNull);
      expect(result.note?.title, 'Belajar Flutter');
      expect(result.note?.body, 'Mempelajari Clean Architecture');
      expect(repository.addCount, 1);
      expect(repository.lastTitle, 'Belajar Flutter');
      expect(repository.lastBody, 'Mempelajari Clean Architecture');
    });

    test('meneruskan Failure dari repository', () async {
      // Arrange
      final repository = FakeNoteRepository(
        failure: const LocalFailure('Gagal menyimpan catatan'),
      );
      final addNote = AddNote(repository);

      // Act
      final result = await addNote(title: 'Catatan Valid');

      // Assert
      expect(result.note, isNull);
      expect(result.failure, isA<LocalFailure>());
      expect(result.failure?.message, 'Gagal menyimpan catatan');
      expect(repository.addCount, 1);
    });
  });
}

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.failure});

  final Failure? failure;

  int addCount = 0;
  String? lastTitle;
  String? lastBody;

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCount++;
    lastTitle = title;
    lastBody = body;

    if (failure != null) {
      return (note: null, failure: failure);
    }

    return (
      note: Note(
        id: 1,
        title: title,
        body: body,
        updatedAt: DateTime(2026, 11, 5),
        dirty: true,
      ),
      failure: null,
    );
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (
      notes: <Note>[],
      failure: null,
    );
  }
}