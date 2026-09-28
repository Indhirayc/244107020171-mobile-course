import 'package:dio/dio.dart';

import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan postId.
  /// Dio yang digunakan berasal dari api_client.dart,
  /// sehingga baseUrl dan timeout tetap terpusat.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {
        'postId': postId,
      },
    );

    final data = response.data ?? [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}