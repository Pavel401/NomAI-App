import 'dart:io';

import 'package:get/get.dart';
import 'package:turfit/app/models/AI/nutrition_input.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/modules/Scanner/views/scan_view.dart';
import 'package:turfit/app/repo/meal_ai_repo.dart';
import 'package:turfit/app/repo/nutrition_record_repo.dart';
import 'package:turfit/app/repo/storage_service.dart';
import 'package:turfit/app/utility/image_utility.dart';
import 'package:turfit/app/utility/registry_service.dart';

class ScannerController extends GetxController {
  DailyNutritionRecords? exisitingNutritionRecords;
  List<NutritionRecord> dailyRecords = [];
  DateTime selectedDate = DateTime.now();
  var isLoading = false.obs;

  Future<NutritionOutput> getNutritionData(
      NutritionInputQuery inputData, String userId) async {
    AiRepository aiRepository = serviceLocator<AiRepository>();

    try {
      NutritionOutput nutritionOutput =
          await aiRepository.getNutritionData(inputData);
      return nutritionOutput;
    } catch (e) {
      print("🔥 [API Error] $e");
      throw Exception("❌ Something went wrong: $e");
    }
  }

  Future<void> processNutritionQueryRequest(
      String userId, File image, ScanMode scanMode) async {
    isLoading.value = true;
    NutritionRecordRepo nutritionRecordRepo =
        serviceLocator<NutritionRecordRepo>();
    try {
      File resizedFile = await ImageUtility.downscaleImage(
        image.path,
        scale: ImageScale.large_2048,
      );

      final base64String =
          await ImageUtility.convertImageToBase64(resizedFile.path);
      StorageService storageService = serviceLocator<StorageService>();

      // Await the uploadImage method and handle the nullable return type
      String? imageUrl = await storageService.uploadImage(resizedFile);

      if (imageUrl == null) {
        throw Exception("Failed to upload image.");
      }

      NutritionInputQuery inputData = NutritionInputQuery(
        imageUrl: imageUrl,
        scanMode: scanMode,
        imageData: base64String,
      );

      NutritionOutput nutritionOutput =
          await getNutritionData(inputData, userId);

      NutritionRecord nutritionRecord = NutritionRecord(
        nutritionOutput: nutritionOutput,
        recordTime: DateTime.now(),
        nutritionInputQuery: inputData,
      );

      String recordId = nutritionRecordRepo.getRecordId(DateTime.now());

      List<NutritionRecord> dailyRecords =
          exisitingNutritionRecords?.dailyRecords ?? [];

      DailyNutritionRecords? dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: [...dailyRecords, nutritionRecord],
        recordDate: DateTime.now(),
        recordId: recordId,
      );

      await nutritionRecordRepo.saveNutritionData(
          dailyNutritionRecords, userId);

      update();
    } catch (e) {
      print("🔥 [API Error] $e");
      throw Exception("❌ Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
