import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Gender { male, female, other, none }

enum WeeklyPace { slow, moderate, fast, none }

enum HealthMode {
  none,
  weightLoss,
  muscleGain,
  maintainWeight,
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  none
}

enum Goal { loseWeight, maintainWeight, gainMuscle }

enum DietPreference { none, vegetarian, vegan, keto, paleo }

extension GenderExtension on Gender {
  String toSimpleText() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.none:
        return 'Prefer not to say';
      default:
        return '';
    }
  }

  String toJson() => name;

  static Gender fromJson(String json) {
    return Gender.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Gender.none,
    );
  }

  static Gender fromSimpleText(String text) {
    switch (text) {
      case 'Male':
        return Gender.male;
      case 'Female':
        return Gender.female;
      case 'Other':
        return Gender.other;
      case 'Prefer not to say':
        return Gender.none;
      default:
        throw ArgumentError('Invalid gender text: $text');
    }
  }
}

extension WeeklyPaceExtension on WeeklyPace {
  String toSimpleText() {
    switch (this) {
      case WeeklyPace.slow:
        return 'Slow';
      case WeeklyPace.moderate:
        return 'Moderate';
      case WeeklyPace.fast:
        return 'Fast';
      case WeeklyPace.none:
        return 'None';
      default:
        return '';
    }
  }

  String toJson() => name;

  static WeeklyPace fromJson(String json) {
    return WeeklyPace.values.firstWhere(
      (e) => e.name == json,
      orElse: () => WeeklyPace.none,
    );
  }

  static WeeklyPace fromSimpleText(String text) {
    switch (text) {
      case 'Slow':
        return WeeklyPace.slow;
      case 'Moderate':
        return WeeklyPace.moderate;
      case 'Fast':
        return WeeklyPace.fast;
      case 'None':
        return WeeklyPace.none;
      default:
        throw ArgumentError('Invalid pace text: $text');
    }
  }
}

extension HealthModeExtension on HealthMode {
  String toSimpleText() {
    switch (this) {
      case HealthMode.weightLoss:
        return 'Weight Loss';
      case HealthMode.muscleGain:
        return 'Muscle Gain';
      case HealthMode.maintainWeight:
        return 'Maintain Weight';
      case HealthMode.none:
        return 'None';
      default:
        return '';
    }
  }

  String toJson() => name;

  static HealthMode fromJson(String json) {
    return HealthMode.values.firstWhere(
      (e) => e.name == json,
      orElse: () => HealthMode.none,
    );
  }

  static HealthMode fromSimpleText(String text) {
    switch (text) {
      case 'Weight Loss':
        return HealthMode.weightLoss;
      case 'Muscle Gain':
        return HealthMode.muscleGain;
      case 'Maintain Weight':
        return HealthMode.maintainWeight;
      case 'None':
        return HealthMode.none;
      default:
        throw ArgumentError('Invalid health mode text: $text');
    }
  }
}

extension ActivityLevelExtension on ActivityLevel {
  String toSimpleText() {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      default:
        return '';
    }
  }

  String toJson() => name;

  static ActivityLevel fromJson(String json) {
    return ActivityLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ActivityLevel.sedentary,
    );
  }

  static ActivityLevel fromSimpleText(String text) {
    switch (text) {
      case 'Sedentary':
        return ActivityLevel.sedentary;
      case 'Lightly Active':
        return ActivityLevel.lightlyActive;
      case 'Moderately Active':
        return ActivityLevel.moderatelyActive;
      case 'Very Active':
        return ActivityLevel.veryActive;
      default:
        throw ArgumentError('Invalid activity level text: $text');
    }
  }
}

extension GoalExtension on Goal {
  String toSimpleText() {
    switch (this) {
      case Goal.loseWeight:
        return 'Lose Weight';
      case Goal.maintainWeight:
        return 'Maintain Weight';
      case Goal.gainMuscle:
        return 'Gain Muscle';
      default:
        return '';
    }
  }

  String toJson() => name;

  static Goal fromJson(String json) {
    return Goal.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Goal.maintainWeight,
    );
  }

  static Goal fromSimpleText(String text) {
    switch (text) {
      case 'Lose Weight':
        return Goal.loseWeight;
      case 'Maintain Weight':
        return Goal.maintainWeight;
      case 'Gain Muscle':
        return Goal.gainMuscle;
      default:
        throw ArgumentError('Invalid goal text: $text');
    }
  }
}

