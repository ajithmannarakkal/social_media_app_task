import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../models/post_model.dart';
import '../../controllers/feed_controller.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final FeedController controller = Get.find();

  PostCard({super.key, required this.post});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'Friends':
        return Icons.people;
      case 'Only Me':
        return Icons.lock;
      case 'Public':
      default:
        return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1), // Separator line effect
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(Icons.person, color: Colors.grey.shade800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Current User',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.verified,
                              size: 14, color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _formatTime(post.createdAt),
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Text('·',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(
                            _getVisibilityIcon(post.visibility),
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                  onSelected: (value) {
                    if (value == 'delete') {
                      // Confirm dialog could be added here, but direct delete for now
                      controller.deletePost(post.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                     PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Post', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(
                    fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            if (post.content.isNotEmpty && post.mediaPaths.isNotEmpty)
              const SizedBox(height: 12),
            // Media
            if (post.mediaPaths.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.mediaPaths.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.file(
                          File(post.mediaPaths[index]),
                          fit: BoxFit.cover,
                          // Slightly wider to look premium
                          width: post.mediaPaths.length == 1
                              ? MediaQuery.of(context).size.width * 0.9
                              : MediaQuery.of(context).size.width * 0.8,
                          cacheWidth: 1024,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              color: Colors.grey.shade100,
                              child: const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Footer (Actions)
            Row(
              children: [
                GetBuilder<FeedController>(
                  builder: (_) {
                    final isLiked = post.isLiked;
                    return InkWell(
                      onTap: () => controller.toggleLike(post.id),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                              color: isLiked ? Colors.red : Colors.grey.shade700,
                              size: 24,
                            ),
                            if (post.likes > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${post.likes}',
                                style: TextStyle(
                                  color: isLiked ? Colors.red : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    Get.bottomSheet(
                      CommentBottomSheet(post: post),
                      isScrollControlled: true, 
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: Colors.grey.shade700, size: 22),
                        const SizedBox(width: 6),
                        if (post.comments.isNotEmpty) ...[
                          Text('${post.comments.length}',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                        ],
                        Text('Comment',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                // Share button removed as requested
              ],
            ),
          ],
        ),
      ),
    );
  }
}
