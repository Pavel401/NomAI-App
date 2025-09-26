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
    DateTime time = selectedDate;

    // Get user preferences early before any async operations to avoid context issues
    UserModel? userModel;
    try {
      if (context.mounted) {
        final userBloc = context.read<UserBloc>();
        final userState = userBloc.state;

        if (userState is UserLoaded) {
          userModel = userState.userModel;
        }
      }
    } catch (e) {
      print("Error retrieving user preferences: $e");
    }

    try {
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
      } catch (e) {
        print("Error downscaling image: $e");
        resizedFile = image;
      }

      File fileToUpload = resizedFile.existsSync() ? resizedFile : image;

      final imageUrl = await storageService.uploadImage(fileToUpload);

      if (imageUrl == null) {
        throw Exception("Failed to upload image");
      }

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

      if (rawNutritionData.status != 200 || rawNutritionData.response == null) {
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

      updateRecord(NutritionRecord(
        nutritionOutput: rawNutritionData,
        recordTime: time,
        nutritionInputQuery: inputData,
        processingStatus: ProcessingStatus.COMPLETED,
      ));

      // Build the full list for the target day to persist correctly even if
      // the user switched the UI to a different day during processing.
      final key = _dateKey(time);
      final persistedForDay =
          await nutritionRecordRepo.getNutritionData(userId, time);

      // Merge: start with persisted, overlay transient by recordTime
      final mergedForDay = List<NutritionRecord>.from(
          persistedForDay.dailyRecords);
      final transient = _transientByDate[key] ?? const <NutritionRecord>[];
      for (final t in transient) {
        final i = mergedForDay.indexWhere((r) => r.recordTime == t.recordTime);
        if (i >= 0) {
          mergedForDay[i] = t;
        } else {
          mergedForDay.add(t);
        }
      }

      // Recompute totals from the merged list
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

      await nutritionRecordRepo.saveNutritionData(
          dailyNutritionRecords, userId);

      // Update UI totals only if the user is currently viewing this date
      if (_dateKey(selectedDate) == key) {
        existingNutritionRecords = dailyNutritionRecords;
        consumedCalories.value = totalConsumedCalories;
        burnedCalories.value = totalBurnedCalories;
        consumedFat.value = totalConsumedFat;
        consumedProtein.value = totalConsumedProtein;
        consumedCarb.value = totalConsumedCarb;
      }

      update();
    } catch (e) {
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
