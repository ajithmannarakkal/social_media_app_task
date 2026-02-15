import 'package:get/get.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/hive_service.dart';

class FeedController extends GetxController {
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  void loadPosts() {
    isLoading.value = true;
    try {
      final allPosts = HiveService.getPosts();
      // Sort by newest first
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      posts.assignAll(allPosts);
    } catch (e) {
      // debugPrint("Error loading posts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    await HiveService.toggleLike(postId);
    // Refresh the specific post in the list strictly or reload all.
    // Since we are using HiveObjects and the list references the same objects,
    // modification might be reflected, but to be sure we trigger update.
    // However, HiveService doesn't return the updated object, it modifies in place usually if it's the same instance.
    // To be safe and reactive:
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      posts[index].save(); // Ensure hive saves it if not already done in service
      posts.refresh(); // Trigger GetX update
    }
    loadPosts(); // Reload to ensure order and state is correct
  }

  Future<void> addComment(String postId, String content) async {
    final comment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: 'Current User', // Mock user
      content: content,
      createdAt: DateTime.now(),
    );

    await HiveService.addComment(postId, comment);

    // Refresh the specific post in the list
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      posts[index].save(); 
      posts.refresh(); 
    }
    loadPosts();
  }
}

