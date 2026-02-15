import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart';
import 'widgets/post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate controller
    final FeedController controller = Get.put(FeedController());

    return Scaffold(
      body: Obx(() {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text(
                'Social Feed',
                style: TextStyle(letterSpacing: -1),
              ),
              centerTitle: false,

            ),
            if (controller.isLoading.value)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.feed_outlined,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 24),
                      Text(
                        'Your feed is empty',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by creating a new post',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(() => const CreatePostScreen()),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Post'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PostCard(post: controller.posts[index]);
                  },
                  childCount: controller.posts.length,
                ),
              ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreatePostScreen()),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.edit),
        label: const Text('New Post'),
      ),
    );
  }
}
