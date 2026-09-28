import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers.dart';

class PostDetailNotifier extends AsyncNotifier<Post> {
  PostDetailNotifier(this.postId);

  final int postId;

  @override
  Future<Post> build() async {
    final repository = ref.watch(postRepositoryProvider);

    return repository.fetchPostById(postId);
  }
}

final postDetailProvider =
    AsyncNotifierProvider.family<PostDetailNotifier, Post, int>(
  PostDetailNotifier.new,
);