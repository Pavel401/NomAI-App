import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Gender { male, female, other, none }

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

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

enum Goal { loseWeight, maintainWeight, gainMuscle }

enum DietPreference { none, vegetarian, vegan, keto, paleo }

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

  /// **Convert User to Firestore Entity**
  Map<String, dynamic> toEntity() {
    return {
      "userId": userId,
      "email": email,
      "name": name,
      "photoUrl": photoUrl,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "userInfo": userInfo?.toMap(),
    };
  }

  /// **Create User from Firestore Entity**
  static UserModel fromEntity(Map<String, dynamic> entity) {
    return UserModel(
      userId: entity["userId"] ?? '',
      email: entity["email"] ?? '',
      name: entity["name"] ?? '',
      photoUrl: entity["photoUrl"],
      phoneNumber: entity["phoneNumber"],
      createdAt: DateTime.tryParse(entity["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(entity["updatedAt"] ?? "") ?? DateTime.now(),
      userInfo: entity["userInfo"] != null
          ? UserBasicInfo.fromMap(entity["userInfo"])
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
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      ];
}

class UserBasicInfo {
  final Gender selectedGender;
  final DateTime selectedDate;
  final String? currentHeight;
  final String? currentWeight;
  final String? desiredWeight;
  final String selectedHaveYouTriedApps;
  final String selectedWorkoutOption;
  final String selectedGoal;
  final String selectedPace;
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
  final String selectedAllergy;
  final String selectedEatOut;
  final String selectedHomeCooked;
  final String selectedActivityLevel;
  final String selectedSleepPattern;

  UserBasicInfo({
    required this.selectedGender,
    required this.selectedDate,
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
    required this.selectedAllergy,
    required this.selectedEatOut,
    required this.selectedHomeCooked,
    required this.selectedActivityLevel,
    required this.selectedSleepPattern,
  });

  /// Convert UserInfo to a Map for easy storage or transmission
  Map<String, dynamic> toMap() {
    return {
      'selectedGender': selectedGender.toSimpleText(),
      'selectedDate': selectedDate.toIso8601String(),
      'currentHeight': currentHeight,
      'currentWeight': currentWeight,
      'desiredWeight': desiredWeight,
      'selectedHaveYouTriedApps': selectedHaveYouTriedApps,
      'selectedWorkoutOption': selectedWorkoutOption,
      'selectedGoal': selectedGoal,
      'selectedPace': selectedPace,
      'selectedObstacle': selectedObstacle,
      'selectedDietKnowledge': selectedDietKnowledge,
      'selectedMeals': selectedMeals,
      'selectedBodySatisfaction': selectedBodySatisfaction,
      'selectedDiet': selectedDiet,
      'selectedMealTiming': selectedMealTiming,
      'firstMealOfDay': _timeOfDayToString(firstMealOfDay!),
      'secondMealOfDay': _timeOfDayToString(secondMealOfDay!),
      'thirdMealOfDay': _timeOfDayToString(thirdMealOfDay!),
      'selectedMacronutrientKnowledge': selectedMacronutrientKnowledge,
      'selectedAllergy': selectedAllergy,
      'selectedEatOut': selectedEatOut,
      'selectedHomeCooked': selectedHomeCooked,
      'selectedActivityLevel': selectedActivityLevel,
      'selectedSleepPattern': selectedSleepPattern,
    };
  }

  /// Create UserInfo from a Map
  static UserBasicInfo fromMap(Map<String, dynamic> map) {
    return UserBasicInfo(
      selectedGender: GenderExtension.fromSimpleText(map['selectedGender']),
      selectedDate: DateTime.parse(map['selectedDate']),
      currentHeight: map['currentHeight'],
      currentWeight: map['currentWeight'],
      desiredWeight: map['desiredWeight'],
      selectedHaveYouTriedApps: map['selectedHaveYouTriedApps'],
      selectedWorkoutOption: map['selectedWorkoutOption'],
      selectedGoal: map['selectedGoal'],
      selectedPace: map['selectedPace'],
      selectedObstacle: map['selectedObstacle'],
      selectedDietKnowledge: map['selectedDietKnowledge'],
      selectedMeals: List<String>.from(map['selectedMeals']),
      selectedBodySatisfaction: map['selectedBodySatisfaction'],
      selectedDiet: map['selectedDiet'],
      selectedMealTiming: map['selectedMealTiming'],
      firstMealOfDay: _timeOfDayFromString(map['firstMealOfDay'] ?? '00:00'),
      secondMealOfDay: _timeOfDayFromString(map['secondMealOfDay'] ?? '00:00'),
      thirdMealOfDay: _timeOfDayFromString(map['thirdMealOfDay'] ?? '00:00'),
      selectedMacronutrientKnowledge: map['selectedMacronutrientKnowledge'],
      selectedAllergy: map['selectedAllergy'],
      selectedEatOut: map['selectedEatOut'],
      selectedHomeCooked: map['selectedHomeCooked'],
      selectedActivityLevel: map['selectedActivityLevel'],
      selectedSleepPattern: map['selectedSleepPattern'],
    );
  }

  static String _timeOfDayToString(TimeOfDay time) {
    return time.hour.toString().padLeft(2, '0') +
        ':' +
        time.minute.toString().padLeft(2, '0');
  }

  static TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
