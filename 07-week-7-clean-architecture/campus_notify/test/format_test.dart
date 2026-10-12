import 'package:campus_notify/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Format Date', () {
    test('mengubah tanggal menjadi DD/MM/YYYY', () {
      final date = DateTime(2026, 10, 12);

      expect(formatDate(date), '12/10/2026');
    });

    test('menambahkan angka nol pada tanggal dan bulan', () {
      final date = DateTime(2026, 1, 5);

      expect(formatDate(date), '05/01/2026');
    });
  });
}
