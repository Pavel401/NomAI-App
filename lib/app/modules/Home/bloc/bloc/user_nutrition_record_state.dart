part of 'user_nutrition_record_bloc.dart';

sealed class UserNutritionRecordState extends Equatable {
  const UserNutritionRecordState();

  @override
  List<Object> get props => [];
}

final class UserNutritionRecordInitial extends UserNutritionRecordState {}

final class UserNutritionRecordLoading extends UserNutritionRecordState {}

final class UserNutritionRecordSuccess extends UserNutritionRecordState {
  final DailyNutritionRecords nutritionRecords;

  UserNutritionRecordSuccess(this.nutritionRecords);

  @override
  List<Object> get props => [nutritionRecords];
}

final class UserNutritionRecordFailure extends UserNutritionRecordState {
  final String message;

  UserNutritionRecordFailure(this.message);

  @override
  List<Object> get props => [message];
}
