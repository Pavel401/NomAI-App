import 'package:turfit/app/models/AI/nutrition_input.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';

class NutritionRecord {
  final NutritionOutput nutritionOutput;
  final NutritionInputQuery nutritionInputQuery;
  final DateTime recordTime;

  NutritionRecord({
    required this.nutritionOutput,
    required this.recordTime,
    required this.nutritionInputQuery,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) =>
      NutritionRecord(
        nutritionOutput: NutritionOutput.fromJson(json['nutritionOutput']),
        nutritionInputQuery:
            NutritionInputQuery.fromJson(json['nutritionInputQuery']),
        recordTime: DateTime.parse(json['recordTime']),
      );

  Map<String, dynamic> toJson() => {
        'nutritionOutput': nutritionOutput.toJson(),
        'recordTime': recordTime.toIso8601String(),
        'nutritionInputQuery': nutritionInputQuery.toJson(),
      };
}

class DailyNutritionRecords {
  final List<NutritionRecord> dailyRecords;
  final String recordId;
  final DateTime recordDate;

  DailyNutritionRecords({
    required this.dailyRecords,
    required this.recordDate,
    required this.recordId,
  });

  factory DailyNutritionRecords.fromJson(Map<String, dynamic> json) =>
      DailyNutritionRecords(
        dailyRecords: (json['dailyRecords'] as List)
            .map((item) =>
                NutritionRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
        recordDate: DateTime.parse(json['recordDate']),
        recordId: json['recordId'],
      );

  Map<String, dynamic> toJson() => {
        'dailyRecords': dailyRecords.map((record) => record.toJson()).toList(),
        'recordDate': recordDate.toIso8601String(),
        'recordId': recordId,
      };
}
