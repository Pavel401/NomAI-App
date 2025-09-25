class MonthlyAnalytics {
  final List<DailyAnalytics> dailyAnalytics;

  final String overAllMonthlySummary;

  final DateTime lastModified;

  MonthlyAnalytics({
    required this.dailyAnalytics,
    required this.lastModified,
    this.overAllMonthlySummary = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyAnalytics': dailyAnalytics.map((e) => e.toJson()).toList(),
      'lastModified': lastModified.toIso8601String(),
      'overAllMonthlySummary': overAllMonthlySummary,
    };
  }

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    final dynamic listAny = json['dailyAnalytics'];
    final daily = (listAny is List)
        ? listAny
            .whereType<Map>()
            .map((e) => DailyAnalytics.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <DailyAnalytics>[];

    final dynamic lm = json['lastModified'];
    DateTime lastMod;
    if (lm is String) {
      lastMod = DateTime.tryParse(lm) ?? DateTime.now();
    } else if (lm is DateTime) {
      lastMod = lm;
    } else {
      lastMod = DateTime.now();
    }

    final String summary = (json['overAllMonthlySummary'] as String?) ?? '';

    return MonthlyAnalytics(
      dailyAnalytics: daily,
      overAllMonthlySummary: summary,
      lastModified: lastMod,
    );
  }
}

class DailyAnalytics {
  final DateTime date;
  final int totalCalories;
  final int totalProtein;
  final int totalFat;
  final int totalCarbs;
  final int mealCount;

  final int totalCaloriesBurned;

  final int waterIntake;

  final String? overAllSummary;

  DailyAnalytics({
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalFat = 0,
    this.totalCarbs = 0,
    this.mealCount = 0,
    this.totalCaloriesBurned = 0,
    this.waterIntake = 0,
    this.overAllSummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
      'mealCount': mealCount,
      'totalCaloriesBurned': totalCaloriesBurned,
      'waterIntake': waterIntake,
      'overAllSummary': overAllSummary,
    };
  }

  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    final dynamic d = json['date'];
    DateTime parsedDate;
    if (d is String) {
      parsedDate = DateTime.tryParse(d) ?? DateTime.now();
    } else if (d is DateTime) {
      parsedDate = d;
    } else {
      parsedDate = DateTime.now();
    }

    int _asInt(dynamic v) => v is num ? v.toInt() : (int.tryParse('$v') ?? 0);

    return DailyAnalytics(
      date: parsedDate,
      totalCalories: _asInt(json['totalCalories']),
      totalProtein: _asInt(json['totalProtein']),
      totalFat: _asInt(json['totalFat']),
      totalCarbs: _asInt(json['totalCarbs']),
      mealCount: _asInt(json['mealCount']),
      totalCaloriesBurned: _asInt(json['totalCaloriesBurned']),
      waterIntake: _asInt(json['waterIntake']),
      overAllSummary: json['overAllSummary'] as String?,
    );
  }
}
