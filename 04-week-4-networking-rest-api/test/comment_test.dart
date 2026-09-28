import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('menggunakan nilai default ketika field hilang', () {
      final json = <String, dynamic>{
        'postId': 1,
        'id': 2,
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 2);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('menggunakan nilai default ketika semua field null', () {
      final json = <String, dynamic>{
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });
  });
}