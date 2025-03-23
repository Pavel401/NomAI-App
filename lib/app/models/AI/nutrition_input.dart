import 'package:turfit/app/modules/Scanner/views/scan_view.dart';

class NutritionInputQuery {
  final String imageUrl;
  final ScanMode scanMode;
  final String imageData;

  NutritionInputQuery({
    required this.imageUrl,
    required this.scanMode,
    required this.imageData,
  });

  factory NutritionInputQuery.fromJson(Map<String, dynamic> json) {
    return NutritionInputQuery(
      imageUrl: json['imageUrl'],
      scanMode: ScanMode.values.firstWhere(
        (e) => e.toString() == json['scanMode'],
        orElse: () => ScanMode.gallery,
      ),
      imageData: json['imageData'],
    );
  }

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'scanMode': scanMode.toString(),
        'imageData': imageData,
      };
}
