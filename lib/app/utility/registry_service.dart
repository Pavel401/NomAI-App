import 'package:get_it/get_it.dart';
import 'package:turfit/app/repo/meal_ai_repo.dart';
import 'package:turfit/app/repo/nutrition_record_repo.dart';
import 'package:turfit/app/repo/storage_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupRegistry() async {
  serviceLocator.registerLazySingleton<AiRepository>(() => AiRepository());

  serviceLocator
      .registerLazySingleton<NutritionRecordRepo>(() => NutritionRecordRepo());

  serviceLocator.registerLazySingleton<StorageService>(() => StorageService());
}
