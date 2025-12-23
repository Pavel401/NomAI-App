import 'dart:io';

import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/components/dialogs.dart';
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

  // Keep transient (in-memory) records per date so they persist
  // while the user navigates between dates.
  final Map<String, List<NutritionRecord>> _transientByDate = {};

  String _dateKey(DateTime d) => "${d.year}-${d.month}-${d.day}";

  @override
  void onInit() {
    super.onInit();
  }

  void addRecord(NutritionRecord record) {
    final key = _dateKey(record.recordTime!);
    final list = _transientByDate.putIfAbsent(key, () => []);
    list.add(record);

    if (_dateKey(selectedDate) == key) {
      dailyRecords.add(record);
      update();
    } else {
      update();
    }
  }

  void removeRecord(NutritionRecord record) {
    final key = _dateKey(record.recordTime!);
    if (_transientByDate.containsKey(key)) {
      _transientByDate[key]!.removeWhere(
        (r) => r.recordTime == record.recordTime,
      );
    }

    if (_dateKey(selectedDate) == key) {
      dailyRecords.removeWhere((r) => r.recordTime == record.recordTime);
      update();
    } else {
      update();
    }
  }

  void updateRecord(NutritionRecord record) {
    final key = _dateKey(record.recordTime!);

    // Update transient cache
    final list = _transientByDate.putIfAbsent(key, () => []);
    final tIndex = list.indexWhere((r) => r.recordTime == record.recordTime);
    if (tIndex >= 0) {
      list[tIndex] = record;
    } else {
      list.add(record);
    }

    // Update currently displayed list only if it matches the selected date
    if (_dateKey(selectedDate) == key) {
      final index =
          dailyRecords.indexWhere((r) => r.recordTime == record.recordTime);
      if (index >= 0) {
        dailyRecords[index] = record;
      } else {
        dailyRecords.add(record);
      }
    }

    update();
  }

  Future<void> processNutritionQueryRequest(String userId, File image,
      ScanMode scanMode, BuildContext context) async {
    DateTime time = DateTime.now();
    print("🚀 [NUTRITION] Starting nutrition processing for userId: $userId, scanMode: $scanMode, date: $time");

    // Get user preferences early before any async operations to avoid context issues
    UserModel? userModel;
    try {
      print("📋 [NUTRITION] Retrieving user preferences...");
      if (context.mounted) {
        final userBloc = context.read<UserBloc>();
        final userState = userBloc.state;

        if (userState is UserLoaded) {
          userModel = userState.userModel;
          print("✅ [NUTRITION] User preferences loaded successfully");
          print("   - Diet: ${userModel.userInfo?.selectedDiet}");
          print("   - Allergies: ${userModel.userInfo?.selectedAllergies}");
          print("   - Goal: ${userModel.userInfo?.selectedGoal?.name}");
        } else {
          print("⚠️ [NUTRITION] User state is not loaded: ${userState.runtimeType}");
        }
      }
    } catch (e) {
      print("❌ [NUTRITION] Error retrieving user preferences: $e");
    }

    try {
      print("🔧 [NUTRITION] Initializing services...");
      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();
      final storageService = serviceLocator<StorageService>();
      final aiRepository = serviceLocator<AiRepository>();
      print("✅ [NUTRITION] Services initialized successfully");

      print("📝 [NUTRITION] Creating PROCESSING record...");
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
      print("✅ [NUTRITION] PROCESSING record added to UI");

      File resizedFile;
      try {
        print("🖼️ [NUTRITION] Downscaling image...");
        print("   - Original path: ${image.path}");
        resizedFile = await ImageUtility.downscaleImage(
          image.path,
          scale: ImageScale.large_2048,
        );
        print("✅ [NUTRITION] Image downscaled successfully");
        print("   - Resized path: ${resizedFile.path}");
      } catch (e) {
        print("❌ [NUTRITION] Error downscaling image: $e");
        print("   - Using original image");
        resizedFile = image;
      }

      File fileToUpload = resizedFile.existsSync() ? resizedFile : image;
      print("📤 [NUTRITION] Uploading image to storage...");
      print("   - File size: ${fileToUpload.lengthSync()} bytes");

      final imageUrl = await storageService.uploadImage(fileToUpload);

      if (imageUrl == null) {
        print("❌ [NUTRITION] Image upload failed - null URL returned");
        throw Exception("Failed to upload image");
      }
      print("✅ [NUTRITION] Image uploaded successfully");
      print("   - Image URL: $imageUrl");

      print("🤖 [NUTRITION] Sending request to AI for nutrition analysis...");
      print("   - Scan mode: $scanMode");
      print("   - Dietary preferences: ${userModel?.userInfo?.selectedDiet}");
      print("   - Allergies: ${userModel?.userInfo?.selectedAllergies}");
      print("   - Goals: ${userModel?.userInfo?.selectedGoal?.name}");

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

      print("📊 [NUTRITION] AI response received");
      print("   - Status: ${rawNutritionData.status}");
      print("   - Message: ${rawNutritionData.message}");

      if (rawNutritionData.status != 200 || rawNutritionData.response == null) {
        print("❌ [NUTRITION] AI analysis failed");
        print("   - Status code: ${rawNutritionData.status}");
        print("   - Error message: ${rawNutritionData.message}");
        print("🔄 [NUTRITION] Updating record status to FAILED");

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

        AppDialogs.showErrorSnackbar(
          title: "Error",
          message: rawNutritionData.message ?? "Failed to analyze the image",
        );

        print("⛔ [NUTRITION] Processing aborted due to AI analysis failure");
        return;
      }

      print("✅ [NUTRITION] AI analysis successful");
      print("   - Food name: ${rawNutritionData.response?.foodName}");
      print("   - Ingredients count: ${rawNutritionData.response?.ingredients?.length ?? 0}");

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
      print("🔄 [NUTRITION] Updating record status to COMPLETED");

      updateRecord(NutritionRecord(
        nutritionOutput: rawNutritionData,
        recordTime: time,
        nutritionInputQuery: inputData,
        processingStatus: ProcessingStatus.COMPLETED,
      ));
      print("✅ [NUTRITION] Record updated to COMPLETED in UI");

      // Build the full list for the target day to persist correctly even if
      // the user switched the UI to a different day during processing.
      print("🔗 [NUTRITION] Merging records for database persistence...");
      final key = _dateKey(time);
      final persistedForDay =
          await nutritionRecordRepo.getNutritionData(userId, time);
      print("   - Existing persisted records: ${persistedForDay.dailyRecords.length}");

      // Merge: start with persisted, overlay transient by recordTime
      final mergedForDay = List<NutritionRecord>.from(
          persistedForDay.dailyRecords);
      final transient = _transientByDate[key] ?? const <NutritionRecord>[];
      print("   - Transient records for date: ${transient.length}");

      for (final t in transient) {
        final i = mergedForDay.indexWhere((r) => r.recordTime == t.recordTime);
        if (i >= 0) {
          mergedForDay[i] = t;
        } else {
          mergedForDay.add(t);
        }
      }
      print("   - Total merged records: ${mergedForDay.length}");

      // Recompute totals from the merged list
      print("🧮 [NUTRITION] Calculating daily nutritional totals...");
      int totalConsumedCalories = 0;
      int totalConsumedProtein = 0;
      int totalConsumedFat = 0;
      int totalConsumedCarb = 0;
      int totalBurnedCalories = persistedForDay.dailyBurnedCalories;

      for (final rec in mergedForDay) {
        final resp = rec.nutritionOutput?.response;
        if (resp?.ingredients != null) {
          for (final ing in resp!.ingredients!) {
            totalConsumedCalories += ing.calories ?? 0;
            totalConsumedProtein += ing.protein ?? 0;
            totalConsumedFat += ing.fat ?? 0;
            totalConsumedCarb += ing.carbs ?? 0;
          }
        }
      }
      print("   - Total calories: $totalConsumedCalories");
      print("   - Total protein: $totalConsumedProtein g");
      print("   - Total carbs: $totalConsumedCarb g");
      print("   - Total fat: $totalConsumedFat g");

      final dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: mergedForDay,
        recordDate: time,
        recordId: dailyRecordID,
        dailyConsumedCalories: totalConsumedCalories,
        dailyBurnedCalories: totalBurnedCalories,
        dailyConsumedProtein: totalConsumedProtein,
        dailyConsumedFat: totalConsumedFat,
        dailyConsumedCarb: totalConsumedCarb,
      );

      print("💾 [NUTRITION] Saving nutrition data to database...");
      print("   - Record ID: $dailyRecordID");
      print("   - Number of meals: ${mergedForDay.length}");
      await nutritionRecordRepo.saveNutritionData(
          dailyNutritionRecords, userId);
      print("✅ [NUTRITION] Data saved to database successfully");

      // Update UI totals only if the user is currently viewing this date
      print("🎨 [NUTRITION] Updating UI...");
      if (_dateKey(selectedDate) == key) {
        existingNutritionRecords = dailyNutritionRecords;
        consumedCalories.value = totalConsumedCalories;
        burnedCalories.value = totalBurnedCalories;
        consumedFat.value = totalConsumedFat;
        consumedProtein.value = totalConsumedProtein;
        consumedCarb.value = totalConsumedCarb;
        print("   ✅ UI updated with latest totals (viewing current date)");
      } else {
        print("   ⏭️ UI not updated (user switched to different date: ${_dateKey(selectedDate)} != $key)");
      }

      update();
      print("🎉 [NUTRITION] Processing completed successfully!");
      print("────────────────────────────────────────");
    } catch (e, stackTrace) {
      print("💥 [NUTRITION] EXCEPTION CAUGHT during processing!");
      print("   - Error: $e");
      print("   - Stack trace: $stackTrace");
      print("🔄 [NUTRITION] Marking record as FAILED...");

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

      AppDialogs.showErrorSnackbar(
        title: "Processing Failed",
        message: "Unable to analyze the image. Please try again.",
      );

      update();
      print("❌ [NUTRITION] Processing failed and record marked as FAILED");
      print("────────────────────────────────────────");
    }
  }

  Future<void> getRecordByDate(String userId, DateTime selectedDate) async {
    try {
      // Keep controller's selectedDate in sync with caller
      this.selectedDate = selectedDate;
      isLoading = true;
      update();

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();

      final records =
          await nutritionRecordRepo.getNutritionData(userId, selectedDate);

      // Merge fetched records with any transient in-memory records
      final key = _dateKey(selectedDate);
      final transient = List<NutritionRecord>.from(
          _transientByDate[key] ?? const <NutritionRecord>[]);

      final merged = List<NutritionRecord>.from(records.dailyRecords);
      for (final t in transient) {
        final i = merged.indexWhere((r) => r.recordTime == t.recordTime);
        if (i >= 0) {
          merged[i] = t;
        } else {
          merged.add(t);
        }
      }

      // Auto-fix stuck PROCESSING records older than 5 minutes
      final now = DateTime.now();
      final threshold = Duration(minutes: 5);
      bool needsUpdate = false;

      for (int i = 0; i < merged.length; i++) {
        final record = merged[i];
        if (record.processingStatus == ProcessingStatus.PROCESSING &&
            record.recordTime != null) {
          final age = now.difference(record.recordTime!);
          if (age > threshold) {
            // Mark as FAILED if stuck in PROCESSING for more than 5 minutes
            merged[i] = NutritionRecord(
              recordTime: record.recordTime,
              nutritionInputQuery: record.nutritionInputQuery,
              processingStatus: ProcessingStatus.FAILED,
              nutritionOutput: record.nutritionOutput,
            );
            needsUpdate = true;
          }
        }
      }

      // If we fixed any stuck records, update the database
      if (needsUpdate) {
        final updatedRecord = DailyNutritionRecords(
          dailyRecords: merged,
          recordDate: selectedDate,
          recordId: records.recordId,
          dailyConsumedCalories: records.dailyConsumedCalories,
          dailyBurnedCalories: records.dailyBurnedCalories,
          dailyConsumedProtein: records.dailyConsumedProtein,
          dailyConsumedFat: records.dailyConsumedFat,
          dailyConsumedCarb: records.dailyConsumedCarb,
        );
        await nutritionRecordRepo.saveNutritionData(updatedRecord, userId);
      }

      existingNutritionRecords = records;
      dailyRecords = merged;

      consumedCalories.value = records.dailyConsumedCalories;
      burnedCalories.value = records.dailyBurnedCalories;
      consumedFat.value = records.dailyConsumedFat;
      consumedProtein.value = records.dailyConsumedProtein;
      consumedCarb.value = records.dailyConsumedCarb;
    } catch (e) {
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
      AppDialogs.showErrorSnackbar(
        title: "Cannot Retry",
        message: "Original image file not found",
      );
      return;
    }

    // Check if context is still valid before proceeding
    if (!context.mounted) {
      AppDialogs.showErrorSnackbar(
        title: "Cannot Retry",
        message: "Screen context is no longer available",
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

      AppDialogs.showErrorSnackbar(
        title: "Cannot Retry",
        message: "Original image file not found",
      );
    }
  }

  void removeFailedRecord(NutritionRecord record) {
    if (record.processingStatus == ProcessingStatus.FAILED) {
      removeRecord(record);
      AppDialogs.showSuccessSnackbar(
        title: "Record Removed",
        message: "Failed nutrition record has been removed",
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
