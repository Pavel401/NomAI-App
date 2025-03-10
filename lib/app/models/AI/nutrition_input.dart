import 'dart:convert';

class NutritionInputQuery {
  final String imageData;

  NutritionInputQuery({
    required this.imageData,
  });

  factory NutritionInputQuery.fromRawJson(String str) =>
      NutritionInputQuery.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NutritionInputQuery.fromJson(Map<String, dynamic> json) =>
      NutritionInputQuery(
        imageData: json["imageData"],
      );

  Map<String, dynamic> toJson() => {
        "imageData": imageData,
      };
}
