import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget digunakan karena halaman perlu mengamati provider Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch digunakan di dalam build agar UI otomatis diperbarui
    // ketika state statsProvider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),

      body: statsAsync.when(
        // State loading ditampilkan ketika data sedang diambil.
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // State error menampilkan pesan kesalahan dan tombol retry.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              const SizedBox(height: 12),
              FilledButton(
                // Provider di-invalidasi agar proses pengambilan data
                // dijalankan kembali.
                onPressed: () {
                  ref.invalidate(statsProvider);
                },
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),

        // State success menampilkan tiga data statistik.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(stats[index]),
            );
          },
        ),
      ),

      // NavigationBar untuk berpindah antara halaman ToDo dan Statistik.
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'ToDo',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}