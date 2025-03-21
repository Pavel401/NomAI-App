part of 'user_nutrition_record_bloc.dart';

sealed class UserNutritionRecordEvent extends Equatable {
  const UserNutritionRecordEvent();

  @override
  List<Object> get props => [];
}

// 🚀 You will trigger this when scan starts
final class UserNutritionRecordInitialized extends UserNutritionRecordEvent {
  final String userId;
  final DateTime date;

  UserNutritionRecordInitialized(this.userId, this.date);

  @override
  List<Object> get props => [userId, date];
}

final class UserNutritionAdded extends UserNutritionRecordEvent {
  final String userId;
  final DailyNutritionRecords nutritionRecord;

  UserNutritionAdded(this.userId, this.nutritionRecord);

  @override
  List<Object> get props => [userId, nutritionRecord];
}
