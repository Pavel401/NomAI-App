import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:turfit/app/models/AI/nutrition_input.dart';
import 'package:turfit/app/models/AI/nutrition_output.dart';
import 'package:turfit/app/repo/meal_ai_repo.dart';

part 'ai_scan_event.dart';
part 'ai_scan_state.dart';

class AiScanBloc extends Bloc<AiScanEvent, AiScanState> {
  final AiRepository aiRepository;

  AiScanBloc(this.aiRepository) : super(AiScanInitial()) {
    on<AiScanStarted>(_onAiScanStarted);
  }

  // This will get called when you do: bloc.add(AiScanStarted())
  Future<void> _onAiScanStarted(
      AiScanStarted event, Emitter<AiScanState> emit) async {
    emit(AiScanLoading());

    try {
      // ✅ Make API Call
      final NutritionOutput nutritionOutput =
          await aiRepository.getNutritionData(event.nutritionInputQuery);

      // ✅ Emit Success State
      emit(AiScanSuccess(nutritionOutput, event.nutritionInputQuery));
    } catch (e) {
      // ✅ Emit Failure State
      emit(AiScanFailure("Failed to fetch data"));
    }
  }
}
