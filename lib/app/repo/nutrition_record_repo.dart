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

      await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(recordId)
          .set(record.toJson());

      return QueryStatus.SUCCESS;
    } catch (e) {
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
      throw Exception("❌ Something went wrong: $e");
    }
  }

  Future<QueryStatus> deleteMealEntry(
      String userId, DateTime date, int mealIndex) async {
    try {
      final recordId = getRecordId(date);

      // Get the current nutrition data
      final currentData = await getNutritionData(userId, date);

      // Check if the meal index is valid
      if (mealIndex < 0 || mealIndex >= currentData.dailyRecords.length) {
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

      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.FAILED;
    }
  }

  Future<QueryStatus> deleteMealEntryByTime(
      String userId, DateTime date, DateTime mealTime) async {
    try {
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
        return QueryStatus.FAILED;
      }

      // Use the existing deleteMealEntry method
      return await deleteMealEntry(userId, date, mealIndex);
    } catch (e) {
      print("Error deleting meal entry: $e");
      return QueryStatus.FAILED;
    }
  }

  Future<QueryStatus> updateMealEntry(String userId, NutritionRecord record,
      DateTime date, DateTime mealTime) async {
    try {
      final currentData = await getNutritionData(userId, date);
      final recordId = getRecordId(date);

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
        return QueryStatus.FAILED;
      }

      // Get the old meal entry for calorie calculation
      final oldMeal = currentData.dailyRecords[mealIndex];

      // Calculate old meal's nutritional values
      int oldCalories = 0;
      int oldProtein = 0;
      int oldFat = 0;
      int oldCarbs = 0;

      if (oldMeal.nutritionOutput != null &&
          oldMeal.nutritionOutput!.response != null &&
          oldMeal.nutritionOutput!.response!.ingredients != null) {
        for (var ingredient
            in oldMeal.nutritionOutput!.response!.ingredients!) {
          oldCalories += ingredient.calories ?? 0;
          oldProtein += ingredient.protein ?? 0;
          oldFat += ingredient.fat ?? 0;
          oldCarbs += ingredient.carbs ?? 0;
        }
      }

      // Calculate new meal's nutritional values
      int newCalories = 0;
      int newProtein = 0;
      int newFat = 0;
      int newCarbs = 0;

      if (record.nutritionOutput != null &&
          record.nutritionOutput!.response != null &&
          record.nutritionOutput!.response!.ingredients != null) {
        for (var ingredient in record.nutritionOutput!.response!.ingredients!) {
          newCalories += ingredient.calories ?? 0;
          newProtein += ingredient.protein ?? 0;
          newFat += ingredient.fat ?? 0;
          newCarbs += ingredient.carbs ?? 0;
        }
      }

      // Update the meal entry
      currentData.dailyRecords[mealIndex] = record;

      // Update daily totals by removing old values and adding new values
      currentData.dailyConsumedCalories =
          currentData.dailyConsumedCalories - oldCalories + newCalories;
      currentData.dailyConsumedProtein =
          currentData.dailyConsumedProtein - oldProtein + newProtein;
      currentData.dailyConsumedFat =
          currentData.dailyConsumedFat - oldFat + newFat;
      currentData.dailyConsumedCarb =
          currentData.dailyConsumedCarb - oldCarbs + newCarbs;

      // Ensure values don't go below zero
      currentData.dailyConsumedCalories =
          currentData.dailyConsumedCalories.clamp(0, double.infinity).toInt();
      currentData.dailyConsumedProtein =
          currentData.dailyConsumedProtein.clamp(0, double.infinity).toInt();
      currentData.dailyConsumedFat =
          currentData.dailyConsumedFat.clamp(0, double.infinity).toInt();
      currentData.dailyConsumedCarb =
          currentData.dailyConsumedCarb.clamp(0, double.infinity).toInt();

      // Save the updated data back to Firestore
      await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(recordId)
          .set(currentData.toJson());

      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.FAILED;
    }
  }
}
