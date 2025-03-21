import 'dart:convert';

import 'package:turfit/app/modules/Scanner/views/scan_view.dart';

class NutritionInputQuery {
  final String imageData;
  final ScanMode scanMode;

  NutritionInputQuery({
    required this.imageData,
    required this.scanMode,
  });

  factory NutritionInputQuery.fromRawJson(String str) =>
      NutritionInputQuery.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NutritionInputQuery.fromJson(Map<String, dynamic> json) =>
      NutritionInputQuery(
        imageData: json["imageData"],
        scanMode: json["scanMode"],
      );

  Map<String, dynamic> toJson() => {
        "imageData": imageData,
        // "scanMode": scanMode,
      };
}
