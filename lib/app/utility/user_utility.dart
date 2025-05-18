import 'package:turfit/app/models/Auth/user.dart';

class EnhancedUserNutrition {
  // Safety minimums based on biological sex
  static const double MIN_CALORIES_FEMALE = 1200;
  static const double MIN_CALORIES_MALE = 1500;
  static const double MIN_CALORIES_OTHER = 1350;

  // Improved LBM calculation with better coefficients based on recent research
  static double calculateEnhancedLBM(
      Gender gender, double weightKg, double heightCm) {
    if (gender == Gender.male) {
      // Enhanced Boer formula for males
      return (0.407 * weightKg) + (0.267 * heightCm) - 19.2;
    } else if (gender == Gender.female) {
      // Enhanced Boer formula for females
      return (0.252 * weightKg) + (0.473 * heightCm) - 48.3;
    } else {
      // Average of both formulas for non-binary individuals
      return ((0.407 * weightKg) +
              (0.267 * heightCm) -
              19.2 +
              (0.252 * weightKg) +
              (0.473 * heightCm) -
              48.3) /
          2;
    }
  }

  // Katch-McArdle BMR formula based on LBM
  static double calculatePreciseBMR(
      Gender gender, double weightKg, double heightCm, int age) {
    double lbm = calculateEnhancedLBM(gender, weightKg, heightCm);
    return 370 + (21.6 * lbm);
  }

  // Evidence-based activity multipliers
  static double calculateAccurateTDEE(double bmr, ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2; // Updated from 1.1 to align with research
      case ActivityLevel.lightlyActive:
        return bmr * 1.375; // Updated from 1.3 to align with research
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55; // Updated from 1.45 to align with research
      case ActivityLevel.veryActive:
        return bmr * 1.725; // Updated from 1.6 to align with research
      default:
        return bmr * 1.375;
    }
  }

  // Scientific calorie adjustment based on goal, with body fat consideration
  static double adjustCaloriesForGoal(
      double tdee,
      HealthMode goal,
      WeeklyPace pace,
      Gender gender,
      double currentWeight,
      double targetWeight) {
    // Estimate body fat percentage based on weight differential
    double estimatedBodyFat =
        ((currentWeight - targetWeight) / currentWeight) * 100;
    if (estimatedBodyFat > 40) estimatedBodyFat = 40;
    if (estimatedBodyFat < 0) estimatedBodyFat = 5; // Minimum healthy body fat

    double adjustment = 0;

    switch (goal) {
      case HealthMode.weightLoss:
        switch (pace) {
          case WeeklyPace.slow:
            // 0.25kg/week loss (~250 cal deficit)
            adjustment = 250;
            break;
          case WeeklyPace.moderate:
            // 0.5kg/week loss (~500 cal deficit)
            adjustment = 500;
            break;
          case WeeklyPace.fast:
            // 0.75-1kg/week loss (~750-1000 cal deficit)
            adjustment = estimatedBodyFat > 25 ? 1000 : 750;
            break;
          case WeeklyPace.none:
            adjustment = 0;
            break;
        }
        tdee -= adjustment;
        break;

      case HealthMode.muscleGain:
        // Scientific surplus based on training status
        tdee += estimatedBodyFat < 15 ? 350 : 250;
        break;

      case HealthMode.maintainWeight:
      case HealthMode.none:
      default:
        // No adjustment needed
        break;
    }

    // Apply safety minimums based on biological sex
    double minCalories = gender == Gender.male
        ? MIN_CALORIES_MALE
        : gender == Gender.female
            ? MIN_CALORIES_FEMALE
            : MIN_CALORIES_OTHER;

    return tdee < minCalories ? minCalories : tdee;
  }

  // Evidence-based macro calculation
  static UserMacros calculateScientificMacros(
      double calories, HealthMode goal, double bodyWeight) {
    double proteinPerKg;
    double fatPercentage;
    double minFiberPer1000Cal = 14;

    switch (goal) {
      case HealthMode.weightLoss:
        // Higher protein during deficit to preserve muscle mass
        proteinPerKg = 2.0;
        fatPercentage = 0.3; // Minimum needed for hormone production
        break;

      case HealthMode.muscleGain:
        // Optimal protein for muscle protein synthesis
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

    // Calculate macros based on research-backed ratios
    int proteinGrams = (bodyWeight * proteinPerKg).round();
    double proteinCalories = proteinGrams * 4;

    double fatCalories = calories * fatPercentage;
    int fatGrams = (fatCalories / 9).round();

    double remainingCalories = calories - (proteinCalories + fatCalories);
    int carbGrams = (remainingCalories / 4).round();

    // Water intake based on weight (ml per kg)
    int waterIntake = (bodyWeight * 35).round();

    // Fiber calculation with healthy minimum and maximum
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

  // Main method that utilizes all the enhanced scientific calculations
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

    // Chain of enhanced calculations
    double bmr = calculatePreciseBMR(gender, weight, height, age);
    double tdee = calculateAccurateTDEE(bmr, activityLevel);
    double adjustedCalories = adjustCaloriesForGoal(
        tdee, healthMode, weeklyPace, gender, weight, targetWeight);

    return calculateScientificMacros(adjustedCalories, healthMode, weight);
  }

  // More accurate age calculation considering leap years
  static int calculateAccurateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Check if birthday has occurred this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
