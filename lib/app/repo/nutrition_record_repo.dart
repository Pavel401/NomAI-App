import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';

class NutritionRecordRepo {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  String getRecordId(DateTime date) {
    return date.day.toString() +
        date.month.toString() +
        date.year.toString() +
        date.weekday.toString();
  }

  Future<void> saveNutritionData(
      DailyNutritionRecords record, String userId) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .doc(record.recordId)
          .set(record.toJson());
    } catch (e) {
      print("🔥 [API Error] $e");
      throw Exception("❌ Something went wrong: $e");
    }
  }

  Future<List<DailyNutritionRecords>> getNutritionData(String userId) async {
    try {
      final snapshot = await usersCollection
          .doc(userId)
          .collection('nutritionRecords')
          .get();

      return snapshot.docs
          .map((doc) => DailyNutritionRecords.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("🔥 [API Error] $e");
      throw Exception("❌ Something went wrong: $e");
    }
  }
}
