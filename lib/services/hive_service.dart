import 'package:hive_flutter/hive_flutter.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class HiveService {
  static const String boxName = 'posts';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PostModelAdapter());
    Hive.registerAdapter(CommentModelAdapter());
    await Hive.openBox<PostModel>(boxName);
  }

  static Box<PostModel> get _box => Hive.box<PostModel>(boxName);

  static Future<void> savePost(PostModel post) async {
    await _box.put(post.id, post);
  }

  static List<PostModel> getPosts() {
    return _box.values.toList();
  }

  static Future<void> toggleLike(String postId) async {
    final post = _box.get(postId);
    if (post != null) {
      post.isLiked = !post.isLiked;
      post.likes = post.isLiked ? post.likes + 1 : post.likes - 1;
      await post.save();
    }
  }

  static Future<void> addComment(String postId, CommentModel comment) async {
    final post = _box.get(postId);
    if (post != null) {
      post.comments.add(comment);
      await post.save();
    }
  }

  static Future<void> deletePost(String postId) async {
    await _box.delete(postId);
  }
  
  static Future<void> clearAll() async {
    await _box.clear();
  }
}
