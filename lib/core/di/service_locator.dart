import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/data/datasources/local/tickets_local_datasource.dart';
import 'package:ahorrapp/data/repositories/appwrite_recurrent_expense_repository.dart';
import 'package:ahorrapp/data/repositories/appwrite_shopping_list_repository.dart';
import 'package:ahorrapp/data/repositories/appwrite_shopping_template_repository.dart';
import 'package:ahorrapp/data/repositories/isar_debt_loan_repository.dart';
import 'package:ahorrapp/data/repositories/isar_recurrent_expense_repository.dart';
import 'package:ahorrapp/data/repositories/isar_shopping_list_repository.dart';
import 'package:ahorrapp/data/repositories/isar_shopping_template_repository.dart';
import 'package:ahorrapp/data/repositories/ticket_repository_impl.dart';
import 'package:ahorrapp/data/services/google_mlkit_ocr_service.dart';
import 'package:ahorrapp/data/services/google_mlkit_document_scanner_service.dart';
import 'package:ahorrapp/data/services/openai_service.dart';
import 'package:ahorrapp/data/services/ticket_export_service_impl.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';
import 'package:ahorrapp/domain/repositories/i_shopping_list_repository.dart';
import 'package:ahorrapp/domain/repositories/i_shopping_template_repository.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/domain/services/ocr_service.dart';
import 'package:ahorrapp/domain/services/document_scanner_service.dart';
import 'package:ahorrapp/domain/services/ai_service.dart';
import 'package:ahorrapp/domain/services/ticket_export_service.dart';
import 'package:ahorrapp/domain/usecases/delete_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/add_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/delete_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/get_debts_loans_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/update_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/process_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_list_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_template_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_list_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_templates_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_list_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_template_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/delete_ticket_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/get_ticket_items_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/process_ticket_image_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/reorder_ticket_items_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/save_ticket_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/update_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
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

  // Servicios IA y OCR
  getIt.registerLazySingleton<AIService>(() => OpenAIService());
  getIt.registerLazySingleton<OCRService>(() => GoogleMlKitOCRService(getIt<AIService>()));
  getIt.registerLazySingleton<DocumentScannerService>(() => GoogleMlKitDocumentScannerService());
  getIt.registerLazySingleton<TicketExportService>(() => TicketExportServiceImpl());

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

  getIt.registerLazySingleton<IShoppingRepository>(
    () => IsarShoppingListRepository(),
    instanceName: 'shopping_local',
  );

  getIt.registerLazySingleton<IShoppingRepository>(
    () => AppwriteShoppingListRepository(),
    instanceName: 'shopping_remote',
  );

  getIt.registerLazySingleton<IShoppingTemplateRepository>(
    () => IsarShoppingTemplateRepository(),
    instanceName: 'template_local',
  );

  getIt.registerLazySingleton<IShoppingTemplateRepository>(
    () => AppwriteShoppingTemplateRepository(),
    instanceName: 'template_remote',
  );

  getIt.registerLazySingleton<DebtLoanRepository>(
    () => IsarDebtLoanRepository(getIt<LocalDbService>()),
    instanceName: 'debt_local',
  );

  // REPOSITORIO DE TICKETS
  getIt.registerLazySingleton<TicketsLocalDataSource>(() => TicketsLocalDataSource(getIt<LocalDbService>().isar));
  getIt.registerLazySingleton<TicketsRepository>(() => TicketsRepositoryImpl(getIt<TicketsLocalDataSource>()));

  // 3. CASOS DE USO
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
        ticketsRepository: getIt<TicketsRepository>(),
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

  getIt.registerLazySingleton<ProcessRecurrentExpensesUseCase>(() => ProcessRecurrentExpensesUseCase(
        localRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_local'),
        remoteRepository: getIt<IRecurrentExpenseRepository>(instanceName: 'recurrent_remote'),
        saveMovementUseCase: getIt<SaveMovementUseCase>(),
      ));

  // CASOS DE USO LISTA DE LA COMPRA
  getIt.registerLazySingleton<GetShoppingListUseCase>(() => GetShoppingListUseCase(
        localRepository: getIt<IShoppingRepository>(instanceName: 'shopping_local'),
      ));

  getIt.registerLazySingleton<SaveShoppingListItemUseCase>(() => SaveShoppingListItemUseCase(
        localRepository: getIt<IShoppingRepository>(instanceName: 'shopping_local'),
        remoteRepository: getIt<IShoppingRepository>(instanceName: 'shopping_remote'),
        localDbService: getIt<LocalDbService>(),
      ));

  getIt.registerLazySingleton<DeleteShoppingListItemUseCase>(() => DeleteShoppingListItemUseCase(
        localRepository: getIt<IShoppingRepository>(instanceName: 'shopping_local'),
        remoteRepository: getIt<IShoppingRepository>(instanceName: 'shopping_remote'),
        localDbService: getIt<LocalDbService>(),
      ));

  // CASOS DE USO PLANTILLAS
  getIt.registerLazySingleton<GetShoppingTemplatesUseCase>(() => GetShoppingTemplatesUseCase(
        repository: getIt<IShoppingTemplateRepository>(instanceName: 'template_local'),
      ));

  getIt.registerLazySingleton<SaveShoppingTemplateUseCase>(() => SaveShoppingTemplateUseCase(
        localRepository: getIt<IShoppingTemplateRepository>(instanceName: 'template_local'),
        remoteRepository: getIt<IShoppingTemplateRepository>(instanceName: 'template_remote'),
        localDbService: getIt<LocalDbService>(),
      ));

  getIt.registerLazySingleton<DeleteShoppingTemplateUseCase>(() => DeleteShoppingTemplateUseCase(
        localRepository: getIt<IShoppingTemplateRepository>(instanceName: 'template_local'),
        remoteRepository: getIt<IShoppingTemplateRepository>(instanceName: 'template_remote'),
      ));

  // CASOS DE USO TICKETS
  getIt.registerLazySingleton<GetTicketItemsUseCase>(() => GetTicketItemsUseCase(getIt<TicketsRepository>()));
  getIt.registerLazySingleton<SaveTicketItemUseCase>(() => SaveTicketItemUseCase(getIt<TicketsRepository>()));
  getIt.registerLazySingleton<DeleteTicketItemUseCase>(() => DeleteTicketItemUseCase(
    ticketsRepository: getIt<TicketsRepository>(),
    movementRepository: getIt<IMovementRepository>(instanceName: 'local'),
  ));
  getIt.registerLazySingleton<ReorderTicketItemsUseCase>(() => ReorderTicketItemsUseCase(getIt<TicketsRepository>()));
  getIt.registerLazySingleton<TransferTicketsToExpensesUseCase>(() => TransferTicketsToExpensesUseCase(
    saveMovementUseCase: getIt<SaveMovementUseCase>(),
    ticketsRepository: getIt<TicketsRepository>(),
  ));
  getIt.registerLazySingleton<ProcessTicketImageUseCase>(() => ProcessTicketImageUseCase(getIt<OCRService>()));

  // CASOS DE USO DEUDAS Y PRÉSTAMOS
  getIt.registerLazySingleton<GetDebtsLoansUseCase>(() => GetDebtsLoansUseCase(getIt<DebtLoanRepository>(instanceName: 'debt_local')));
  getIt.registerLazySingleton<AddDebtLoanUseCase>(() => AddDebtLoanUseCase(getIt<DebtLoanRepository>(instanceName: 'debt_local')));
  getIt.registerLazySingleton<UpdateDebtLoanUseCase>(() => UpdateDebtLoanUseCase(getIt<DebtLoanRepository>(instanceName: 'debt_local')));
  getIt.registerLazySingleton<DeleteDebtLoanUseCase>(() => DeleteDebtLoanUseCase(getIt<DebtLoanRepository>(instanceName: 'debt_local')));

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
  getIt.registerSingleton<ShoppingListCubit>(ShoppingListCubit());
  getIt.registerSingleton<ShoppingTemplatesCubit>(ShoppingTemplatesCubit(
    getTemplatesUseCase: getIt<GetShoppingTemplatesUseCase>(),
    saveTemplateUseCase: getIt<SaveShoppingTemplateUseCase>(),
    deleteTemplateUseCase: getIt<DeleteShoppingTemplateUseCase>(),
  ));

  getIt.registerSingleton<TicketsCubit>(TicketsCubit(
    getTicketItemsUseCase: getIt<GetTicketItemsUseCase>(),
    saveTicketItemUseCase: getIt<SaveTicketItemUseCase>(),
    deleteTicketItemUseCase: getIt<DeleteTicketItemUseCase>(),
    reorderTicketItemsUseCase: getIt<ReorderTicketItemsUseCase>(),
    processTicketImageUseCase: getIt<ProcessTicketImageUseCase>(),
    documentScannerService: getIt<DocumentScannerService>(),
  ));

  getIt.registerSingleton<DebtsLoansCubit>(DebtsLoansCubit(
    getDebtsLoansUseCase: getIt<GetDebtsLoansUseCase>(),
    addDebtLoanUseCase: getIt<AddDebtLoanUseCase>(),
    updateDebtLoanUseCase: getIt<UpdateDebtLoanUseCase>(),
    deleteDebtLoanUseCase: getIt<DeleteDebtLoanUseCase>(),
    recurrentExpensesCubit: getIt<RecurrentExpensesCubit>(),
  ));
  
  // 5. CUBITS DE FÁBRICA (Se crean bajo demanda)
  getIt.registerFactory<NewUserCubit>(() => NewUserCubit());
  getIt.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit());
  getIt.registerFactory<UpdatePasswordCubit>(() => UpdatePasswordCubit());
  getIt.registerFactory<DeleteAcountCubit>(() => DeleteAcountCubit());
  getIt.registerFactory<IncomesCubit>(() => IncomesCubit());
  getIt.registerFactory<ExpensesCubit>(() => ExpensesCubit());
}
