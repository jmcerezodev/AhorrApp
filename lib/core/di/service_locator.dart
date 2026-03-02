import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/data/repositories/appwrite_recurrent_expense_repository.dart';
import 'package:ahorrapp/data/repositories/isar_recurrent_expense_repository.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';
import 'package:ahorrapp/domain/usecases/delete_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/update_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:get_it/get_it.dart';
import '../../data/appwrite/appwrite_repository.dart';
import '../../data/appwrite/auth_appwrite.dart';
import '../../data/local/local_db_service.dart';
import '../../data/repositories/appwrite_movement_repository.dart';
import '../../data/repositories/isar_movement_repository.dart';
import '../../domain/repositories/i_movement_repository.dart';
import '../../domain/usecases/get_movements_usecase.dart';
import '../../domain/usecases/save_movement_usecase.dart';
import '../auth/biometric_service.dart';
import '../sync/sync_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  
  // 1. DATA SOURCES & SERVICIOS BÁSICOS
  final localDbService = LocalDbService();
  await localDbService.init();
  getIt.registerSingleton<LocalDbService>(localDbService);

  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<AppwriteRepository>(() => AppwriteRepository());
  getIt.registerLazySingleton<AuthAppwrite>(() => AuthAppwrite());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<SyncService>(() => SyncService());

  // 2. REPOSITORIOS
  getIt.registerLazySingleton<IMovementRepository>(
    () => AppwriteMovementRepository(),
    instanceName: 'remote',
  );

  getIt.registerLazySingleton<IMovementRepository>(
    () => IsarMovementRepository(),
    instanceName: 'local',
  );

  getIt.registerLazySingleton<IRecurrentExpenseRepository>(
    () => AppwriteRecurrentExpenseRepository(),
    instanceName: 'recurrent_remote',
  );

  getIt.registerLazySingleton<IRecurrentExpenseRepository>(
    () => IsarRecurrentExpenseRepository(),
    instanceName: 'recurrent_local',
  );

  // 3. CASOS DE USO (Cimientos de los Cubits)
  getIt.registerLazySingleton<GetMovementsUseCase>(() => GetMovementsUseCase(
        localRepository: getIt<IMovementRepository>(instanceName: 'local'),
        remoteRepository: getIt<IMovementRepository>(instanceName: 'remote'),
      ));

  getIt.registerLazySingleton<SaveMovementUseCase>(() => SaveMovementUseCase(
        localRepository: getIt<IMovementRepository>(instanceName: 'local'),
        remoteRepository: getIt<IMovementRepository>(instanceName: 'remote'),
        localDbService: getIt<LocalDbService>(),
        totalMoneyCubit: getIt<TotalMoneyCubit>(), 
      ));

  getIt.registerLazySingleton<DeleteMovementUseCase>(() => DeleteMovementUseCase(
        localRepository: getIt<IMovementRepository>(instanceName: 'local'),
        remoteRepository: getIt<IMovementRepository>(instanceName: 'remote'),
        localDbService: getIt<LocalDbService>(),
        totalMoneyCubit: getIt<TotalMoneyCubit>(),
      ));

  getIt.registerLazySingleton<UpdateMovementUseCase>(() => UpdateMovementUseCase(
        localRepository: getIt<IMovementRepository>(instanceName: 'local'),
        localDbService: getIt<LocalDbService>(),
        totalMoneyCubit: getIt<TotalMoneyCubit>(),
        remoteDataSource: getIt<AppwriteRepository>(),
      ));

  // CASOS DE USO RECURRENTES
  getIt.registerLazySingleton<GetRecurrentExpensesUseCase>(() => GetRecurrentExpensesUseCase(
        localRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_local'),
      ));

  getIt.registerLazySingleton<SaveRecurrentExpenseUseCase>(() => SaveRecurrentExpenseUseCase(
        localRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_local'),
        remoteRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_remote'),
        localDbService: getIt<LocalDbService>(),
      ));

  getIt.registerLazySingleton<DeleteRecurrentExpenseUseCase>(() => DeleteRecurrentExpenseUseCase(
        localRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_local'),
        remoteRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_remote'),
        localDbService: getIt<LocalDbService>(),
      ));

  // 4. CUBITS CORE (Permanentes)
  final totalMoneyCubit = TotalMoneyCubit();
  getIt.registerSingleton<TotalMoneyCubit>(totalMoneyCubit);
  getIt.registerSingleton<DateCubit>(DateCubit());
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
  
  getIt.registerSingleton<HistoryCubit>(HistoryCubit(totalMoneyCubit: totalMoneyCubit));
  getIt.registerSingleton<SavingsCubit>(SavingsCubit());
  getIt.registerSingleton<LoginCubit>(LoginCubit(historyCubit: getIt<HistoryCubit>()));
  getIt.registerSingleton<UpdateNameCubit>(UpdateNameCubit());
  getIt.registerSingleton<RecurrentExpensesCubit>(RecurrentExpensesCubit());
  
  // 5. CUBITS DE FÁBRICA (Se crean bajo demanda)
  getIt.registerFactory<NewUserCubit>(() => NewUserCubit());
  getIt.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit());
  getIt.registerFactory<UpdatePasswordCubit>(() => UpdatePasswordCubit());
  getIt.registerFactory<DeleteAcountCubit>(() => DeleteAcountCubit());
  getIt.registerFactory<IncomesCubit>(() => IncomesCubit());
  getIt.registerFactory<ExpensesCubit>(() => ExpensesCubit());
}
