import 'dart:io';

import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';
import 'package:NomAi/app/repo/meal_ai_repo.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/repo/storage_service.dart';
import 'package:NomAi/app/utility/image_utility.dart';
import 'package:NomAi/app/utility/registry_service.dart';

class ScannerController extends GetxController {
  RxInt maximumCalories = 0.obs;
  RxInt consumedCalories = 0.obs;
  RxInt burnedCalories = 0.obs;
  RxInt maximumFat = 0.obs;
  RxInt consumedFat = 0.obs;
  RxInt maximumProtein = 0.obs;
  RxInt consumedProtein = 0.obs;
  RxInt maximumCarb = 0.obs;
  RxInt consumedCarb = 0.obs;
  List<NutritionRecord> dailyRecords = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  DailyNutritionRecords? existingNutritionRecords;

  @override
  void onInit() {
    super.onInit();
    print("📌 ScannerController initialized");
  }

  void addRecord(NutritionRecord record) {
    dailyRecords.add(record);
    update();
  }

  void removeRecord(NutritionRecord record) {
    dailyRecords.remove(record);
    update();
  }

  void updateRecord(NutritionRecord record) {
    final index =
        dailyRecords.indexWhere((r) => r.recordTime == record.recordTime);
    dailyRecords[index] = record;
    update();
  }

