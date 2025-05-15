// To parse this JSON data, do
//
//     final nutritionOutput = nutritionOutputFromJson(jsonString);

import 'dart:convert';

NutritionOutput nutritionOutputFromJson(String str) =>
    NutritionOutput.fromJson(json.decode(str));

String nutritionOutputToJson(NutritionOutput data) =>
    json.encode(data.toJson());

class NutritionOutput {
  Response? response;
  int? status;
  String? message;
  int? inputTokenCount;
  int? outputTokenCount;
  int? totalTokenCount;
  double? estimatedCost;

  double? executionTimeSeconds;

  NutritionOutput({
    this.response,
    this.status,
    this.message,
    this.inputTokenCount,
    this.outputTokenCount,
    this.totalTokenCount,
    this.estimatedCost,
    this.executionTimeSeconds,
  });

  factory NutritionOutput.fromJson(Map<String, dynamic> json) =>
      NutritionOutput(
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
        status: json["status"],
        message: json["message"],
        inputTokenCount: json["input_token_count"],
        outputTokenCount: json["output_token_count"],
        totalTokenCount: json["total_token_count"],
        estimatedCost: json["estimated_cost"]?.toDouble(),
        executionTimeSeconds: json["execution_time_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "response": response?.toJson(),
        "status": status,
        "message": message,
        "input_token_count": inputTokenCount,
        "output_token_count": outputTokenCount,
        "total_token_count": totalTokenCount,
        "estimated_cost": estimatedCost,
        "execution_time_seconds": executionTimeSeconds,
      };
}

class Response {
  String? foodName;
  List<Ingredient>? ingredients;
  List<Ingredient>? suggestAlternatives;

  Response({
    this.foodName,
    this.ingredients,
    this.suggestAlternatives,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        foodName: json["foodName"],
        ingredients: json["ingredients"] == null
            ? []
            : List<Ingredient>.from(
                json["ingredients"]!.map((x) => Ingredient.fromJson(x))),
        suggestAlternatives: json["suggestAlternatives"] == null
            ? []
            : List<Ingredient>.from(json["suggestAlternatives"]!
                .map((x) => Ingredient.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "foodName": foodName,
        "ingredients": ingredients == null
            ? []
            : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
        "suggestAlternatives": suggestAlternatives == null
            ? []
            : List<dynamic>.from(suggestAlternatives!.map((x) => x.toJson())),
      };
}

class Ingredient {
  String? name;
  int? calories;
  int? protein;
  int? carbs;
  int? fibre;
  int? fat;
  int? quantity;
  String? portion;
  int? healthScore;
  String? healthComments;

  Ingredient({
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fibre,
    this.fat,
    this.quantity,
    this.portion,
    this.healthScore,
    this.healthComments,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json["name"],
        calories: json["calories"],
        protein: json["protein"],
        carbs: json["carbs"],
        fibre: json["fibre"],
        fat: json["fat"],
        quantity: json["quantity"],
        portion: json["portion"],
        healthScore: json["healthScore"],
        healthComments: json["healthComments"],
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
        "healthScore": healthScore,
        "healthComments": healthComments,
      };
}
