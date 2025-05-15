import 'package:turfit/app/constants/enums.dart';
import 'package:turfit/app/models/AI/nutrition_input.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';

class NutritionRecord {
  NutritionOutput? nutritionOutput;
  NutritionInputQuery? nutritionInputQuery;
  DateTime? recordTime;
  ProcessingStatus? processingStatus;

  NutritionRecord({
    this.nutritionOutput,
    this.recordTime,
    this.nutritionInputQuery,
    this.processingStatus,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) =>
      NutritionRecord(
        nutritionOutput: NutritionOutput.fromJson(json['nutritionOutput']),
        nutritionInputQuery:
            NutritionInputQuery.fromJson(json['nutritionInputQuery']),
        recordTime: DateTime.parse(json['recordTime']),
        processingStatus:
            ProcessingStatus.values.byName(json['processingStatus']),
      );

  Map<String, dynamic> toJson() => {
        'nutritionOutput': nutritionOutput!.toJson(),
        'recordTime': recordTime!.toIso8601String(),
        'nutritionInputQuery': nutritionInputQuery!.toJson(),
        'processingStatus': processingStatus!.name,
      };
}

class DailyNutritionRecords {
  final List<NutritionRecord> dailyRecords;
  final String recordId;
  final DateTime recordDate;
  int dailyConsumedCalories = 0;
  int dailyBurnedCalories = 0;
  int dailyConsumedProtein = 0;
  int dailyConsumedFat = 0;
  int dailyConsumedCarb = 0;

  DailyNutritionRecords({
    required this.dailyRecords,
    required this.recordDate,
    required this.recordId,
    this.dailyConsumedCalories = 0,
    this.dailyBurnedCalories = 0,
    this.dailyConsumedProtein = 0,
    this.dailyConsumedFat = 0,
    this.dailyConsumedCarb = 0,
  });

  factory DailyNutritionRecords.fromJson(Map<String, dynamic> json) =>
      DailyNutritionRecords(
        dailyRecords: (json['dailyRecords'] as List)
            .map((item) =>
                NutritionRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
        recordDate: DateTime.parse(json['recordDate']),
        recordId: json['recordId'],
        dailyConsumedCalories: json['dailyConsumedCalories'] ?? 0,
        dailyBurnedCalories: json['dailyBurnedCalories'] ?? 0,
        dailyConsumedProtein: json['dailyConsumedProtein'] ?? 0,
        dailyConsumedFat: json['dailyConsumedFat'] ?? 0,
        dailyConsumedCarb: json['dailyConsumedCarb'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'dailyRecords': dailyRecords.map((record) => record.toJson()).toList(),
        'recordDate': recordDate.toIso8601String(),
        'recordId': recordId,
        'dailyConsumedCalories': dailyConsumedCalories,
        'dailyBurnedCalories': dailyBurnedCalories,
        'dailyConsumedProtein': dailyConsumedProtein,
        'dailyConsumedFat': dailyConsumedFat,
        'dailyConsumedCarb': dailyConsumedCarb,
      };
}
