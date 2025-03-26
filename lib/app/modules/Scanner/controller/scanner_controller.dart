import 'dart:io';

import 'package:get/get.dart';
import 'package:turfit/app/constants/enums.dart';
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
  // Variables for state management
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

  Future<void> processNutritionQueryRequest(
      String userId, File image, ScanMode scanMode) async {
    try {
      print(
          "--- processNutritionQueryRequest --- UserId: $userId --- ScanMode: $scanMode");

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();
      final storageService = serviceLocator<StorageService>();
      final aiRepository = serviceLocator<AiRepository>();

      DateTime time = DateTime.now();

      NutritionRecord nutritionRecord = NutritionRecord(
        recordTime: time,
        nutritionInputQuery: NutritionInputQuery(
          imageUrl: "",
          scanMode: scanMode,
          imageData: "",
          imageFilePath: image.path,
        ),
        processingStatus: ProcessingStatus.PROCESSING,
      );

      addRecord(nutritionRecord);

      ///First We will downscale image
      final resizedFile = await ImageUtility.downscaleImage(
        image.path,
        scale: ImageScale.large_2048,
      );

      print("--- Let's get the Base64 ----");

      ///Convert image to base64 and upload
      final base64String =
          await ImageUtility.convertImageToBase64(resizedFile.path);

      print("The Image Base64 is ${base64String.length}");

      print("--- Lets get the nutrition data from Meal AI backend");

      NutritionOutput rawNutritionData = await aiRepository.getNutritionData(
        NutritionInputQuery(
          imageUrl: "",
          scanMode: scanMode,
          imageData: base64String,
          // imageFilePath: image.path,
        ),
      );

      print("We got the rawNutritionData: ${rawNutritionData.status}");

      print("--- Now let's get the Image url");

      ///Upload the imageurl in the firebase
      final imageUrl = await storageService.uploadImage(resizedFile);

      print("We got the image URL: $imageUrl");

      if (imageUrl == null) {
        print("Failed to upload image.");
      }

      ///Prepare input data for AI (with imageData)
      final inputData = NutritionInputQuery(
        imageUrl: imageUrl!,
        scanMode: scanMode,
        imageData: base64String, // Include imageData for API request
        imageFilePath: image.path,
      );

      String dailyRecordID = nutritionRecordRepo.getRecordId(time);

      print("The dailyRecordID is $dailyRecordID");

      updateRecord(NutritionRecord(
        nutritionOutput: rawNutritionData,
        recordTime: time,
        nutritionInputQuery: inputData,
        processingStatus: ProcessingStatus.COMPLETED,
      ));

      DailyNutritionRecords dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: dailyRecords,
        recordDate: time,
        recordId: dailyRecordID,
      );

      final status = await nutritionRecordRepo.saveNutritionData(
          dailyNutritionRecords, userId);

      existingNutritionRecords = dailyNutritionRecords;

      update();
    } catch (e) {
      print("🔥 [API Error] $e");
    }
  }

  Future<void> getRecordByDate(String userId, DateTime selectedDate) async {
    print("🔍 Fetching nutrition records for user: $userId on $selectedDate");

    try {
      // Set loading state and update UI
      isLoading = true;
      update();

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();

      // Fetch records
      final records =
          await nutritionRecordRepo.getNutritionData(userId, selectedDate);

      // Update existing records and daily records
      existingNutritionRecords = records;
      dailyRecords = records.dailyRecords;

      print("✅ Successfully retrieved records");
    } catch (e) {
      print("🔥 [API Error] $e");

      // Clear records on error
      dailyRecords.clear();
      existingNutritionRecords = null;
      throw Exception("❌ Something went wrong: $e");
    } finally {
      // Always set loading to false
      isLoading = false;
      update();
    }
  }
}
