import 'package:hive/hive.dart';

import 'comment_model.dart';
part 'post_model.g.dart';

@HiveType(typeId: 0)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final List<String> mediaPaths;

  @HiveField(3)
  final String visibility; // 'Public', 'Friends', 'Only Me'

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  int likes;

  @HiveField(6)
  bool isLiked;

  @HiveField(7)
  List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.content,
    required this.mediaPaths,
    required this.visibility,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    List<CommentModel>? comments,
  }) : comments = comments ?? [];

  // To help with debugging
  @override
  String toString() {
    return 'PostModel(id: $id, content: $content, media: ${mediaPaths.length}, visibility: $visibility)';
  }
}
