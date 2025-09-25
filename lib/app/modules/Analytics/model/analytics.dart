class MonthlyAnalytics {
  List<DailyAnalytics> dailyAnalytics;

  DateTime lastModified;

  MonthlyAnalytics({
    required this.dailyAnalytics,
    required this.lastModified,
  });

  toJson() {
    return {
      'dailyAnalytics': dailyAnalytics.map((e) => e.toJson()).toList(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalytics(
      dailyAnalytics: (json['dailyAnalytics'] as List)
          .map((e) => DailyAnalytics.fromJson(e))
          .toList(),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }
}

class DailyAnalytics {
  DateTime date;
  int totalCalories;
  int totalProtein;
  int totalFat;
  int totalCarbs;
  int mealCount;

  int totalCaloriesBurned;

  int waterIntake;

  DailyAnalytics({
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalFat = 0,
    this.totalCarbs = 0,
    this.mealCount = 0,
    this.totalCaloriesBurned = 0,
    this.waterIntake = 0,
  });

  toJson() {
    return {
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
      'mealCount': mealCount,
      'totalCaloriesBurned': totalCaloriesBurned,
      'waterIntake': waterIntake,
    };
  }

  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    return DailyAnalytics(
      date: DateTime.parse(json['date']),
      totalCalories: json['totalCalories'] ?? 0,
      totalProtein: json['totalProtein'] ?? 0,
      totalFat: json['totalFat'] ?? 0,
      totalCarbs: json['totalCarbs'] ?? 0,
      mealCount: json['mealCount'] ?? 0,
      totalCaloriesBurned: json['totalCaloriesBurned'] ?? 0,
      waterIntake: json['waterIntake'] ?? 0,
    );
  }
}
