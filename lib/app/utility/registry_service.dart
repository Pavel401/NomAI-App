import 'package:NomAi/app/repo/meal_ai_repo.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/repo/storage_service.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> setupRegistry() async {
  serviceLocator.registerLazySingleton<AiRepository>(() => AiRepository());

  serviceLocator
      .registerLazySingleton<NutritionRecordRepo>(() => NutritionRecordRepo());

  serviceLocator.registerLazySingleton<StorageService>(() => StorageService());
}
