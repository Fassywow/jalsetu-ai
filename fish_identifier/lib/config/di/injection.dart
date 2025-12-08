import 'package:get_it/get_it.dart';
import '../../features/detection/data/datasources/tflite_detection_service.dart';
import '../../features/detection/data/datasources/freshness_service.dart';
import '../../features/detection/data/datasources/bengali_fish_classifier_service.dart';
import '../../features/detection/data/repositories/detection_repository_impl.dart';
import '../../features/detection/domain/repositories/detection_repository.dart';
import '../../features/detection/domain/usecases/detect_objects.dart';
import '../../features/detection/presentation/bloc/detection_bloc.dart';
import '../../features/auth/data/datasources/api_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/session/data/repositories/session_repository_impl.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../core/services/image_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/sync_service.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupDependencyInjection() async {
  // Services (Singletons)
  getIt.registerLazySingleton<TFLiteDetectionService>(
    () => TFLiteDetectionService(),
  );
  getIt.registerLazySingleton<BengaliFishClassifierService>(
    () => BengaliFishClassifierService(),
  );
  getIt.registerLazySingleton<FreshnessService>(
    () => FreshnessService(),
  );
  getIt.registerLazySingleton<ImageService>(
    () => ImageService(),
  );
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );
  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      localStorage: getIt<LocalStorageService>(),
      imageService: getIt<ImageService>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<DetectionRepository>(
    () => DetectionRepositoryImpl(
      detectionService: getIt<TFLiteDetectionService>(),
      bengaliClassifier: getIt<BengaliFishClassifierService>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<DetectObjects>(
    () => DetectObjects(getIt<DetectionRepository>()),
  );

  // BLoCs (Factories - new instance each time)
  getIt.registerFactory<DetectionBloc>(
    () => DetectionBloc(
      repository: getIt<DetectionRepository>(),
      detectObjectsUseCase: getIt<DetectObjects>(),
      freshnessService: getIt<FreshnessService>(),
    ),
  );
  // Auth Dependencies
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(repository: getIt<AuthRepository>()),
  );

  // Session Repository
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(),
  );
}
