import 'package:get_it/get_it.dart';
import 'package:turfit/app/repo/nutrition_firebase_repo.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<NutritionFirebaseRepo>(
      () => NutritionFirebaseRepo());
}