  Future<void> processNutritionQueryRequest(String userId, File image,
      ScanMode scanMode, BuildContext context) async {
    DateTime time = DateTime.now(); // Declare time at method level

    // Get user preferences early before any async operations to avoid context issues
    UserModel? userModel;
    try {
      if (context.mounted) {
        final userBloc = context.read<UserBloc>();
        final userState = userBloc.state;

        if (userState is UserLoaded) {
          userModel = userState.userModel;
        }
        print("User model obtained: $userModel");
      } else {
        print("Context not mounted, proceeding without user preferences");
      }
    } catch (e) {
      print("Error getting user preferences: $e, proceeding without them");
    }

    try {
      print(
          "--- processNutritionQueryRequest --- UserId: $userId --- ScanMode: $scanMode");

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();
      final storageService = serviceLocator<StorageService>();
      final aiRepository = serviceLocator<AiRepository>();

      NutritionRecord nutritionRecord = NutritionRecord(
        recordTime: time,
        nutritionInputQuery: NutritionInputQuery(
          imageUrl: "",
          scanMode: scanMode,
          imageFilePath: image.path,
        ),
        processingStatus: ProcessingStatus.PROCESSING,
      );

      addRecord(nutritionRecord);

      File resizedFile;
      try {
        resizedFile = await ImageUtility.downscaleImage(
          image.path,
          scale: ImageScale.large_2048,
        );
        print("Successfully created resized image at: ${resizedFile.path}");
      } catch (e) {
        print("Error downscaling image: $e");
        print("Using original image instead");
        resizedFile = image;
      }

      print("--- Now let's upload the image first to get URL ----");

      print("Resized file path: ${resizedFile.path}");
      print("Resized file exists: ${resizedFile.existsSync()}");

      File fileToUpload = resizedFile.existsSync() ? resizedFile : image;
      print("Using file for upload: ${fileToUpload.path}");

      final imageUrl = await storageService.uploadImage(fileToUpload);
      print("We got the image URL: $imageUrl");

      if (imageUrl == null) {
        print("Failed to upload image.");
        throw Exception("Failed to upload image");
      }

      print("--- Now lets get the nutrition data from Meal AI backend");

      NutritionOutput rawNutritionData = await aiRepository.getNutritionData(
        NutritionInputQuery(
          imageUrl: imageUrl,
          scanMode: scanMode,
          food_description: "",
          dietaryPreferences: userModel?.userInfo?.selectedDiet != null
              ? [userModel!.userInfo!.selectedDiet]
              : [],
          allergies: userModel?.userInfo?.selectedAllergies != null &&
                  userModel!.userInfo!.selectedAllergies.isNotEmpty
              ? userModel.userInfo!.selectedAllergies
              : [],
          selectedGoals: userModel?.userInfo?.selectedGoal != null
              ? [userModel!.userInfo!.selectedGoal.name]
              : [],
        ),
      );

      print("We got the rawNutritionData: ${rawNutritionData.status}");

      if (rawNutritionData.status != 200 || rawNutritionData.response == null) {
        print("❌ API call failed or returned no data");

        updateRecord(NutritionRecord(
          recordTime: time,
          nutritionInputQuery: NutritionInputQuery(
            imageUrl: imageUrl,
            scanMode: scanMode,
            imageFilePath: image.path,
          ),
          processingStatus: ProcessingStatus.FAILED,
          nutritionOutput: rawNutritionData, // Include the error response
        ));

        Get.snackbar(
          "Error",
          rawNutritionData.message ?? "Failed to analyze the image",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );

        return;
      }

      final inputData = NutritionInputQuery(
        imageUrl: imageUrl,
        scanMode: scanMode,
        imageFilePath: image.path,
        food_description: "",
        dietaryPreferences: userModel?.userInfo?.selectedDiet != null
            ? [userModel!.userInfo!.selectedDiet]
            : [],
        allergies: userModel?.userInfo?.selectedAllergies != null &&
                userModel!.userInfo!.selectedAllergies.isNotEmpty
            ? userModel.userInfo!.selectedAllergies
            : [],
        selectedGoals: userModel?.userInfo?.selectedGoal != null
            ? [userModel!.userInfo!.selectedGoal.name]
            : [],
      );

      String dailyRecordID = nutritionRecordRepo.getRecordId(time);

      print("The dailyRecordID is $dailyRecordID");

      updateRecord(NutritionRecord(
        nutritionOutput: rawNutritionData,
        recordTime: time,
        nutritionInputQuery: inputData,
        processingStatus: ProcessingStatus.COMPLETED,
      ));

      int totalNutritionValue = 0;
      int totalProteinValue = 0;
      int totalFatValue = 0;
      int totalCarbValue = 0;

      if (rawNutritionData.response?.ingredients != null) {
        for (final ingredient in rawNutritionData.response!.ingredients!) {
          totalNutritionValue += ingredient.calories ?? 0;
          totalProteinValue += ingredient.protein ?? 0;
          totalFatValue += ingredient.fat ?? 0;
          totalCarbValue += ingredient.carbs ?? 0;
        }
      }

      if (existingNutritionRecords == null) {
        existingNutritionRecords = DailyNutritionRecords(
          dailyRecords: [],
          recordDate: time,
          recordId: dailyRecordID,
          dailyConsumedCalories: 0,
          dailyBurnedCalories: 0,
          dailyConsumedProtein: 0,
          dailyConsumedFat: 0,
          dailyConsumedCarb: 0,
        );
      }

      int totalConsumedCalories =
          (existingNutritionRecords?.dailyConsumedCalories ?? 0) +
              totalNutritionValue;
      int totalConsumedFat =
          (existingNutritionRecords?.dailyConsumedFat ?? 0) + totalFatValue;
      int totalConsumedProtein =
          (existingNutritionRecords?.dailyConsumedProtein ?? 0) +
              totalProteinValue;
      int totalConsumedCarb =
          (existingNutritionRecords?.dailyConsumedCarb ?? 0) + totalCarbValue;
      int totalBurnedCalories =
          existingNutritionRecords?.dailyBurnedCalories ?? 0;

      DailyNutritionRecords dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: dailyRecords,
        recordDate: time,
        recordId: dailyRecordID,
        dailyConsumedCalories: totalConsumedCalories,
        dailyBurnedCalories: totalBurnedCalories,
        dailyConsumedProtein: totalConsumedProtein,
        dailyConsumedFat: totalConsumedFat,
        dailyConsumedCarb: totalConsumedCarb,
      );

      await nutritionRecordRepo.saveNutritionData(
          dailyNutritionRecords, userId);

      existingNutritionRecords = dailyNutritionRecords;

      consumedCalories.value = totalConsumedCalories;
      burnedCalories.value = totalBurnedCalories;
      consumedFat.value = totalConsumedFat;
      consumedProtein.value = totalConsumedProtein;
      consumedCarb.value = totalConsumedCarb;

      update();
    } catch (e) {
      print("🔥 [API Error] $e");

      final failedRecord = dailyRecords.firstWhere(
        (record) => record.recordTime == time,
        orElse: () => NutritionRecord(
          recordTime: time,
          nutritionInputQuery: NutritionInputQuery(
            imageUrl: "",
            scanMode: scanMode,
            imageFilePath: image.path,
          ),
          processingStatus: ProcessingStatus.FAILED,
        ),
      );

      updateRecord(NutritionRecord(
        recordTime: failedRecord.recordTime,
        nutritionInputQuery: failedRecord.nutritionInputQuery,
        processingStatus: ProcessingStatus.FAILED,
        nutritionOutput: failedRecord.nutritionOutput,
      ));

      Get.snackbar(
        "Processing Failed",
        "Unable to analyze the image. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      update();
    }
  }

