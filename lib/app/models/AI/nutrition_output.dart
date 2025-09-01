import 'dart:convert';

NutritionOutput nutritionOutputFromJson(String str) =>
    NutritionOutput.fromJson(json.decode(str));

String nutritionOutputToJson(NutritionOutput data) =>
    json.encode(data.toJson());

class NutritionOutput {
  NutritionResponse? response;
  int? status;
  String? message;
  Metadata? metadata;
  int? inputTokenCount;
  int? outputTokenCount;
  int? totalTokenCount;
  double? estimatedCost;
  double? executionTimeSeconds;

  NutritionOutput({
    this.response,
    this.status,
    this.message,
    this.metadata,
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
            : NutritionResponse.fromJson(json["response"]),
        status: json["status"],
        message: json["message"],
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
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
        "metadata": metadata?.toJson(),
        "input_token_count": inputTokenCount,
        "output_token_count": outputTokenCount,
        "total_token_count": totalTokenCount,
        "estimated_cost": estimatedCost,
        "execution_time_seconds": executionTimeSeconds,
      };
}

class NutritionResponse {
  String? message;
  String? foodName;
  String? portion;
  double? portionSize;
  int? confidenceScore;
  List<Ingredient>? ingredients;
  List<PrimaryConcern>? primaryConcerns;
  List<Ingredient>? suggestAlternatives;
  int? overallHealthScore;
  String? overallHealthComments;

  NutritionResponse({
    this.message,
    this.foodName,
    this.portion,
    this.portionSize,
    this.confidenceScore,
    this.ingredients,
    this.primaryConcerns,
    this.suggestAlternatives,
    this.overallHealthScore,
    this.overallHealthComments,
  });

  factory NutritionResponse.fromJson(Map<String, dynamic> json) =>
      NutritionResponse(
        message: json["message"],
        foodName: json["foodName"],
        portion: json["portion"],
        portionSize: json["portionSize"]?.toDouble(),
        confidenceScore: json["confidenceScore"],
        ingredients: json["ingredients"] == null
            ? []
            : List<Ingredient>.from(
                json["ingredients"]!.map((x) => Ingredient.fromJson(x))),
        primaryConcerns: json["primaryConcerns"] == null
            ? []
            : List<PrimaryConcern>.from(json["primaryConcerns"]!
                .map((x) => PrimaryConcern.fromJson(x))),
        suggestAlternatives: json["suggestAlternatives"] == null
            ? []
            : List<Ingredient>.from(json["suggestAlternatives"]!
                .map((x) => Ingredient.fromJson(x))),
        overallHealthScore: json["overallHealthScore"],
        overallHealthComments: json["overallHealthComments"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "foodName": foodName,
        "portion": portion,
        "portionSize": portionSize,
        "confidenceScore": confidenceScore,
        "ingredients": ingredients == null
            ? []
            : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
        "primaryConcerns": primaryConcerns == null
            ? []
            : List<dynamic>.from(primaryConcerns!.map((x) => x.toJson())),
        "suggestAlternatives": suggestAlternatives == null
            ? []
            : List<dynamic>.from(suggestAlternatives!.map((x) => x.toJson())),
        "overallHealthScore": overallHealthScore,
        "overallHealthComments": overallHealthComments,
      };
}

class Ingredient {
  String? name;
  int? calories;
  int? protein;
  int? carbs;
  int? fiber; // Changed from fibre to fiber
  int? fat;
  int? sugar;
  int? sodium;
  int? healthScore;
  String? healthComments;

  Ingredient({
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.fat,
    this.sugar,
    this.sodium,
    this.healthScore,
    this.healthComments,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json["name"],
        calories: json["calories"],
        protein: json["protein"],
        carbs: json["carbs"],
        fiber: json["fiber"], // Changed from fibre to fiber
        fat: json["fat"],
        sugar: json["sugar"],
        sodium: json["sodium"],
        healthScore: json["healthScore"],
        healthComments: json["healthComments"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fiber": fiber, // Changed from fibre to fiber
        "fat": fat,
        if (sugar != null) "sugar": sugar,
        if (sodium != null) "sodium": sodium,
        "healthScore": healthScore,
        "healthComments": healthComments,
      };
}

class PrimaryConcern {
  String? issue;
  String? explanation;
  List<Recommendation>? recommendations;

  PrimaryConcern({
    this.issue,
    this.explanation,
    this.recommendations,
  });

  factory PrimaryConcern.fromJson(Map<String, dynamic> json) => PrimaryConcern(
        issue: json["issue"],
        explanation: json["explanation"],
        recommendations: json["recommendations"] == null
            ? []
            : List<Recommendation>.from(json["recommendations"]!
                .map((x) => Recommendation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "issue": issue,
        "explanation": explanation,
        "recommendations": recommendations == null
            ? []
            : List<dynamic>.from(recommendations!.map((x) => x.toJson())),
      };
}

class Recommendation {
  String? food;
  String? quantity;
  String? reasoning;

  Recommendation({
    this.food,
    this.quantity,
    this.reasoning,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        food: json["food"],
        quantity: json["quantity"],
        reasoning: json["reasoning"],
      );

  Map<String, dynamic> toJson() => {
        "food": food,
        "quantity": quantity,
        "reasoning": reasoning,
      };
}

class Metadata {
  int? inputTokenCount;
  int? outputTokenCount;
  int? totalTokenCount;
  double? estimatedCost;
  double? executionTimeSeconds;

  Metadata({
    this.inputTokenCount,
    this.outputTokenCount,
    this.totalTokenCount,
    this.estimatedCost,
    this.executionTimeSeconds,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        inputTokenCount: json["input_token_count"],
        outputTokenCount: json["output_token_count"],
        totalTokenCount: json["total_token_count"],
        estimatedCost: json["estimated_cost"]?.toDouble(),
        executionTimeSeconds: json["execution_time_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "input_token_count": inputTokenCount,
        "output_token_count": outputTokenCount,
        "total_token_count": totalTokenCount,
        "estimated_cost": estimatedCost,
        "execution_time_seconds": executionTimeSeconds,
      };
}
