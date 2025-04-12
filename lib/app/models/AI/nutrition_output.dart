import 'dart:convert';

class NutritionOutput {
  final NutritionResponse response;
  final int status;
  final String message;
  final int inputTokenCount;
  final int outputTokenCount;
  final int totalTokenCount;
  final double estimatedCost;
  final double executionTimeSeconds;

  NutritionOutput({
    required this.response,
    required this.status,
    required this.message,
    required this.inputTokenCount,
    required this.outputTokenCount,
    required this.totalTokenCount,
    required this.estimatedCost,
    required this.executionTimeSeconds,
  });

  factory NutritionOutput.fromRawJson(String str) =>
      NutritionOutput.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NutritionOutput.fromJson(Map<String, dynamic> json) =>
      NutritionOutput(
        response: NutritionResponse.fromJson(json["response"]),
        status: json["status"],
        message: json["message"],
        inputTokenCount: json["input_token_count"],
        outputTokenCount: json["output_token_count"],
        totalTokenCount: json["total_token_count"],
        estimatedCost: json["estimated_cost"]?.toDouble(),
        executionTimeSeconds: json["execution_time_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "status": status,
        "message": message,
        "input_token_count": inputTokenCount,
        "output_token_count": outputTokenCount,
        "total_token_count": totalTokenCount,
        "estimated_cost": estimatedCost,
        "execution_time_seconds": executionTimeSeconds,
      };
}

class NutritionResponse {
  final String foodName;
  final List<NutritionInfo> nutritionData;

  NutritionResponse({
    required this.foodName,
    required this.nutritionData,
  });

  factory NutritionResponse.fromJson(Map<String, dynamic> json) =>
      NutritionResponse(
        foodName: json["foodName"],
        nutritionData: List<NutritionInfo>.from(
            json["nutritionData"].map((x) => NutritionInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "foodName": foodName,
        "nutritionData":
            List<dynamic>.from(nutritionData.map((x) => x.toJson())),
      };
}

class NutritionInfo {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fibre;
  final int fat;
  final String portion;
  final String? preparationMethod;
  final double healthScore;
  final String analysis;

  NutritionInfo({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fibre,
    required this.fat,
    required this.portion,
    required this.preparationMethod,
    required this.healthScore,
    required this.analysis,
  });

  factory NutritionInfo.fromRawJson(String str) =>
      NutritionInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
        name: json["name"],
        calories: json["calories"],
        protein: json["protein"],
        carbs: json["carbs"],
        fibre: json["fibre"],
        fat: json["fat"],
        portion: json["portion"],
        preparationMethod: json["preparationMethod"],
        healthScore: json["healthScore"]?.toDouble(),
        analysis: json["analysis"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fibre": fibre,
        "fat": fat,
        "portion": portion,
        "preparationMethod": preparationMethod,
        "healthScore": healthScore,
        "analysis": analysis,
      };
}