  Future<void> getRecordByDate(String userId, DateTime selectedDate) async {
    print("🔍 Fetching nutrition records for user: $userId on $selectedDate");

    try {
      isLoading = true;
      update();

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();

      final records =
          await nutritionRecordRepo.getNutritionData(userId, selectedDate);

      existingNutritionRecords = records;
      dailyRecords = records.dailyRecords;

      consumedCalories.value = records.dailyConsumedCalories;
      burnedCalories.value = records.dailyBurnedCalories;
      consumedFat.value = records.dailyConsumedFat;
      consumedProtein.value = records.dailyConsumedProtein;
      consumedCarb.value = records.dailyConsumedCarb;

      print("✅ Successfully retrieved records");
    } catch (e) {
      print("🔥 [API Error] $e");

      dailyRecords.clear();
      existingNutritionRecords = null;
      throw Exception("❌ Something went wrong: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void updateNutritionValues({
    int? maxCalories,
    int? conCalories,
    int? burnCalories,
    int? maxFat,
    int? conFat,
    int? maxProtein,
    int? conProtein,
    int? maxCarb,
    int? conCarb,
  }) {
    if (maxCalories != null) maximumCalories.value = maxCalories;
    if (conCalories != null) consumedCalories.value = conCalories;
    if (burnCalories != null) burnedCalories.value = burnCalories;
    if (maxFat != null) maximumFat.value = maxFat;
    if (conFat != null) consumedFat.value = conFat;
    if (maxProtein != null) maximumProtein.value = maxProtein;
    if (conProtein != null) consumedProtein.value = conProtein;
    if (maxCarb != null) maximumCarb.value = maxCarb;
    if (conCarb != null) consumedCarb.value = conCarb;

    update();
  }

  Future<void> retryNutritionAnalysis(
      String userId, NutritionRecord failedRecord, BuildContext context) async {
    if (failedRecord.nutritionInputQuery?.imageFilePath == null) {
      Get.snackbar(
        "Cannot Retry",
        "Original image file not found",
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    // Check if context is still valid before proceeding
    if (!context.mounted) {
      print("Context not mounted, cannot retry nutrition analysis");
      Get.snackbar(
        "Cannot Retry",
        "Screen context is no longer available",
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    updateRecord(NutritionRecord(
      recordTime: failedRecord.recordTime,
      nutritionInputQuery: failedRecord.nutritionInputQuery,
      processingStatus: ProcessingStatus.PROCESSING,
    ));

    final imageFile = File(failedRecord.nutritionInputQuery!.imageFilePath!);
    final scanMode =
        failedRecord.nutritionInputQuery!.scanMode ?? ScanMode.food;

    if (imageFile.existsSync()) {
      await processNutritionQueryRequest(
        userId,
        imageFile,
        scanMode,
        context,
      );
    } else {
      updateRecord(NutritionRecord(
        recordTime: failedRecord.recordTime,
        nutritionInputQuery: failedRecord.nutritionInputQuery,
        processingStatus: ProcessingStatus.FAILED,
        nutritionOutput: NutritionOutput(
          status: 404,
          message: "Original image file not found",
          response: null,
        ),
      ));

      Get.snackbar(
        "Cannot Retry",
        "Original image file not found",
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  void removeFailedRecord(NutritionRecord record) {
    if (record.processingStatus == ProcessingStatus.FAILED) {
      removeRecord(record);
      Get.snackbar(
        "Record Removed",
        "Failed nutrition record has been removed",
        backgroundColor: Colors.blue.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  List<NutritionRecord> getFailedRecords() {
    return dailyRecords
        .where((record) => record.processingStatus == ProcessingStatus.FAILED)
        .toList();
  }

  List<NutritionRecord> getProcessingRecords() {
    return dailyRecords
        .where(
            (record) => record.processingStatus == ProcessingStatus.PROCESSING)
        .toList();
  }
}
