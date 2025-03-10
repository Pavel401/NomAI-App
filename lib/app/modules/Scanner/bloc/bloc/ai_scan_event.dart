part of 'ai_scan_bloc.dart';

sealed class AiScanEvent extends Equatable {
  const AiScanEvent();

  @override
  List<Object> get props => [];
}

// 🚀 You will trigger this when scan starts
final class AiScanStarted extends AiScanEvent {
  final NutritionInputQuery nutritionInputQuery;

  AiScanStarted(this.nutritionInputQuery);

  @override
  List<Object> get props => [nutritionInputQuery];
}
