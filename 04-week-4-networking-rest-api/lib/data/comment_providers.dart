import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Provider untuk CommentRepository.
/// Menggunakan Dio yang sama dari dioProvider,
/// sehingga konfigurasi API tetap terpusat.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier untuk mengambil comments berdasarkan postId.
/// Error yang dilempar repository secara otomatis
/// akan menjadi AsyncError.
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);

  final int postId;

  @override
  Future<List<Comment>> build() async {
    final repository = ref.watch(commentRepositoryProvider);

    return repository.fetchComments(postId);
  }
}

/// Provider family digunakan karena comments
/// bergantung pada postId yang dipilih.
final commentsProvider = AsyncNotifierProvider.family<
    CommentsNotifier,
    List<Comment>,
    int>(
  CommentsNotifier.new,
);