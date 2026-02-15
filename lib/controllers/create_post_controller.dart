import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../services/hive_service.dart';
import 'feed_controller.dart';
import 'social_text_controller.dart';

class CreatePostController extends GetxController {
  final TextEditingController textController = SocialTextEditingController();
  // Suggestions
  final RxList<String> suggestions = <String>[].obs;
  final RxBool showSuggestions = false.obs;
  String? currentMatchTerm; // The term we are currently matching (e.g. "@Ali")

  final RxList<XFile> selectedMedia = <XFile>[].obs;
  final RxString selectedVisibility = 'Public'.obs;
  final RxBool isLoading = false.obs;

  final List<String> visibilityOptions = ['Public', 'Friends', 'Only Me'];
  final ImagePicker _picker = ImagePicker();

  // Observable to check if post button should be enabled
  final RxBool isPostValid = false.obs;

  final List<String> _mockUsers = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Eve',
    'Frank',
    'Grace',
    'Heidi',
    'Ivan',
    'Judy'
  ];
  final List<String> _mockTags = [
    'Flutter',
    'Dart',
    'Coding',
    'MobileDev',
    'OpenSource',
    'Tech',
    'Innovation',
    'Design',
    'UIUX',
    'programming'
  ];

  @override
  void onInit() {
    super.onInit();
    // Listen to text changes to update validity
    textController.addListener(_validatePost);
    textController.addListener(_checkForMentions); // Check for @ or #
    // Listen to media changes
    ever(selectedMedia, (_) => _validatePost());
  }

  void _validatePost() {
    final text = textController.text.trim();
    final hasValidText = text.isNotEmpty && text != '@' && text != '#';
    isPostValid.value = hasValidText || selectedMedia.isNotEmpty;
  }

  void _checkForMentions() {
    final text = textController.text;
    final selection = textController.selection;

    if (!selection.isValid || selection.isCollapsed == false) {
      showSuggestions.value = false;
      return;
    }

    final cursorPos = selection.baseOffset;
    if (cursorPos <= 0) {
      showSuggestions.value = false;
      return;
    }

    // Find the word being typed
    int start = cursorPos - 1;
    while (start >= 0 && text[start] != ' ' && text[start] != '\n') {
      start--;
    }
    // start is now either -1 or the index of the space before the word
    final word = text.substring(start + 1, cursorPos);

    if (word.startsWith('@')) {
      final query = word.substring(1).toLowerCase();
      suggestions.value = _mockUsers
          .where((user) => user.toLowerCase().contains(query))
          .map((user) => '@$user')
          .toList();
      showSuggestions.value = suggestions.isNotEmpty;
      currentMatchTerm = word;
    } else if (word.startsWith('#')) {
      final query = word.substring(1).toLowerCase();
      suggestions.value = _mockTags
          .where((tag) => tag.toLowerCase().contains(query))
          .map((tag) => '#$tag')
          .toList();
      showSuggestions.value = suggestions.isNotEmpty;
      currentMatchTerm = word;
    } else {
      showSuggestions.value = false;
    }
  }

  void insertSuggestion(String suggestion) {
    if (currentMatchTerm == null) return;

    final text = textController.text;
    final selection = textController.selection;
    final cursorPos = selection.baseOffset;

    // Find where the current term starts
    int start = cursorPos - currentMatchTerm!.length;

    final newText = text.replaceRange(start, cursorPos, '$suggestion ');
    textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + suggestion.length + 1),
    );

    showSuggestions.value = false;
    suggestions.clear();
  }

  void insertTrigger(String char) {
    final text = textController.text;
    final selection = textController.selection;
    
    // If invalid selection, append to end
     if (!selection.isValid || selection.baseOffset == -1) {
        textController.text = '$text$char';
     } else {
        final cursorPos = selection.baseOffset;
        final newText = text.replaceRange(cursorPos, cursorPos, char);
        textController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursorPos + 1),
        );
     }
    
    // Trigger suggestions manually
    _checkForMentions();
  }

  Future<void> pickMedia() async {
    try {
      final List<XFile> medias = await _picker.pickMultiImage();
      if (medias.isNotEmpty) {
        selectedMedia.addAll(medias);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  void removeMedia(int index) {
    selectedMedia.removeAt(index);
  }

  void updateVisibility(String? newValue) {
    if (newValue != null) {
      selectedVisibility.value = newValue;
    }
  }

  Future<void> createPost() async {
    if (!isPostValid.value) return;

    isLoading.value = true;
    try {
      final String id = const Uuid().v4();
      final List<String> mediaPaths = selectedMedia.map((e) => e.path).toList();

      final newPost = PostModel(
        id: id,
        content: textController.text.trim(),
        mediaPaths: mediaPaths,
        visibility: selectedVisibility.value,
        createdAt: DateTime.now(),
      );

      await HiveService.savePost(newPost);

      // Refresh feed
      if (Get.isRegistered<FeedController>()) {
        Get.find<FeedController>().loadPosts();
      }

      // Reset and go back
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Post created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    textController.clear();
    selectedMedia.clear();
    selectedVisibility.value = 'Public';
    showSuggestions.value = false;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
