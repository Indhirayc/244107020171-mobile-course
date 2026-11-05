import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validasi Judul Notes', () {
    test('menolak judul kosong', () {
      expect(''.trim().isEmpty, isTrue);
    });

    test('menolak judul berisi spasi', () {
      expect('   '.trim().isEmpty, isTrue);
    });

    test('menerima judul valid', () {
      expect('Belajar Flutter'.trim().isEmpty, isFalse);
    });
  });
}