import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';

class NutritionFirebaseRepo {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  String getNutritionRecordId(DateTime date) {
    return date.toIso8601String();
  }

  Future<DailyNutritionRecords> getDailyNutritionRecords(
    String userId,
    DateTime date,
  ) async {
    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(date.toIso8601String())
          .get();

      if (snapshot.exists) {
        DailyNutritionRecords dailyRecords = DailyNutritionRecords.fromJson(
            snapshot.data() as Map<String, dynamic>);

        return dailyRecords;
      } else {
        return DailyNutritionRecords(
          dailyRecords: [],
          recordDate: date,
          recordId: getNutritionRecordId(date),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveDailyNutritionRecords(
    String userId,
    DailyNutritionRecords dailyRecords,
  ) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(dailyRecords.recordId)
          .set(dailyRecords.toJson());
    } catch (e) {
      rethrow;
    }
  }
}
