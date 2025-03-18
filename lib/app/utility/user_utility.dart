import 'package:turfit/app/models/Auth/user.dart';

class UserUtility {
  static const double MIN_CALORIES_FEMALE = 1200;
  static const double MIN_CALORIES_MALE = 1500;
  static const double MIN_CALORIES_OTHER = 1350;

  static double calculateLBM(Gender gender, double weight, double height) {
    if (gender == Gender.male) {
      return (0.407 * weight) + (0.267 * height) - 19.2;
    } else if (gender == Gender.female) {
      return (0.252 * weight) + (0.473 * height) - 48.3;
    } else {
      return ((0.407 * weight) +
              (0.267 * height) -
              19.2 +
              (0.252 * weight) +
              (0.473 * height) -
              48.3) /
          2;
    }
  }

  static double calculateBMR(
      Gender gender, double weight, double height, int age) {
    double lbm = calculateLBM(gender, weight, height);
    return 370 + (21.6 * lbm);
  }

  static double calculateTDEE(double bmr, ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.1;
      case ActivityLevel.lightlyActive:
        return bmr * 1.3;
      case ActivityLevel.moderatelyActive:
        return bmr * 1.45;
      case ActivityLevel.veryActive:
        return bmr * 1.6;
      default:
        return bmr * 1.3;
    }
  }

  static double adjustCaloriesForGoal(
      double tdee,
      HealthMode goal,
      WeeklyPace pace,
      Gender gender,
      double currentWeight,
      double targetWeight) {
    double bodyFat = ((currentWeight - targetWeight) / currentWeight) * 100;
    if (bodyFat > 40) bodyFat = 40;

    double deficit = 0;

    switch (goal) {
      case HealthMode.weightLoss:
        switch (pace) {
          case WeeklyPace.slow:
            deficit = tdee * 0.10;
            break;
          case WeeklyPace.moderate:
            deficit = tdee * 0.20;
            break;
          case WeeklyPace.fast:
            deficit = tdee * 0.30;
            break;
          case WeeklyPace.none:
            // TODO: Handle this case.
            break;
        }
        if (bodyFat > 30) deficit += tdee * 0.10;
        tdee -= deficit;
        break;

      case HealthMode.muscleGain:
        tdee += 300;
        break;

      case HealthMode.maintainWeight:
        tdee = tdee;
        break;

      case HealthMode.none:
      default:
        tdee = tdee;
        break;
    }

    double minCalories = gender == Gender.male
        ? MIN_CALORIES_MALE
        : gender == Gender.female
            ? MIN_CALORIES_FEMALE
            : MIN_CALORIES_OTHER;

    return tdee < minCalories ? minCalories : tdee;
  }

  static UserMacros calculateMacros(
      double calories, HealthMode goal, double bodyWeight) {
    double proteinPerKg;
    double fatPercentage;
    double minCarbsPerKg;
    double maxCarbsPerKg;

    switch (goal) {
      case HealthMode.weightLoss:
        proteinPerKg = 1.2;
        fatPercentage = 0.25;
        minCarbsPerKg = 1.5;
        maxCarbsPerKg = 2.0;
        break;
      case HealthMode.muscleGain:
        proteinPerKg = 1.6;
        fatPercentage = 0.25;
        minCarbsPerKg = 3.0;
        maxCarbsPerKg = 4.0;
        break;
      case HealthMode.maintainWeight:
        proteinPerKg = 1.0;
        fatPercentage = 0.25;
        minCarbsPerKg = 2.0;
        maxCarbsPerKg = 3.0;
        break;
      case HealthMode.none:
      default:
        proteinPerKg = 1.0;
        fatPercentage = 0.25;
        minCarbsPerKg = 2.0;
        maxCarbsPerKg = 3.0;
        break;
    }

    int proteinGrams = (bodyWeight * proteinPerKg).round();
    double proteinCalories = proteinGrams * 4;

    double fatCalories = calories * fatPercentage;
    int fatGrams = (fatCalories / 9).round();

    double remainingCalories = calories - (proteinCalories + fatCalories);
    int carbGrams = (remainingCalories / 4).round();

    int waterIntake = (bodyWeight * 35).round();
    int fiberIntake = (calories / 1000 * 14).round();
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

  static UserMacros calculateUserNutrition(
      Gender gender,
      DateTime birthDate,
      double height,
      double weight,
      WeeklyPace weeklyPace,
      double targetWeight,
      HealthMode healthMode,
      ActivityLevel activityLevel) {
    int age = DateTime.now().year - birthDate.year;

    double bmr = calculateBMR(gender, weight, height, age);
    double tdee = calculateTDEE(bmr, activityLevel);
    double adjustedCalories = adjustCaloriesForGoal(
        tdee, healthMode, weeklyPace, gender, weight, targetWeight);

    return calculateMacros(adjustedCalories, healthMode, weight);
  }

  /// Calculate accurate age from birthdate considering month and day
  static int calculateAge(DateTime birthDate) {
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
