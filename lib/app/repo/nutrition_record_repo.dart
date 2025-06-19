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
}
