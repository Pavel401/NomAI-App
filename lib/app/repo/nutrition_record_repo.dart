import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';

class NutritionRecordRepo {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  String getRecordId(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<QueryStatus> saveNutritionData(
      DailyNutritionRecords record, String userId) async {
    try {
      final recordId = getRecordId(record.recordDate);

      print("Saving record for user: $userId on date: ${record.recordDate}");

      print("Record ID: $recordId");
      print("Record Data: ${record.toJson()}");

      print("Saving to Firestore...");

      await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(recordId)
          .set(record.toJson());

      return QueryStatus.SUCCESS;
    } catch (e) {
      print("🔥 [API Error] $e");

      return QueryStatus.FAILED;
    }
  }

  Future<DailyNutritionRecords> getNutritionData(
      String userId, DateTime date) async {
    String recordId = getRecordId(date);

    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(recordId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        return DailyNutritionRecords.fromJson(data);
      } else {
        return DailyNutritionRecords(
          dailyRecords: [],
          recordDate: date,
          recordId: recordId,
        );
      }
    } catch (e) {
      print("🔥 [API Error] $e");
      throw Exception("❌ Something went wrong: $e");
    }
  }

  Future<QueryStatus> deleteMealEntry(
      String userId, DateTime date, int mealIndex) async {
    try {
      final recordId = getRecordId(date);

      print(
          "Deleting meal entry for user: $userId on date: $date at index: $mealIndex");

      // Get the current nutrition data
      final currentData = await getNutritionData(userId, date);

      // Check if the meal index is valid
      if (mealIndex < 0 || mealIndex >= currentData.dailyRecords.length) {
        print("❌ Invalid meal index: $mealIndex");
        return QueryStatus.FAILED;
      }

      // Get the meal entry to be deleted for calorie calculation
      final mealToDelete = currentData.dailyRecords[mealIndex];

      // Remove the meal entry from the list
      currentData.dailyRecords.removeAt(mealIndex);

      // Recalculate daily totals by subtracting the deleted meal's values
      if (mealToDelete.nutritionOutput != null &&
          mealToDelete.nutritionOutput!.response != null &&
          mealToDelete.nutritionOutput!.response!.ingredients != null) {
        // Calculate totals from ingredients
        int totalCalories = 0;
        int totalProtein = 0;
        int totalFat = 0;
        int totalCarbs = 0;

        for (var ingredient
            in mealToDelete.nutritionOutput!.response!.ingredients!) {
          totalCalories += ingredient.calories ?? 0;
          totalProtein += ingredient.protein ?? 0;
          totalFat += ingredient.fat ?? 0;
          totalCarbs += ingredient.carbs ?? 0;
        }

        // Subtract the deleted meal's values from daily totals
        currentData.dailyConsumedCalories -= totalCalories;
        currentData.dailyConsumedProtein -= totalProtein;
        currentData.dailyConsumedFat -= totalFat;
        currentData.dailyConsumedCarb -= totalCarbs;

        // Ensure values don't go below zero
        currentData.dailyConsumedCalories =
            currentData.dailyConsumedCalories.clamp(0, double.infinity).toInt();
        currentData.dailyConsumedProtein =
            currentData.dailyConsumedProtein.clamp(0, double.infinity).toInt();
        currentData.dailyConsumedFat =
            currentData.dailyConsumedFat.clamp(0, double.infinity).toInt();
        currentData.dailyConsumedCarb =
            currentData.dailyConsumedCarb.clamp(0, double.infinity).toInt();
      }

      // Save the updated data back to Firestore
      await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(recordId)
          .set(currentData.toJson());

      print("✅ Meal entry deleted successfully");
      return QueryStatus.SUCCESS;
    } catch (e) {
      print("🔥 [API Error] $e");
      return QueryStatus.FAILED;
    }
  }

  Future<QueryStatus> deleteMealEntryByTime(
      String userId, DateTime date, DateTime mealTime) async {
    try {
      print(
          "Deleting meal entry for user: $userId on date: $date at time: $mealTime");

      // Get the current nutrition data
      final currentData = await getNutritionData(userId, date);

      // Find the meal entry with the matching time
      int mealIndex = -1;
      for (int i = 0; i < currentData.dailyRecords.length; i++) {
        if (currentData.dailyRecords[i].recordTime != null &&
            currentData.dailyRecords[i].recordTime!
                .isAtSameMomentAs(mealTime)) {
          mealIndex = i;
          break;
        }
      }

      // Check if the meal was found
      if (mealIndex == -1) {
        print("❌ Meal entry not found for the specified time");
        return QueryStatus.FAILED;
      }

      // Use the existing deleteMealEntry method
      return await deleteMealEntry(userId, date, mealIndex);
    } catch (e) {
      print("🔥 [API Error] $e");
      return QueryStatus.FAILED;
    }
  }
}
