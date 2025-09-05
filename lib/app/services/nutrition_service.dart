import 'package:NomAi/app/models/Agent/agent_response.dart';

class NutritionService {
  /// Extracts nutrition data from agent response tool returns
  static AgentResponsePayload? extractNutritionResponse(
      List<ToolReturn> toolReturns) {
    for (final toolReturn in toolReturns) {
      if (toolReturn.toolName == 'calculate_nutrition_by_food_description' &&
          toolReturn.content?.response != null) {
        return toolReturn.content!.response!;
      }
    }
    return null;
  }

  /// Calculates total nutrition from ingredients
  static NutritionTotals calculateTotalNutrition(List<Ingredient> ingredients) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int totalFiber = 0;

    for (final ingredient in ingredients) {
      totalCalories += ingredient.calories ?? 0;
      totalProtein += ingredient.protein ?? 0;
      totalCarbs += ingredient.carbs ?? 0;
      totalFat += ingredient.fat ?? 0;
      totalFiber += ingredient.fiber ?? 0;
    }

    return NutritionTotals(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
    );
  }

  /// Determines health score color based on score value
  static HealthScoreLevel getHealthScoreLevel(int score) {
    if (score >= 7) return HealthScoreLevel.good;
    if (score >= 5) return HealthScoreLevel.moderate;
    return HealthScoreLevel.poor;
  }

  /// Checks if a response has valid nutrition data
  static bool hasNutritionData(AgentResponsePayload response) {
    return response.ingredients != null && response.ingredients!.isNotEmpty;
  }

  /// Gets a display-friendly portion text
  static String getPortionDisplayText(AgentResponsePayload response) {
    final portionSize = response.portionSize ?? 0;
    final portion = response.portion ?? '';

    if (portionSize > 0 && portion.isNotEmpty) {
      return '$portionSize $portion';
    } else if (portion.isNotEmpty) {
      return portion;
    }
    return 'Unknown portion';
  }
}

/// Data class for nutrition totals
class NutritionTotals {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;

  const NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
}

/// Enum for health score levels
enum HealthScoreLevel {
  good,
  moderate,
  poor;

  String get displayText {
    switch (this) {
      case HealthScoreLevel.good:
        return 'Good';
      case HealthScoreLevel.moderate:
        return 'Moderate';
      case HealthScoreLevel.poor:
        return 'Poor';
    }
  }
}
