import 'package:turfit/app/modules/Scanner/views/scan_view.dart';

class NutritionInputQuery {
  final String imageUrl;
  final ScanMode? scanMode;
  String? imageData;
  String? message;

  String? imageFilePath;

  List<String>? dietaryPreferences;
  List<String>? allergies;

  List<String>? selectedGoals;

  NutritionInputQuery({
    required this.imageUrl,
    required this.scanMode,
    this.imageData,
    this.message,
    this.imageFilePath,
    this.dietaryPreferences,
    this.allergies,
    this.selectedGoals,
  });

  factory NutritionInputQuery.fromJson(Map<String, dynamic> json) {
    return NutritionInputQuery(
      imageUrl: json['imageUrl'] ?? '',
      scanMode: json['scanMode'] == null
          ? ScanMode.food
          : ScanMode.values.byName(json['scanMode']),
      imageData: json['imageData'] ?? '',
      message: json['message'] ?? '',
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : [],
      allergies:
          json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      selectedGoals: json['selectedGoals'] != null
          ? List<String>.from(json['selectedGoals'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'scanMode': scanMode!.name,

        // 'imageData' is intentionally excluded
      };

  Map<String, dynamic> toJsonForMealAIBackend() => {
        // 'imageData' is intentionally excluded

        "imageData": imageData,
        "message": message,
        "dietaryPreferences": dietaryPreferences,
        "allergies": allergies,
        "selectedGoals": selectedGoals,
      };
}
