import 'package:turfit/app/models/AI/nutrition_output.dart';
import 'package:turfit/app/modules/Scanner/views/scan_view.dart';

class NutritionRecord {
  final NutritionOutput nutritionOutput;
  final DateTime recordTime;
  final String? foodImageData;
  final String? barcodeData;
  final ScanMode scanMode;

  NutritionRecord({
    required this.nutritionOutput,
    required this.recordTime,
    required this.scanMode,
    this.foodImageData,
    this.barcodeData,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) =>
      NutritionRecord(
        nutritionOutput: NutritionOutput.fromRawJson(json['nutritionOutput']),
        recordTime: DateTime.parse(json['recordTime']),
        foodImageData: json['foodImageData'] as String?,
        barcodeData: json['barcodeData'] as String?,
        scanMode: ScanMode.values[json['scanMode']],
      );

  Map<String, dynamic> toJson() => {
        'nutritionOutput': nutritionOutput.toRawJson(),
        'recordTime': recordTime.toIso8601String(),
        'foodImageData': foodImageData,
        'barcodeData': barcodeData,
        'scanMode': scanMode.index,
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
            .map((item) => NutritionRecord.fromJson(item))
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
