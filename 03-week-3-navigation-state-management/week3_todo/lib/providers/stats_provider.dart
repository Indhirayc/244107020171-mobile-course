import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier ini mengelola data statistik yang dimuat secara asynchronous.
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // Simulasi proses mengambil data dari server selama 2 detik.
    await Future.delayed(const Duration(seconds: 2));

    // Menghasilkan angka acak untuk mensimulasikan kemungkinan gagal 30%.
    final random = Random();

    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    // Data dikembalikan sebagai List baru sehingga tidak melakukan
    // mutasi langsung terhadap state.
    return [
      'Total Pengguna: 120',
      'Pengguna Aktif: 85',
      'Total Transaksi: 240',
    ];
  }
}

// Provider memiliki tipe eksplisit:
// AsyncNotifierProvider<StatsNotifier, List<String>>.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(
      StatsNotifier.new,
    );