extension DietPreferenceExtension on DietPreference {
  String toSimpleText() {
    switch (this) {
      case DietPreference.none:
        return 'No Preference';
      case DietPreference.vegetarian:
        return 'Vegetarian';
      case DietPreference.vegan:
        return 'Vegan';
      case DietPreference.keto:
        return 'Keto';
      case DietPreference.paleo:
        return 'Paleo';
      default:
        return '';
    }
  }

  String toJson() => name;

  static DietPreference fromJson(String json) {
    return DietPreference.values.firstWhere(
      (e) => e.name == json,
      orElse: () => DietPreference.none,
    );
  }

  static DietPreference fromSimpleText(String text) {
    switch (text) {
      case 'No Preference':
        return DietPreference.none;
      case 'Vegetarian':
        return DietPreference.vegetarian;
      case 'Vegan':
        return DietPreference.vegan;
      case 'Keto':
        return DietPreference.keto;
      case 'Paleo':
        return DietPreference.paleo;
      default:
        throw ArgumentError('Invalid diet preference text: $text');
    }
  }
}

class UserModel extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserBasicInfo? userInfo;

  const UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.userInfo,
  });

  Map<String, dynamic> toEntity() {
    return {
      "user_id": userId,
      "email": email,
      "name": name,
      "photo_url": photoUrl,
      "phone_number": phoneNumber,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "user_info": userInfo?.toMap(),
    };
  }

  static UserModel fromEntity(Map<String, dynamic> entity) {
    return UserModel(
      userId: entity["user_id"] ?? '',
      email: entity["email"] ?? '',
      name: entity["name"] ?? '',
      photoUrl: entity["photo_url"],
      phoneNumber: entity["phone_number"],
      createdAt:
          DateTime.tryParse(entity["created_at"] ?? "") ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(entity["updated_at"] ?? "") ?? DateTime.now(),
      userInfo: entity["user_info"] != null
          ? UserBasicInfo.fromMap(entity["user_info"])
          : null,
    );
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserBasicInfo? userInfo,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  UserModel.empty()
      : this(
          userId: '',
          email: '',
          name: '',
          photoUrl: '',
          phoneNumber: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

  @override
  List<Object?> get props => [
        userId,
        email,
        name,
        photoUrl,
        phoneNumber,
        createdAt,
        updatedAt,
        userInfo,
      ];
}

class UserBasicInfo {
  final Gender selectedGender;
  final int age;
  final WeeklyPace selectedPace;
  final DateTime birthDate;
  final double? currentHeight;
  final double? currentWeight;
  final double? desiredWeight;
  final String selectedHaveYouTriedApps;
  final String selectedWorkoutOption;
  final HealthMode selectedGoal;
  final String selectedObstacle;
  final String selectedDietKnowledge;
  final List<String> selectedMeals;
  final String selectedBodySatisfaction;
  final String selectedDiet;
  final String selectedMealTiming;
  final TimeOfDay? firstMealOfDay;
  final TimeOfDay? secondMealOfDay;
  final TimeOfDay? thirdMealOfDay;
  final String selectedMacronutrientKnowledge;
  final List<String> selectedAllergies;
  final String selectedEatOut;
  final String selectedHomeCooked;
  final ActivityLevel selectedActivityLevel;
  final String selectedSleepPattern;
  final UserMacros userMacros;

  UserBasicInfo({
    required this.selectedGender,
    required this.birthDate,
    required this.currentHeight,
    required this.currentWeight,
    required this.desiredWeight,
    required this.selectedHaveYouTriedApps,
    required this.selectedWorkoutOption,
    required this.selectedGoal,
    required this.selectedPace,
    required this.selectedObstacle,
    required this.selectedDietKnowledge,
    required this.selectedMeals,
    required this.selectedBodySatisfaction,
    required this.selectedDiet,
    required this.selectedMealTiming,
    required this.firstMealOfDay,
    required this.secondMealOfDay,
    required this.thirdMealOfDay,
    required this.selectedMacronutrientKnowledge,
    required this.selectedAllergies,
    required this.selectedEatOut,
    required this.selectedHomeCooked,
    required this.selectedActivityLevel,
    required this.selectedSleepPattern,
    required this.userMacros,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'gender': selectedGender.toJson(),
      'birth_date': birthDate.toIso8601String(),
      'height': currentHeight,
      'weight': currentWeight,
      'target_weight': desiredWeight,
      'previous_apps_experience': selectedHaveYouTriedApps,
      'workout_preference': selectedWorkoutOption,
      'health_goal': selectedGoal.toJson(),
      'weekly_pace': selectedPace.toJson(),
      'main_obstacle': selectedObstacle,
      'diet_knowledge_level': selectedDietKnowledge,
      'preferred_meals': selectedMeals,
      'body_satisfaction': selectedBodySatisfaction,
      'diet_type': selectedDiet,
      'meal_timing_preference': selectedMealTiming,
      'first_meal_time': _timeOfDayToString(firstMealOfDay),
      'second_meal_time': _timeOfDayToString(secondMealOfDay),
      'third_meal_time': _timeOfDayToString(thirdMealOfDay),
      'macro_knowledge_level': selectedMacronutrientKnowledge,
      'allergies': selectedAllergies,
      'eating_out_frequency': selectedEatOut,
      'home_cooking_frequency': selectedHomeCooked,
      'activity_level': selectedActivityLevel.toJson(),
      'sleep_pattern': selectedSleepPattern,
      'macros': userMacros.toMap(),
      'age': age,
    };
  }

  static UserBasicInfo fromMap(Map<String, dynamic> map) {
    return UserBasicInfo(
      selectedGender: map['gender'] != null
          ? GenderExtension.fromJson(map['gender'])
          : GenderExtension.fromSimpleText(
              map['selectedGender'] ?? 'Prefer not to say'),
      birthDate: DateTime.parse(map['birth_date'] ?? map['birthDate']),
      currentHeight: map['height'] ?? map['currentHeight'],
      currentWeight: map['weight'] ?? map['currentWeight'],
      desiredWeight: map['target_weight'] ?? map['desiredWeight'],
      selectedHaveYouTriedApps:
          map['previous_apps_experience'] ?? map['selectedHaveYouTriedApps'],
      selectedWorkoutOption:
          map['workout_preference'] ?? map['selectedWorkoutOption'],
      selectedGoal: map['health_goal'] != null
          ? HealthModeExtension.fromJson(map['health_goal'])
          : HealthMode.values.firstWhere((e) => e.name == map['selectedGoal'],
              orElse: () => HealthMode.none),
      selectedPace: map['weekly_pace'] != null
          ? WeeklyPaceExtension.fromJson(map['weekly_pace'])
          : WeeklyPace.values.firstWhere((e) => e.name == map['selectedPace'],
              orElse: () => WeeklyPace.none),
      selectedObstacle: map['main_obstacle'] ?? map['selectedObstacle'],
      selectedDietKnowledge:
          map['diet_knowledge_level'] ?? map['selectedDietKnowledge'],
      selectedMeals: List<String>.from(
          map['preferred_meals'] ?? map['selectedMeals'] ?? []),
      selectedBodySatisfaction:
          map['body_satisfaction'] ?? map['selectedBodySatisfaction'],
      selectedDiet: map['diet_type'] ?? map['selectedDiet'],
      selectedMealTiming:
          map['meal_timing_preference'] ?? map['selectedMealTiming'],
      firstMealOfDay:
          _timeOfDayFromString(map['first_meal_time'] ?? map['firstMealOfDay']),
      secondMealOfDay: _timeOfDayFromString(
          map['second_meal_time'] ?? map['secondMealOfDay']),
      thirdMealOfDay:
          _timeOfDayFromString(map['third_meal_time'] ?? map['thirdMealOfDay']),
      selectedMacronutrientKnowledge:
          map['macro_knowledge_level'] ?? map['selectedMacronutrientKnowledge'],
      selectedAllergies: map['allergies'] != null
          ? (map['allergies'] is List
              ? List<String>.from(map['allergies'])
              : [map['allergies'].toString()])
          : (map['selectedAllergy'] != null ? [map['selectedAllergy']] : []),
      selectedEatOut: map['eating_out_frequency'] ?? map['selectedEatOut'],
      selectedHomeCooked:
          map['home_cooking_frequency'] ?? map['selectedHomeCooked'],
      selectedActivityLevel: map['activity_level'] != null
          ? ActivityLevelExtension.fromJson(map['activity_level'])
          : ActivityLevel.values.firstWhere(
              (e) => e.name == (map['selectedActivityLevel'] ?? ''),
              orElse: () => ActivityLevel.sedentary),
      selectedSleepPattern: map['sleep_pattern'] ?? map['selectedSleepPattern'],
      userMacros: UserMacros.fromMap(map['macros'] ?? map['userMacros']),
      age: map['age'],
    );
  }

  static String _timeOfDayToString(TimeOfDay? time) {
    if (time == null) return '00:00';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay _timeOfDayFromString(String? timeString) {
    if (timeString == null) return const TimeOfDay(hour: 0, minute: 0);
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  UserBasicInfo copyWith({
    Gender? selectedGender,
    int? age,
    WeeklyPace? selectedPace,
    DateTime? birthDate,
    double? currentHeight,
    double? currentWeight,
    double? desiredWeight,
    String? selectedHaveYouTriedApps,
    String? selectedWorkoutOption,
    HealthMode? selectedGoal,
    String? selectedObstacle,
    String? selectedDietKnowledge,
    List<String>? selectedMeals,
    String? selectedBodySatisfaction,
    String? selectedDiet,
    String? selectedMealTiming,
    TimeOfDay? firstMealOfDay,
    TimeOfDay? secondMealOfDay,
    TimeOfDay? thirdMealOfDay,
    String? selectedMacronutrientKnowledge,
    List<String>? selectedAllergies,
    String? selectedEatOut,
    String? selectedHomeCooked,
    ActivityLevel? selectedActivityLevel,
    String? selectedSleepPattern,
    UserMacros? userMacros,
  }) {
    return UserBasicInfo(
      selectedGender: selectedGender ?? this.selectedGender,
      age: age ?? this.age,
      selectedPace: selectedPace ?? this.selectedPace,
      birthDate: birthDate ?? this.birthDate,
      currentHeight: currentHeight ?? this.currentHeight,
      currentWeight: currentWeight ?? this.currentWeight,
      desiredWeight: desiredWeight ?? this.desiredWeight,
      selectedHaveYouTriedApps:
          selectedHaveYouTriedApps ?? this.selectedHaveYouTriedApps,
      selectedWorkoutOption:
          selectedWorkoutOption ?? this.selectedWorkoutOption,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedObstacle: selectedObstacle ?? this.selectedObstacle,
      selectedDietKnowledge:
          selectedDietKnowledge ?? this.selectedDietKnowledge,
      selectedMeals: selectedMeals ?? this.selectedMeals,
      selectedBodySatisfaction:
          selectedBodySatisfaction ?? this.selectedBodySatisfaction,
      selectedDiet: selectedDiet ?? this.selectedDiet,
      selectedMealTiming: selectedMealTiming ?? this.selectedMealTiming,
      firstMealOfDay: firstMealOfDay ?? this.firstMealOfDay,
      secondMealOfDay: secondMealOfDay ?? this.secondMealOfDay,
      thirdMealOfDay: thirdMealOfDay ?? this.thirdMealOfDay,
      selectedMacronutrientKnowledge:
          selectedMacronutrientKnowledge ?? this.selectedMacronutrientKnowledge,
      selectedAllergies: selectedAllergies ?? this.selectedAllergies,
      selectedEatOut: selectedEatOut ?? this.selectedEatOut,
      selectedHomeCooked: selectedHomeCooked ?? this.selectedHomeCooked,
      selectedActivityLevel:
          selectedActivityLevel ?? this.selectedActivityLevel,
      selectedSleepPattern: selectedSleepPattern ?? this.selectedSleepPattern,
      userMacros: userMacros ?? this.userMacros,
    );
  }
}

class UserMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int water;
  final int fiber;

  UserMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.water = 0,
    this.fiber = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'daily_calories': calories,
      'daily_protein': protein,
      'daily_carbs': carbs,
      'daily_fat': fat,
      'daily_water': water,
      'daily_fiber': fiber,
    };
  }

  factory UserMacros.fromMap(Map<String, dynamic> map) {
    return UserMacros(
      calories: map['daily_calories'] ?? map['calories'] ?? 0,
      protein: map['daily_protein'] ?? map['protein'] ?? 0,
      carbs: map['daily_carbs'] ?? map['carbs'] ?? 0,
      fat: map['daily_fat'] ?? map['fat'] ?? 0,
      water: map['daily_water'] ?? map['water'] ?? 0,
      fiber: map['daily_fiber'] ?? map['fiber'] ?? 0,
    );
  }
}
