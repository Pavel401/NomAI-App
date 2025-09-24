import 'package:NomAi/app/components/dialogs.dart';
import 'package:NomAi/app/components/social_media_share_widget.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';

import 'package:NomAi/app/utility/date_utility.dart';

class NutritionView extends StatefulWidget {
  final NutritionRecord nutritionRecord;
  final UserModel userModel;

  const NutritionView({
    super.key,
    required this.nutritionRecord,
    required this.userModel,
  });

  @override
  State<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<NutritionView> {
  late final TextEditingController _foodNameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;

  final FocusNode _foodNameFocusNode = FocusNode();
  final FocusNode _caloriesFocusNode = FocusNode();
  final FocusNode _proteinFocusNode = FocusNode();
  final FocusNode _carbsFocusNode = FocusNode();
  final FocusNode _fatFocusNode = FocusNode();

  late final ValueNotifier<String?> _imagePathNotifier;

  bool _isEditing = false;
  String? _selectedImagePath;

  NutritionRecord get nutritionRecord => widget.nutritionRecord;
  UserModel get userModel => widget.userModel;

  @override
  void initState() {
    super.initState();
    final totals = _calculateCurrentTotals();

    _foodNameController = TextEditingController(
      text: nutritionRecord.nutritionOutput?.response?.foodName ?? '',
    );
    _caloriesController = TextEditingController(
      text: totals['calories']!.toString(),
    );
    _proteinController = TextEditingController(
      text: totals['protein']!.toString(),
    );
    _carbsController = TextEditingController(
      text: totals['carbs']!.toString(),
    );
    _fatController = TextEditingController(
      text: totals['fat']!.toString(),
    );

    final query = nutritionRecord.nutritionInputQuery;
    final initialImage = query?.imageFilePath?.isNotEmpty == true
        ? query!.imageFilePath
        : query?.imageUrl?.toString();

    _imagePathNotifier = ValueNotifier<String?>(initialImage);
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();

    _foodNameFocusNode.dispose();
    _caloriesFocusNode.dispose();
    _proteinFocusNode.dispose();
    _carbsFocusNode.dispose();
    _fatFocusNode.dispose();

    _imagePathNotifier.dispose();
    super.dispose();
  }

  Map<String, int> _calculateCurrentTotals() {
    int currentCalories = 0;
    int currentProtein = 0;
    int currentCarbs = 0;
    int currentFat = 0;

    final ingredients = nutritionRecord.nutritionOutput?.response?.ingredients;
    if (ingredients != null) {
      for (final ingredient in ingredients) {
        currentCalories += ingredient.calories ?? 0;
        currentProtein += ingredient.protein ?? 0;
        currentCarbs += ingredient.carbs ?? 0;
        currentFat += ingredient.fat ?? 0;
      }
    }

    return {
      'calories': currentCalories,
      'protein': currentProtein,
      'carbs': currentCarbs,
      'fat': currentFat,
    };
  }

  void _resetEditingControllers() {
    final totals = _calculateCurrentTotals();
    _foodNameController.text =
        nutritionRecord.nutritionOutput?.response?.foodName ?? '';
    _caloriesController.text = totals['calories']!.toString();
    _proteinController.text = totals['protein']!.toString();
    _carbsController.text = totals['carbs']!.toString();
    _fatController.text = totals['fat']!.toString();
    _selectedImagePath = null;

    final query = nutritionRecord.nutritionInputQuery;
    final resetImage = query?.imageFilePath?.isNotEmpty == true
        ? query!.imageFilePath
        : query?.imageUrl?.toString();
    _imagePathNotifier.value = resetImage;
  }

  @override
  Widget build(BuildContext context) {
    NutritionResponse response = nutritionRecord.nutritionOutput!.response!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildFoodHeaderCard(context, response),
                _buildNutritionSummaryCard(context, response),
                if (response.overallHealthComments != null &&
                    response.overallHealthComments!.isNotEmpty)
                  _buildHealthInsightsCard(context, response),
                if (response.ingredients != null &&
                    response.ingredients!.isNotEmpty)
                  _buildIngredientsCard(context, response),
                if (response.primaryConcerns != null &&
                    response.primaryConcerns!.isNotEmpty)
                  _buildPrimaryConcernsCard(context, response),
                if (response.suggestAlternatives != null &&
                    response.suggestAlternatives!.isNotEmpty)
                  _buildAlternativesCard(context, response),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteMeal(BuildContext context) async {
    // Show confirmation dialog
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meal Entry'),
          content: const Text(
            'Are you sure you want to delete this meal entry? This action cannot be undone.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle delete logic here if needed
                // For now, just close the dialog since the logic is commented out
                // Navigator.of(context).pop();

                AppDialogs.showLoadingDialog(
                  title: "Deleting Meal",
                  message: "Removing meal from records...",
                );

                String userId = userModel.userId;
                final nutritionRecordRepo = NutritionRecordRepo();
                final recordTime = nutritionRecord.recordTime ?? DateTime.now();

                QueryStatus result =
                    await nutritionRecordRepo.deleteMealEntryByTime(
                  userId,
                  recordTime,
                  recordTime,
                );

                if (result == QueryStatus.SUCCESS) {
                  AppDialogs.hideDialog();

                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to previous screen

                  AppDialogs.showSuccessSnackbar(
                    title: "Success",
                    message: "Meal deleted successfully!",
                  );
                  ScannerController scannerController =
                      Get.put(ScannerController());

                  await scannerController.getRecordByDate(userId, recordTime);
                } else {
                  // Show error snackbar if deletion failed
                  AppDialogs.showErrorSnackbar(
                    title: "Error",
                    message: "Failed to add to meals. Please try again.",
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // if (confirm != true) return;

    // try {
    //   // Show loading dialog with shorter message to prevent overflow
    //   AppDialogs.showLoadingDialog(
    //     title: "Deleting Meal",
    //     message: "Removing meal from records...",
    //   );

    //   // Get user ID from BLoC
    //   String? userId;
    // final userBloc = context.read<UserBloc>();
    // final userState = userBloc.state;
    // if (userState is UserLoaded) {
    //   userId = userState.userModel.userId;
    // }

    //   if (userId == null) {
    //     AppDialogs.hideDialog();
    //     AppDialogs.showErrorSnackbar(
    //       title: "Error",
    //       message: "Unable to identify user.",
    //     );
    //     return;
    //   }

    // final nutritionRecordRepo = NutritionRecordRepo();
    // final recordTime = nutritionRecord.recordTime ?? DateTime.now();

    //   // First try to delete by time
    // QueryStatus result = await nutritionRecordRepo.deleteMealEntryByTime(
    //   userId,
    //   recordTime,
    //   recordTime,
    // );

    //   // If deletion by time fails, try to find by matching nutrition data and delete by index
    //   if (result != QueryStatus.SUCCESS) {
    //     // Get current daily records
    //     final dailyRecords =
    //         await nutritionRecordRepo.getNutritionData(userId, recordTime);

    //     // Find the meal index by comparing nutrition data
    //     int mealIndex = -1;
    //     for (int i = 0; i < dailyRecords.dailyRecords.length; i++) {
    //       final record = dailyRecords.dailyRecords[i];
    //       if (_areRecordsEqual(record, nutritionRecord)) {
    //         mealIndex = i;
    //         break;
    //       }
    //     }

    //     if (mealIndex != -1) {
    //       result = await nutritionRecordRepo.deleteMealEntry(
    //           userId, recordTime, mealIndex);
    //     }
    //   }

    //   // Hide loading dialog
    //   AppDialogs.hideDialog();

    //   if (result == QueryStatus.SUCCESS) {
    //     // Update the scanner controller to refresh the data
    //     final scannerController = Get.find<ScannerController>();
    //     await scannerController.getRecordByDate(userId, recordTime);

    //     // Show success message
    //     AppDialogs.showSuccessSnackbar(
    //       title: "Success",
    //       message: "Meal deleted successfully!",
    //     );

    //     // Go back to previous screen
    //     Navigator.of(context).pop();
    //   } else {
    //     AppDialogs.showErrorSnackbar(
    //       title: "Error",
    //       message: "Failed to delete meal entry.",
    //     );
    //   }
    // } catch (e) {
    //   // Hide loading dialog if it's still showing
    //   AppDialogs.hideDialog();

    //   AppDialogs.showErrorSnackbar(
    //     title: "Error",
    //     message: "An unexpected error occurred.",
    //   );
    // }
  }

  Future<void> _handleEditMeal(BuildContext context) async {
    // Calculate current total nutrition values
    int currentCalories = 0;
    int currentProtein = 0;
    int currentCarbs = 0;
    int currentFat = 0;

    if (nutritionRecord.nutritionOutput?.response?.ingredients != null) {
      for (var ingredient
          in nutritionRecord.nutritionOutput!.response!.ingredients!) {
        currentCalories += ingredient.calories ?? 0;
        currentProtein += ingredient.protein ?? 0;
        currentCarbs += ingredient.carbs ?? 0;
        currentFat += ingredient.fat ?? 0;
      }
    }

    // Initialize controllers with current values
    final TextEditingController foodNameController = TextEditingController(
      text: nutritionRecord.nutritionOutput?.response?.foodName ?? '',
    );
    final TextEditingController caloriesController = TextEditingController(
      text: currentCalories.toString(),
    );
    final TextEditingController proteinController = TextEditingController(
      text: currentProtein.toString(),
    );
    final TextEditingController carbsController = TextEditingController(
      text: currentCarbs.toString(),
    );
    final TextEditingController fatController = TextEditingController(
      text: currentFat.toString(),
    );

    String? selectedImagePath;
    final ValueNotifier<String?> imagePathNotifier = ValueNotifier<String?>(
      nutritionRecord.nutritionInputQuery?.imageFilePath,
    );

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Edit Meal Entry',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Food Name Field
                    TextField(
                      controller: foodNameController,
                      decoration: const InputDecoration(
                        labelText: 'Food Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Section
                    const Text(
                      'Food Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String?>(
                      valueListenable: imagePathNotifier,
                      builder: (context, imagePath, child) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: imagePath != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imagePath.startsWith('/')
                                          // Local file path
                                          ? Image.file(
                                              File(imagePath),
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.restaurant,
                                                            size: 32,
                                                            color: Colors.grey),
                                                        Text('Image Error',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          // Network URL
                                          : Image.network(
                                              imagePath.startsWith('http')
                                                  ? imagePath
                                                  : nutritionRecord
                                                          .nutritionInputQuery
                                                          ?.imageUrl ??
                                                      '',
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.restaurant,
                                                            size: 32,
                                                            color: Colors.grey),
                                                        Text('No Image',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.white,
                                                  size: 18),
                                              onPressed: () {
                                                _showImagePickerOptions(
                                                    context, imagePathNotifier,
                                                    (path) {
                                                  selectedImagePath = path;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white,
                                                  size: 18),
                                              onPressed: () {
                                                imagePathNotifier.value = null;
                                                selectedImagePath = null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : InkWell(
                                  onTap: () async {
                                    _showImagePickerOptions(
                                        context, imagePathNotifier, (path) {
                                      selectedImagePath = path;
                                    });
                                  },
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              size: 32, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('Tap to add image',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nutrition Values Section
                    const Text(
                      'Nutrition Values',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calories Field
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department,
                            color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Macronutrients Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: proteinController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Protein (g) *',
                              border: OutlineInputBorder(),
                              prefixIcon:
                                  Icon(Icons.fitness_center, color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: carbsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Carbs (g) *',
                              border: OutlineInputBorder(),
                              prefixIcon:
                                  Icon(Icons.grain, color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fat Field
                    TextField(
                      controller: fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fat (g) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.water_drop, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Manual edits will update your daily nutrition totals. Make sure values are accurate.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await _performMealUpdate(
                              context,
                              foodNameController,
                              caloriesController,
                              proteinController,
                              carbsController,
                              fatController,
                              selectedImagePath,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Update Meal'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _performMealUpdate(
    BuildContext context,
    TextEditingController foodNameController,
    TextEditingController caloriesController,
    TextEditingController proteinController,
    TextEditingController carbsController,
    TextEditingController fatController,
    String? selectedImagePath,
  ) async {
    // Validate required fields
    if (foodNameController.text.trim().isEmpty) {
      AppDialogs.showErrorSnackbar(
        title: "Error",
        message: "Please enter a food name.",
      );
      return;
    }

    // Validate and parse numeric values
    int? calories = int.tryParse(caloriesController.text.trim());
    int? protein = int.tryParse(proteinController.text.trim());
    int? carbs = int.tryParse(carbsController.text.trim());
    int? fat = int.tryParse(fatController.text.trim());

    if (calories == null || calories < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for calories (0 or greater).",
      );
      return;
    }

    if (protein == null || protein < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for protein (0 or greater).",
      );
      return;
    }

    if (carbs == null || carbs < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for carbs (0 or greater).",
      );
      return;
    }

    if (fat == null || fat < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for fat (0 or greater).",
      );
      return;
    }

    Navigator.of(context).pop(); // Close the dialog

    AppDialogs.showLoadingDialog(
      title: "Updating Meal",
      message: "Saving your changes...",
    );

    try {
      String userId = userModel.userId;
      final nutritionRecordRepo = NutritionRecordRepo();
      final recordTime = nutritionRecord.recordTime ?? DateTime.now();

      // Create updated nutrition record with manual values
      NutritionRecord updatedRecord = nutritionRecord;

      // Update the food name in the nutrition response
      if (updatedRecord.nutritionOutput?.response != null) {
        updatedRecord.nutritionOutput!.response!.foodName =
            foodNameController.text.trim();

        // Update the ingredients with the new manual values
        if (updatedRecord.nutritionOutput!.response!.ingredients != null &&
            updatedRecord.nutritionOutput!.response!.ingredients!.isNotEmpty) {
          // Update the first (or main) ingredient with the new values
          var mainIngredient =
              updatedRecord.nutritionOutput!.response!.ingredients!.first;
          mainIngredient.calories = calories;
          mainIngredient.protein = protein;
          mainIngredient.carbs = carbs;
          mainIngredient.fat = fat;
          mainIngredient.name = foodNameController.text.trim();
        } else {
          // Create a new ingredient if none exist
          updatedRecord.nutritionOutput!.response!.ingredients = [
            Ingredient(
              name: foodNameController.text.trim(),
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
              healthScore: 5, // Default health score
              healthComments: "Manually entered nutrition values",
            )
          ];
        }
      }

      // Update the food description in input query
      if (updatedRecord.nutritionInputQuery != null) {
        updatedRecord.nutritionInputQuery!.food_description =
            foodNameController.text.trim();

        // Update image path if a new one was selected
        if (selectedImagePath != null) {
          updatedRecord.nutritionInputQuery!.imageFilePath = selectedImagePath;
        }
      }

      QueryStatus result = await nutritionRecordRepo.updateMealEntry(
        userId,
        updatedRecord,
        recordTime,
        recordTime,
      );

      AppDialogs.hideDialog();

      if (result == QueryStatus.SUCCESS) {
        AppDialogs.showSuccessSnackbar(
          title: "Success",
          message: "Meal updated successfully with your custom values!",
        );

        // Refresh the data in scanner controller
        ScannerController scannerController = Get.put(ScannerController());
        await scannerController.getRecordByDate(userId, recordTime);

        // Go back to refresh the view
        Navigator.of(context).pop();
      } else {
        AppDialogs.showErrorSnackbar(
          title: "Error",
          message: "Failed to update meal. Please try again.",
        );
      }
    } catch (e) {
      AppDialogs.hideDialog();
      AppDialogs.showErrorSnackbar(
        title: "Error",
        message: "An unexpected error occurred: $e",
      );
    }
  }

  void _showImagePickerOptions(
      BuildContext context,
      ValueNotifier<String?> imagePathNotifier,
      Function(String) onImageSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    onImageSelected(image.path);
                    imagePathNotifier.value = image.path;
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    onImageSelected(image.path);
                    imagePathNotifier.value = image.path;
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 35.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Bounceable(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
        ),
      ),
      actions: [
        Bounceable(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SocialMediaShareWidget(
                  nutritionRecord: nutritionRecord,
                  userName: userModel.name,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.ios_share,
                color: MealAIColors.lightSuccess, size: 20),
          ),
        ),
        Bounceable(
          onTap: () => _handleEditMeal(context),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
          ),
        ),
        Bounceable(
          onTap: () => _handleDeleteMeal(context),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: nutritionRecord.nutritionInputQuery?.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl:
                      nutritionRecord.nutritionInputQuery!.imageUrl.toString(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.black54),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No Image Available',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No Image Available',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFoodHeaderCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            response.foodName ?? 'Unknown Food',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (response.overallHealthScore != null) ...[
            SizedBox(height: 2.h),
            EnhancedHealthScoreWidget(nutritionRecord: nutritionRecord),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard(
      BuildContext context, NutritionResponse response) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    if (response.ingredients != null) {
      for (var ingredient in response.ingredients!) {
        totalCalories += ingredient.calories ?? 0;
        totalProtein += ingredient.protein ?? 0;
        totalCarbs += ingredient.carbs ?? 0;
        totalFat += ingredient.fat ?? 0;
      }
    }

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics_outlined,
                    color: Colors.blue.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Nutrition Facts',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade300],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$totalCalories kcal',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedNutrientBox(
                  context,
                  'Carbs',
                  '$totalCarbs',
                  'g',
                  MealAIColors.carbsColor,
                  Icons.grain,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedNutrientBox(
                  context,
                  'Protein',
                  '$totalProtein',
                  'g',
                  MealAIColors.proteinColor,
                  Icons.fitness_center,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedNutrientBox(
                  context,
                  'Fat',
                  '$totalFat',
                  'g',
                  MealAIColors.fatColor,
                  Icons.water_drop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNutrientBox(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color backgroundColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: backgroundColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: backgroundColor,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsightsCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology_outlined,
                    color: Colors.green.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Health Insights',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              response.overallHealthComments ?? '',
              style: context.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant_menu,
                    color: Colors.purple.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Ingredients',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.ingredients?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ingredient = response.ingredients![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            ingredient.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ingredient.healthComments != null &&
                        ingredient.healthComments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          ingredient.healthComments!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryConcernsCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber_outlined,
                    color: Colors.orange.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Primary Concerns',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.primaryConcerns?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final concern = response.primaryConcerns![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.orange.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            concern.issue ?? 'Unknown Concern',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      concern.explanation ?? 'No explanation available',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    if (concern.recommendations != null &&
                        concern.recommendations!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Recommendations:',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (Recommendation suggestion
                          in concern.recommendations!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${suggestion.food} - ${suggestion.reasoning} (${suggestion.quantity})',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesCard(
      BuildContext context, NutritionResponse response) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb_outline,
                    color: Colors.green.shade600, size: 20),
              ),
              SizedBox(width: 2.w),
              Text(
                'Healthier Alternatives',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.suggestAlternatives?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alternative = response.suggestAlternatives![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alternative.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                        if (alternative.healthScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${alternative.healthScore}/10',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (alternative.healthComments != null &&
                        alternative.healthComments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        alternative.healthComments!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EnhancedHealthScoreWidget extends StatelessWidget {
  final NutritionRecord nutritionRecord;

  const EnhancedHealthScoreWidget({
    super.key,
    required this.nutritionRecord,
  });

  @override
  Widget build(BuildContext context) {
    double scorePercent = (nutritionRecord
            .nutritionOutput!.response!.overallHealthScore!
            .clamp(0, 10)) /
        10;

    int healthScore = nutritionRecord
        .nutritionOutput!.response!.overallHealthScore!
        .clamp(0, 10)
        .toInt();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getProgressColor(scorePercent).withOpacity(0.1),
            _getProgressColor(scorePercent).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _getProgressColor(scorePercent).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Meal Time",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateUtility.getTimeFromDateTime(
                    nutritionRecord.recordTime?.toLocal() ?? DateTime.now(),
                  ),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CircularPercentIndicator(
                radius: 8.w,
                lineWidth: 6.0,
                animation: true,
                animationDuration: 1200,
                percent: scorePercent,
                backgroundColor: Colors.grey.shade200,
                progressColor: _getProgressColor(scorePercent),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '$healthScore',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(scorePercent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getHealthRating(healthScore),
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(scorePercent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 0.8) return Colors.green.shade600;
    if (percent >= 0.6) return Colors.orange.shade600;
    if (percent >= 0.4) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  String _getHealthRating(int score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Poor';
  }
}
