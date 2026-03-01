import 'package:get_it/get_it.dart';
import '../../data/appwrite/appwrite_repository.dart';
import '../../data/appwrite/auth_appwrite.dart';
import '../../data/local/local_db_service.dart';
import '../../data/repositories/appwrite_movement_repository.dart';
import '../../data/repositories/isar_movement_repository.dart';
import '../../domain/repositories/i_movement_repository.dart';
import '../../domain/usecases/get_movements_usecase.dart';
import '../../domain/usecases/save_movement_usecase.dart';
import '../../presentation/bloc/total_money_cubit/total_money_cubit.dart';
import '../auth/biometric_service.dart';
import '../sync/sync_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- Cubits Globales ---
  getIt.registerSingleton<TotalMoneyCubit>(TotalMoneyCubit());

  // --- Data Sources & Services ---
  final localDbService = LocalDbService();
  await localDbService.init();
  getIt.registerSingleton<LocalDbService>(localDbService);

  getIt.registerLazySingleton<AppwriteRepository>(() => AppwriteRepository());
  getIt.registerLazySingleton<AuthAppwrite>(() => AuthAppwrite());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<SyncService>(() => SyncService());

  // --- Repositories ---
  getIt.registerLazySingleton<IMovementRepository>(
    () => AppwriteMovementRepository(),
    instanceName: 'remote',
  );

  getIt.registerLazySingleton<IMovementRepository>(
    () => IsarMovementRepository(),
    instanceName: 'local',
  );

  // --- Use Cases ---
  getIt.registerLazySingleton<GetMovementsUseCase>(() => GetMovementsUseCase(
        localRepository: getIt<IMovementRepository>(instanceName: 'local'),
        remoteRepository: getIt<IMovementRepository>(instanceName: 'remote'),
      ));

  getIt.registerLazySingleton<SaveMovementUseCase>(() => SaveMovementUseCase(
        localRepository: getIt<IMovementRepository>(instanceName: 'local'),
        remoteRepository: getIt<IMovementRepository>(instanceName: 'remote'),
        localDbService: getIt<LocalDbService>(),
        totalMoneyCubit: getIt<TotalMoneyCubit>(), // Inyectamos el cubit de balance
      ));
}
