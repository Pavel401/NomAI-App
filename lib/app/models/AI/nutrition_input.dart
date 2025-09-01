import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';

class NutritionInputQuery {
  final String? imageUrl;
  final ScanMode? scanMode;
  String? imageData;
  String? food_description;

  String? imageFilePath;

  List<String>? dietaryPreferences;
  List<String>? allergies;

  List<String>? selectedGoals;

  NutritionInputQuery({
    this.imageUrl,
    required this.scanMode,
    this.imageData,
    this.food_description,
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
      food_description: json['food_description'] ?? '',
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

      };

  Map<String, dynamic> toJsonForMealAIBackend() => {

        "imageData": imageData,
        "food_description": food_description,
        "dietaryPreferences": dietaryPreferences,
        "allergies": allergies,
        "selectedGoals": selectedGoals,
      };
}
