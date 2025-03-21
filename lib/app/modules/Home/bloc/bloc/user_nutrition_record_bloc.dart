import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/repo/nutrition_firebase_repo.dart';
import 'package:turfit/app/utility/service_locator.dart';

part 'user_nutrition_record_event.dart';
part 'user_nutrition_record_state.dart';

class UserNutritionRecordBloc
    extends Bloc<UserNutritionRecordEvent, UserNutritionRecordState> {
  final nutritionRepo = getIt<NutritionFirebaseRepo>();

  UserNutritionRecordBloc() : super(UserNutritionRecordInitial()) {
    on<UserNutritionRecordInitialized>((event, emit) async {
      await _onUserNutritionRecordInitialized(event, emit);
    });
    on<UserNutritionAdded>((event, emit) async {
      // emit(UserNutritionRecordLoading());

      try {
        await nutritionRepo.saveDailyNutritionRecords(
            event.userId, event.nutritionRecord);

        // Emit success state after saving data
        emit(UserNutritionRecordSuccess(event.nutritionRecord));
      } catch (e) {
        emit(UserNutritionRecordFailure("Failed to save data"));
      }
    });
  }

  Future<void> _onUserNutritionRecordInitialized(
      UserNutritionRecordInitialized event,
      Emitter<UserNutritionRecordState> emit) async {
    emit(UserNutritionRecordLoading());

    try {
      // ✅ Make API Call
      final DailyNutritionRecords nutritionRecords =
          await nutritionRepo.getDailyNutritionRecords(
        event.userId,
        event.date,
      );

      // ✅ Emit Success State
      emit(UserNutritionRecordSuccess(nutritionRecords));
    } catch (e) {
      // ✅ Emit Failure State
      emit(UserNutritionRecordFailure("Failed to fetch data"));
    }
  }
}
