import 'package:hive/hive.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 1)
class CommentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.username,
    required this.content,
    required this.createdAt,
  });
}
