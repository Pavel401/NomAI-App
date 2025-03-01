import 'package:equatable/equatable.dart';

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
}

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

enum Goal { loseWeight, maintainWeight, gainMuscle }

enum DietPreference { none, vegetarian, vegan, keto, paleo }

class MyUser extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final double? weight;
  final double? height;
  final int? age;
  final Gender? gender;
  final ActivityLevel? activityLevel;
  final Goal? goal;
  final DietPreference? dietPreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MyUser({
    required this.userId,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.activityLevel,
    this.goal,
    this.dietPreference,
    required this.createdAt,
    required this.updatedAt,
  });

  /// **Convert User to Firestore Entity**
  Map<String, dynamic> toEntity() {
    return {
      "userId": userId,
      "email": email,
      "name": name,
      "photoUrl": photoUrl,
      "phoneNumber": phoneNumber,
      "weight": weight,
      "height": height,
      "age": age,
      "gender": gender?.name,
      "activityLevel": activityLevel?.name,
      "goal": goal?.name,
      "dietPreference": dietPreference?.name,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  /// **Create User from Firestore Entity**
  static MyUser fromEntity(Map<String, dynamic> entity) {
    return MyUser(
      userId: entity["userId"] ?? '',
      email: entity["email"] ?? '',
      name: entity["name"] ?? '',
      photoUrl: entity["photoUrl"],
      phoneNumber: entity["phoneNumber"],
      weight: (entity["weight"] as num?)?.toDouble(),
      height: (entity["height"] as num?)?.toDouble(),
      age: entity["age"] as int?,
      gender: entity["gender"] != null
          ? Gender.values.byName(entity["gender"])
          : null,
      activityLevel: entity["activityLevel"] != null
          ? ActivityLevel.values.byName(entity["activityLevel"])
          : null,
      goal: entity["goal"] != null ? Goal.values.byName(entity["goal"]) : null,
      dietPreference: entity["dietPreference"] != null
          ? DietPreference.values.byName(entity["dietPreference"])
          : null,
      createdAt: DateTime.tryParse(entity["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(entity["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }

  MyUser copyWith({
    String? userId,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    double? weight,
    double? height,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
    DietPreference? dietPreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dietPreference: dietPreference ?? this.dietPreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  MyUser.empty()
      : this(
          userId: '',
          email: '',
          name: '',
          photoUrl: '',
          phoneNumber: '',
          weight: 0.0,
          height: 0.0,
          age: 0,
          gender: null,
          activityLevel: null,
          goal: null,
          dietPreference: null,
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
        weight,
        height,
        age,
        gender,
        activityLevel,
        goal,
        dietPreference,
        createdAt,
        updatedAt,
      ];
}
