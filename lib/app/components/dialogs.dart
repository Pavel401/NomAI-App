import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:NomAi/app/constants/colors.dart';

class AppDialogs {
  /// Show a minimal black and white adding dialog
  static void showAddDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Add",
    String cancelText = "Cancel",
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MealAIColors.blackText.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: MealAIColors.blackText.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: MealAIColors.blackText,
                  size: 24,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: MealAIColors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: MealAIColors.grey.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          color: MealAIColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MealAIColors.blackText,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Show success snackbar with black and white minimal styling
  static void showSuccessSnackbar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: MealAIColors.blackText,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      ),
      shouldIconPulse: false,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show error snackbar with black and white minimal styling
  static void showErrorSnackbar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: MealAIColors.grey,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 16,
        ),
      ),
      shouldIconPulse: false,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show info snackbar with black and white minimal styling
  static void showInfoSnackbar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: MealAIColors.greyLight,
      colorText: MealAIColors.blackText,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: MealAIColors.blackText.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline,
          color: MealAIColors.blackText,
          size: 16,
        ),
      ),
      shouldIconPulse: false,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show loading dialog with minimal black and white styling
  static void showLoadingDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MealAIColors.blackText.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MealAIColors.blackText,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: MealAIColors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Prevent dismissing while loading
    );
  }

  /// Hide the currently shown dialog
  static void hideDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
