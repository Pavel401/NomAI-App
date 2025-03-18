import 'dart:convert';

class NutritionOutput {
  final List<NutritionInfo> response;
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
        response: List<NutritionInfo>.from(
            json["response"].map((x) => NutritionInfo.fromJson(x))),
        status: json["status"],
        message: json["message"],
        inputTokenCount: json["input_token_count"],
        outputTokenCount: json["output_token_count"],
        totalTokenCount: json["total_token_count"],
        estimatedCost: json["estimated_cost"]?.toDouble(),
        executionTimeSeconds: json["execution_time_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "response": List<dynamic>.from(response.map((x) => x.toJson())),
        "status": status,
        "message": message,
        "input_token_count": inputTokenCount,
        "output_token_count": outputTokenCount,
        "total_token_count": totalTokenCount,
        "estimated_cost": estimatedCost,
        "execution_time_seconds": executionTimeSeconds,
      };
}

class NutritionInfo {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fibre;
  final int fat;
  final double quantity;
  final String portion;

  NutritionInfo({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fibre,
    required this.fat,
    required this.quantity,
    required this.portion,
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
        quantity: json["quantity"],
        portion: json["portion"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fibre": fibre,
        "fat": fat,
        "quantity": quantity,
        "portion": portion,
      };
}
