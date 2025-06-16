import 'package:turfit/app/models/Auth/user.dart';

class EnhancedUserNutrition {
  // Safety minimums based on biological sex
  static const double MIN_CALORIES_FEMALE = 1200;
  static const double MIN_CALORIES_MALE = 1500;
  static const double MIN_CALORIES_OTHER = 1350;

  // Improved LBM calculation with better coefficients
  static double calculateEnhancedLBM(
      Gender gender, double weightKg, double heightCm) {
    if (gender == Gender.male) {
      return (0.407 * weightKg) + (0.267 * heightCm) - 19.2;
    } else if (gender == Gender.female) {
      return (0.252 * weightKg) + (0.473 * heightCm) - 48.3;
    } else {
      return ((0.407 * weightKg) +
              (0.267 * heightCm) -
              19.2 +
              (0.252 * weightKg) +
              (0.473 * heightCm) -
              48.3) /
          2;
    }
  }

  // Katch-McArdle BMR formula
  static double calculatePreciseBMR(
      Gender gender, double weightKg, double heightCm, int age) {
    double lbm = calculateEnhancedLBM(gender, weightKg, heightCm);
    return 370 + (21.6 * lbm);
  }

  // Calorie adjustment based on goal
  static double adjustCaloriesForGoal(
      double baseCalories,
      HealthMode goal,
      WeeklyPace pace,
      Gender gender,
      double currentWeight,
      double targetWeight) {
    double estimatedBodyFat =
        ((currentWeight - targetWeight) / currentWeight) * 100;
    if (estimatedBodyFat > 40) estimatedBodyFat = 40;
    if (estimatedBodyFat < 0) estimatedBodyFat = 5;

    double adjustment = 0;

    switch (goal) {
      case HealthMode.weightLoss:
        switch (pace) {
          case WeeklyPace.slow:
            adjustment = 250;
            break;
          case WeeklyPace.moderate:
            adjustment = 500;
            break;
          case WeeklyPace.fast:
            adjustment = estimatedBodyFat > 25 ? 1000 : 750;
            break;
          case WeeklyPace.none:
            adjustment = 0;
            break;
        }
        baseCalories -= adjustment;
        break;

      case HealthMode.muscleGain:
        baseCalories += estimatedBodyFat < 15 ? 350 : 250;
        break;

      case HealthMode.maintainWeight:
      case HealthMode.none:
        break;
    }

    double minCalories = gender == Gender.male
        ? MIN_CALORIES_MALE
        : gender == Gender.female
            ? MIN_CALORIES_FEMALE
            : MIN_CALORIES_OTHER;

    return baseCalories < minCalories ? minCalories : baseCalories;
  }

  // Macro breakdown based on calories and goal
  static UserMacros calculateScientificMacros(
      double calories, HealthMode goal, double bodyWeight) {
    double proteinPerKg;
    double fatPercentage;
    double minFiberPer1000Cal = 14;

    switch (goal) {
      case HealthMode.weightLoss:
        proteinPerKg = 2.0;
        fatPercentage = 0.3;
        break;
      case HealthMode.muscleGain:
        proteinPerKg = 1.8;
        fatPercentage = 0.25;
        break;
      case HealthMode.maintainWeight:
      case HealthMode.none:
      default:
        proteinPerKg = 1.6;
        fatPercentage = 0.3;
        break;
    }

    int proteinGrams = (bodyWeight * proteinPerKg).round();
    double proteinCalories = proteinGrams * 4;

    double fatCalories = calories * fatPercentage;
    int fatGrams = (fatCalories / 9).round();

    double remainingCalories = calories - (proteinCalories + fatCalories);
    int carbGrams = (remainingCalories / 4).round();

    int waterIntake = (bodyWeight * 35).round();

    int fiberIntake = (calories / 1000 * minFiberPer1000Cal).round();
    if (fiberIntake < 25) fiberIntake = 25;
    if (fiberIntake > 40) fiberIntake = 40;

    return UserMacros(
      calories: calories.round(),
      protein: proteinGrams,
      carbs: carbGrams,
      fat: fatGrams,
      water: waterIntake,
      fiber: fiberIntake,
    );
  }

  // New method that ignores activity level
  static UserMacros calculateNutritionWithoutActivityLevel(
      Gender gender,
      DateTime birthDate,
      double height,
      double weight,
      WeeklyPace weeklyPace,
      double targetWeight,
      HealthMode healthMode) {
    int age = calculateAccurateAge(birthDate);

    double bmr = calculatePreciseBMR(gender, weight, height, age);
    // No TDEE multiplier applied
    double adjustedCalories = adjustCaloriesForGoal(
        bmr, healthMode, weeklyPace, gender, weight, targetWeight);

    return calculateScientificMacros(adjustedCalories, healthMode, weight);
  }

  // Existing method using activity level (for reference)
  static UserMacros calculateScientificNutrition(
      Gender gender,
      DateTime birthDate,
      double height,
      double weight,
      WeeklyPace weeklyPace,
      double targetWeight,
      HealthMode healthMode,
      ActivityLevel activityLevel) {
    int age = calculateAccurateAge(birthDate);

    double bmr = calculatePreciseBMR(gender, weight, height, age);
    double tdee = calculateAccurateTDEE(bmr, activityLevel);
    double adjustedCalories = adjustCaloriesForGoal(
        tdee, healthMode, weeklyPace, gender, weight, targetWeight);

    return calculateScientificMacros(adjustedCalories, healthMode, weight);
  }

  // Original activity-based TDEE calculation
  static double calculateAccurateTDEE(double bmr, ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2;
      case ActivityLevel.lightlyActive:
        return bmr * 1.375;
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55;
      case ActivityLevel.veryActive:
        return bmr * 1.725;
      default:
        return bmr * 1.375;
    }
  }

  static int calculateAccurateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
