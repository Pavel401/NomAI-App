import 'package:turfit/app/models/Auth/user.dart';

class UserUtility {
  // Minimum healthy calorie intakes
  static const double MIN_CALORIES_FEMALE = 1200;
  static const double MIN_CALORIES_MALE = 1500;
  static const double MIN_CALORIES_OTHER = 1350;

  /// Calculate Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
  /// Height should be in cm, weight in kg, age in years.
  static double calculateBMR(
      Gender gender, double weight, double height, int age) {
    // Input validation
    if (weight <= 0 || height <= 0 || age <= 0 || age > 120) {
      throw ArgumentError(
          'Invalid input: weight, height, and age must be positive values');
    }

    if (gender == Gender.male) {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender == Gender.female) {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    } else {
      // For non-binary individuals, offer options or use an average
      double maleBMR = 10 * weight + 6.25 * height - 5 * age + 5;
      double femaleBMR = 10 * weight + 6.25 * height - 5 * age - 161;
      return (maleBMR + femaleBMR) /
          2; // Average of male and female calculations
    }
  }

  /// Calculate Total Daily Energy Expenditure (TDEE) based on activity level.
  static double calculateTDEE(double bmr, ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2; // Little or no exercise
      case ActivityLevel.lightlyActive:
        return bmr * 1.375; // Light exercise 1-3 days/week
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55; // Moderate exercise 3-5 days/week
      case ActivityLevel.veryActive:
        return bmr * 1.725; // Hard exercise 6-7 days/week

      default:
        return bmr * 1.375;
    }
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

  /// Adjust calories based on the user's goal and desired pace.
  /// Ensures healthy minimum calorie levels.
  static double adjustCaloriesForGoal(
      double tdee,
      HealthMode goal,
      WeeklyPace pace,
      Gender gender,
      double currentWeight,
      double targetWeight) {
    double adjustedCalories = tdee;

    switch (goal) {
      case HealthMode.weightLoss:
        // Calculate deficit based on pace
        double deficit = 0;
        switch (pace) {
          case WeeklyPace.slow:
            deficit = 250; // ~0.25kg/week
            break;
          case WeeklyPace.moderate:
            deficit = 500; // ~0.5kg/week
            break;
          case WeeklyPace.fast:
            deficit = 750; // ~0.75kg/week
            break;
          default:
            deficit = 500;
        }

        // Adaptive deficit: reduce as approaching target weight
        if (currentWeight > targetWeight) {
          double weightDifference = currentWeight - targetWeight;
          // If within 5kg of goal, gradually reduce deficit
          if (weightDifference < 5) {
            deficit = deficit * (weightDifference / 5);
          }
        }

        adjustedCalories = tdee - deficit;
        break;

      case HealthMode.muscleGain:
        adjustedCalories = tdee + 500; // Surplus for muscle gain
        break;

      case HealthMode.maintainWeight:
        adjustedCalories = tdee;
        break;

      default:
        adjustedCalories = tdee;
    }

    // Ensure minimum healthy calorie levels
    double minCalories = MIN_CALORIES_FEMALE;
    if (gender == Gender.male) {
      minCalories = MIN_CALORIES_MALE;
    } else if (gender == Gender.other) {
      minCalories = MIN_CALORIES_OTHER;
    }

    return adjustedCalories < minCalories ? minCalories : adjustedCalories;
  }

  static UserMacros calculateMacros(
      double calories, HealthMode goal, double bodyWeight) {
    double proteinPerKg;
    double fatPercentage;
    double minCarbsPerKg;
    double maxCarbsPerKg;

    // Set dynamic macronutrient targets based on goal
    switch (goal) {
      case HealthMode.weightLoss:
        proteinPerKg = 1.0;
        fatPercentage = 0.25;
        minCarbsPerKg = 1.5;
        maxCarbsPerKg = 2.0;
        break;
      case HealthMode.muscleGain:
        proteinPerKg = 1.2;
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
      default:
        proteinPerKg = 1.0;
        fatPercentage = 0.25;
        minCarbsPerKg = 2.0;
        maxCarbsPerKg = 3.0;
    }

    // Calculate Protein Intake
    int proteinGrams = (bodyWeight * proteinPerKg).round();
    double proteinCalories = proteinGrams * 4;

    // Calculate Fat Intake
    double fatCalories = calories * fatPercentage;
    int fatGrams = (fatCalories / 9).round();

    // Ensure minimum fat intake (0.5g per kg body weight)
    int minFatGrams = (bodyWeight * 0.5).round();
    if (fatGrams < minFatGrams) {
      fatGrams = minFatGrams;
      fatCalories = fatGrams * 9;
    }

    // Calculate remaining calories for carbs
    double remainingCalories = calories - (proteinCalories + fatCalories);
    int carbGrams = (remainingCalories / 4).round();

    // Ensure minimum and maximum carb intake
    int minCarbGrams = (bodyWeight * minCarbsPerKg).round();
    int maxCarbGrams = (bodyWeight * maxCarbsPerKg).round();

    // Adjust carbs based on goal and available calories
    if (carbGrams < minCarbGrams) {
      carbGrams = minCarbGrams;
    } else if (carbGrams > maxCarbGrams) {
      carbGrams = maxCarbGrams;
    }

    // Calculate water intake (40ml/kg during muscle gain, 35ml/kg otherwise)
    int waterIntake =
        (bodyWeight * (goal == HealthMode.muscleGain ? 40 : 35)).round();

    // Calculate fiber recommendation (14g per 1000 calories)
    int fiberRecommendation = (calories / 1000 * 14).round();
    if (fiberRecommendation < 25) fiberRecommendation = 25;
    if (fiberRecommendation > 40) fiberRecommendation = 40;

    return UserMacros(
      calories: calories.round(),
      protein: proteinGrams,
      carbs: carbGrams,
      fat: fatGrams,
      water: waterIntake,
      fiber: fiberRecommendation,
    );
  }

  /// Calculate user nutrition based on profile and goals.
  static UserMacros calculateUserNutrition(
      Gender gender,
      DateTime birthDate,
      double height,
      double weight,
      WeeklyPace weeklyPace,
      double targetWeight,
      HealthMode healthMode,
      ActivityLevel activityLevel) {
    print("The weight is $weight");
    print("The height is $height");
    print("The target weight is $targetWeight");
    print("The weekly pace is $weeklyPace");
    print("The health mode is $healthMode");
    print("The activity level is $activityLevel");

    int age = calculateAge(birthDate);

    print("The age is $age");

    double bmr = calculateBMR(gender, weight, height, age);

    print("-------------------------");
    print("The BMR is $bmr");

    double tdee = calculateTDEE(bmr, activityLevel);
    print("The TDEE is $tdee");
    double adjustedCalories = adjustCaloriesForGoal(
        tdee, healthMode, weeklyPace, gender, weight, targetWeight);

    print("The adjusted calories is $adjustedCalories");

    print("-------------------------");

    return calculateMacros(adjustedCalories, healthMode, weight);
  }
}
