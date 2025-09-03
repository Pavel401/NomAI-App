import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/services/nutrition_service.dart';

/// UI configuration for health score display
class HealthScoreConfig {
  final Color color;
  final IconData icon;
  final String label;

  const HealthScoreConfig({
    required this.color,
    required this.icon,
    required this.label,
  });

  static HealthScoreConfig fromLevel(HealthScoreLevel level) {
    switch (level) {
      case HealthScoreLevel.good:
        return HealthScoreConfig(
          color: MealAIColors.blackText,
          icon: Icons.check_circle,
          label: 'Good',
        );
      case HealthScoreLevel.moderate:
        return HealthScoreConfig(
          color: MealAIColors.grey,
          icon: Icons.warning,
          label: 'Moderate',
        );
      case HealthScoreLevel.poor:
        return HealthScoreConfig(
          color: MealAIColors.grey.withOpacity(0.7),
          icon: Icons.error,
          label: 'Poor',
        );
    }
  }
}

/// UI model for nutrition value display
class NutritionValueItem {
  final String value;
  final String label;
  final IconData icon;

  const NutritionValueItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  static List<NutritionValueItem> fromTotals(NutritionTotals totals) {
    return [
      NutritionValueItem(
        value: '${totals.calories}',
        label: 'Calories',
        icon: Icons.local_fire_department,
      ),
      NutritionValueItem(
        value: '${totals.protein}g',
        label: 'Protein',
        icon: Icons.fitness_center,
      ),
      NutritionValueItem(
        value: '${totals.carbs}g',
        label: 'Carbs',
        icon: Icons.grain,
      ),
      NutritionValueItem(
        value: '${totals.fat}g',
        label: 'Fat',
        icon: Icons.opacity,
      ),
    ];
  }
}

/// UI model for info chips
class InfoChipItem {
  final String label;
  final String value;

  const InfoChipItem({
    required this.label,
    required this.value,
  });
}

/// Constants for UI styling
class NutritionUIConstants {
  // Spacing
  static const double sectionSpacing = 16.0;
  static const double itemSpacing = 12.0;
  static const double smallSpacing = 8.0;

  // Sizes
  static const double iconSize = 20.0;
  static const double smallIconSize = 16.0;
  static const double cardPadding = 16.0;

  // Border radius
  static const double cardRadius = 16.0;
  static const double chipRadius = 20.0;
  static const double smallRadius = 8.0;

  // Grid settings
  static const int nutritionGridColumns = 2;
  static const double nutritionGridAspectRatio = 2.5;
  static const double nutritionGridSpacing = 12.0;
}
