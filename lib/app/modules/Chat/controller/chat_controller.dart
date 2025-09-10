import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:NomAi/app/models/Agent/agent_response.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/repo/agent_service.dart';

class ChatController extends GetxController {
  final AgentService _agentService = AgentService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController userIdController =
      TextEditingController(text: 'Pavel');

  final RxList<AgentResponse> messages = <AgentResponse>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Image handling
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isUploadingImage = false.obs;
  final ImagePicker _imagePicker = ImagePicker();

  AgentResponse? currentStreamingMessage;
  StreamSubscription? _messageSubscription;

  List<String> dietaryPreferences = [];
  List<String> allergies = [];

  List<String> selectedGoals = [];

  @override
  void onInit() {
    super.onInit();
    userIdController.addListener(_onUserIdChanged);
    loadChatHistory();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    userIdController.dispose();
    _messageSubscription?.cancel();
    super.onClose();
  }

  void _onUserIdChanged() {
    // Clear messages and error state like web implementation
    messages.clear();
    errorMessage.value = '';
    currentStreamingMessage = null;
    isTyping.value = false;

    // Cancel any ongoing message stream
    _messageSubscription?.cancel();

    // Trigger UI update
    update();

    // Load chat history for new user
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    final userId = userIdController.text.trim();
    if (userId.isEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final history = await _agentService.getChatHistory(userId);
      messages.value = history;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('DEBUG: Failed to load chat history: $e');
      errorMessage.value = 'Failed to load chat history: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(UserModel user) async {
    await sendMessageWithImage(user);
  }

  void _handleStreamedResponse(AgentResponse response) {
    if (response.role == 'user') return;

    // Handle final messages
    final isActuallyFinal = response.isFinal == true;

    if (isActuallyFinal) {
      if (currentStreamingMessage != null) {
        // Replace the streaming message with the final one
        final index = messages.indexOf(currentStreamingMessage!);
        if (index != -1) {
          messages[index] = response;
        } else {
          messages.add(response);
        }
      } else {
        messages.add(response);
      }
      currentStreamingMessage = null;
      isTyping.value = false;
    } else {
      // Handle streaming/partial messages
      if (currentStreamingMessage == null) {
        currentStreamingMessage = response;
        messages.add(response);
      } else {
        final index = messages.indexOf(currentStreamingMessage!);
        if (index != -1) {
          currentStreamingMessage = response;
          messages[index] = response;
        }
      }

      // Auto-finalization logic (like web implementation)
      final content = response.content?.trim() ?? '';
      if (content.isNotEmpty &&
          (content.endsWith('.') ||
              content.endsWith('!') ||
              content.endsWith('?'))) {
        // Wait a bit to see if more content comes, then finalize
        Timer(const Duration(milliseconds: 500), () {
          if (currentStreamingMessage == response && !isTyping.value) {
            // Still the same message and not actively receiving new content, finalize it
            currentStreamingMessage = null;
            isTyping.value = false;
            print('DEBUG: Auto-finalizing message due to completion pattern');
          }
        });
      }
    }

    _scrollToBottom();
  }

  void _handleError(dynamic error) {
    isTyping.value = false;
    currentStreamingMessage = null;

    print('Error sending message: $error');

    String errorText;
    if (error.toString().contains('Connection refused') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('ClientException')) {
      errorText =
          'Failed to connect to the server. Please check your internet connection and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      errorText = 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      errorText = 'Received invalid response from server. Please try again.';
    } else {
      errorText =
          'Sorry, I encountered an error while processing your request. Please try again.';
    }

    final errorResponse = AgentResponse(
      role: AgentRole.model,
      timestamp: DateTime.now(),
      content: errorText,
      isFinal: true,
    );
    messages.add(errorResponse);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearMessages() {
    messages.clear();
    errorMessage.value = '';
    currentStreamingMessage = null;
    isTyping.value = false;
    _messageSubscription?.cancel();
  }

  // Enhanced method to refresh/reload messages for current user
  Future<void> refreshMessages() async {
    clearMessages();
    await loadChatHistory();
  }

  // Get current user ID or default to Guest (like web implementation)
  String getCurrentUserId() {
    final userId = userIdController.text.trim();
    return userId.isEmpty ? 'Guest' : userId;
  }

  // Update user display (similar to web implementation)
  void updateUserDisplay() {
    update(); // Trigger GetBuilder update
  }

  // Image handling methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  Future<String?> uploadImageToFirebase(File imageFile, String userId) async {
    try {
      isUploadingImage.value = true;

      final fileName =
          'chat_images/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> sendMessageWithImage(UserModel user) async {
    String message = messageController.text.trim();

    if ((message.isEmpty && selectedImage.value == null) || isTyping.value)
      return;

    // If image is selected but no message, use default prompt
    if (selectedImage.value != null && message.isEmpty) {
      message = "What are the nutritional facts for this?";
    }

    final userId = userIdController.text.trim().isNotEmpty
        ? userIdController.text.trim()
        : 'Guest';

    String? imageUrl;

    // Upload image if selected
    if (selectedImage.value != null) {
      imageUrl = await uploadImageToFirebase(selectedImage.value!, userId);
      if (imageUrl == null) {
        // Handle upload failure
        errorMessage.value = 'Failed to upload image. Please try again.';
        return;
      }
    }

    final userMessage = AgentResponse(
      role: AgentRole.user,
      timestamp: DateTime.now(),
      content: message,
      isFinal: true,
      imageUrl: imageUrl,
    );

    messages.add(userMessage);
    messageController.clear();
    selectedImage.value = null; // Clear selected image

    isTyping.value = true;
    currentStreamingMessage = null;

    _scrollToBottom();

    try {
      _messageSubscription?.cancel();
      _messageSubscription = _agentService
          .sendMessage(message, userId, user, foodImage: imageUrl)
          .listen(
        (response) {
          _handleStreamedResponse(response);
        },
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          isTyping.value = false;
          currentStreamingMessage = null;
        },
      );
    } catch (e) {
      _handleError(e);
    }
  }
}
