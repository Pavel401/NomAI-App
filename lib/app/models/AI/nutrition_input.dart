import 'package:turfit/app/modules/Scanner/views/scan_view.dart';

class NutritionInputQuery {
  final String imageUrl;
  final ScanMode? scanMode;
  String? imageData;
  String? imageFilePath;

  NutritionInputQuery({
    required this.imageUrl,
    required this.scanMode,
    this.imageData,
    this.imageFilePath,
  });

  factory NutritionInputQuery.fromJson(Map<String, dynamic> json) {
    return NutritionInputQuery(
      imageUrl: json['imageUrl'] ?? '',
      scanMode: json['scanMode'] == null
          ? ScanMode.food
          : ScanMode.values.byName(json['scanMode']),
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
      };
}
