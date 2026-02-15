import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/create_post_controller.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreatePostController controller = Get.put(CreatePostController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: ElevatedButton(
                onPressed: controller.isPostValid.value && !controller.isLoading.value
                    ? controller.createPost
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isPostValid.value ? Colors.black : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(60, 36),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade100,
                        child: Icon(Icons.person, color: Colors.grey.shade800),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current User',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            // Visibility Chips
                            Obx(() {
                              final selected = controller.selectedVisibility.value;
                              return SizedBox(
                                height: 28,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: controller.visibilityOptions.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final option = controller.visibilityOptions[index];
                                    final isSelected = selected == option;
                                    return InkWell(
                                      onTap: () => controller.updateVisibility(option),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.black : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? Colors.black : Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey.shade600,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Suggestions Overlay
                  Obx(() {
                    if (!controller.showSuggestions.value) return const SizedBox.shrink();
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.suggestions.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final suggestion = controller.suggestions[index];
                          final isMention = suggestion.startsWith('@');
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  isMention ? Colors.blue.shade100 : Colors.orange.shade100,
                              child: Icon(
                                isMention ? Icons.person : Icons.tag,
                                size: 16,
                                color: isMention ? Colors.blue : Colors.orange,
                              ),
                            ),
                            title: Text(suggestion,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            onTap: () => controller.insertSuggestion(suggestion),
                          );
                        },
                      ),
                    );
                  }),

                  // Text Input
                   TextField(
                    controller: controller.textController,
                    maxLines: null,
                    minLines: 1,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "What's happening?",
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 20, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Media Preview
                  Obx(() {
                    if (controller.selectedMedia.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return SizedBox(
                      height: 200, // Taller preview
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedMedia.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(controller.selectedMedia[index].path),
                                  width: 180,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  cacheWidth: 400, // Consistent optimization
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => controller.removeMedia(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // Bottom Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => controller.insertTrigger('@'),
                  icon: const Icon(Icons.alternate_email, color: Colors.blue, size: 28),
                ),
                IconButton(
                  onPressed: () => controller.insertTrigger('#'),
                  icon: const Icon(Icons.tag, color: Colors.blue, size: 28),
                ),
                IconButton(
                  onPressed: controller.pickMedia,
                  icon: const Icon(Icons.image_outlined, color: Colors.blue, size: 28),
                ),
                const Spacer(),
                 // Char count mock
                const Text("0/280", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
