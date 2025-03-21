part of 'ai_scan_bloc.dart';

sealed class AiScanState extends Equatable {
  const AiScanState();

  @override
  List<Object> get props => [];
}

// Initial State
final class AiScanInitial extends AiScanState {}

// ✅ Loading State (Like isLoading.value = true)
final class AiScanLoading extends AiScanState {}

// ✅ Success State (Like controller.data.value)
final class AiScanSuccess extends AiScanState {
  final NutritionOutput nutritionOutput;
  final NutritionInputQuery nutritionInputQuery;
  AiScanSuccess(this.nutritionOutput, this.nutritionInputQuery);

  @override
  List<Object> get props => [nutritionOutput, nutritionInputQuery];
}

// ✅ Failure State (Like controller.error.value)
final class AiScanFailure extends AiScanState {
  final String message;
  AiScanFailure(this.message);

  @override
  List<Object> get props => [message];
}
