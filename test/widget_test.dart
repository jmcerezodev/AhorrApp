import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/security_cubit/security_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/date_cubit/date_cubit.dart';
import 'package:ahorrapp/presentation/bloc/incomes_cubit/incomes_cubit.dart';
import 'package:ahorrapp/presentation/bloc/expenses_cubit/expenses_cubit.dart';
import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ahorrapp/main.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks necesarios
class MockThemeCubit extends Mock implements ThemeCubit {}
class MockSecurityCubit extends Mock implements SecurityCubit {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockLoginCubit extends Mock implements LoginCubit {}
class MockShoppingListCubit extends Mock implements ShoppingListCubit {}
class MockShoppingTemplatesCubit extends Mock implements ShoppingTemplatesCubit {}
class MockTicketsCubit extends Mock implements TicketsCubit {}
class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}
class MockNewUserCubit extends Mock implements NewUserCubit {}
class MockResetPasswordCubit extends Mock implements ResetPasswordCubit {}
class MockUpdatePasswordCubit extends Mock implements UpdatePasswordCubit {}
class MockUpdateNameCubit extends Mock implements UpdateNameCubit {}
class MockDeleteAcountCubit extends Mock implements DeleteAcountCubit {}
class MockSavingsCubit extends Mock implements SavingsCubit {}
class MockDateCubit extends Mock implements DateCubit {}
class MockIncomesCubit extends Mock implements IncomesCubit {}
class MockExpensesCubit extends Mock implements ExpensesCubit {}
class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.jmcerezo.ahorrapp/security');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (message) async => true);

  late MockThemeCubit mockThemeCubit;
  late MockSecurityCubit mockSecurityCubit;
  late MockTotalMoneyCubit mockTotalMoneyCubit;
  late MockHistoryCubit mockHistoryCubit;
  late MockLoginCubit mockLoginCubit;
  late MockShoppingListCubit mockShoppingListCubit;
  late MockShoppingTemplatesCubit mockShoppingTemplatesCubit;
  late MockTicketsCubit mockTicketsCubit;
  late MockDebtsLoansCubit mockDebtsLoansCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
    getIt.reset();
    
    mockThemeCubit = MockThemeCubit();
    mockSecurityCubit = MockSecurityCubit();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    mockHistoryCubit = MockHistoryCubit();
    mockLoginCubit = MockLoginCubit();
    mockShoppingListCubit = MockShoppingListCubit();
    mockShoppingTemplatesCubit = MockShoppingTemplatesCubit();
    mockTicketsCubit = MockTicketsCubit();
    mockDebtsLoansCubit = MockDebtsLoansCubit();

    // Stubs con tipado explícito para evitar TypeError
    when(() => mockThemeCubit.state).thenReturn(ThemeState(themeMode: ThemeMode.system, isPrivacyModeActive: false));
    when(() => mockThemeCubit.stream).thenAnswer((_) => Stream<ThemeState>.empty());
    when(() => mockThemeCubit.close()).thenAnswer((_) async {});
    
    when(() => mockSecurityCubit.state).thenReturn(SecurityState(status: SecurityStatus.unlocked));
    when(() => mockSecurityCubit.stream).thenAnswer((_) => Stream<SecurityState>.empty());
    when(() => mockSecurityCubit.close()).thenAnswer((_) async {});

    when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState());
    when(() => mockTotalMoneyCubit.stream).thenAnswer((_) => Stream<TotalMoneyCubitState>.empty());
    when(() => mockTotalMoneyCubit.close()).thenAnswer((_) async {});

    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState());
    when(() => mockHistoryCubit.stream).thenAnswer((_) => Stream<HistoryCubitState>.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async {});

    when(() => mockLoginCubit.state).thenReturn(const LoginCubitState());
    when(() => mockLoginCubit.stream).thenAnswer((_) => Stream<LoginCubitState>.empty());
    when(() => mockLoginCubit.close()).thenAnswer((_) async {});

    when(() => mockShoppingListCubit.state).thenReturn(const ShoppingState());
    when(() => mockShoppingListCubit.stream).thenAnswer((_) => Stream<ShoppingState>.empty());
    when(() => mockShoppingListCubit.close()).thenAnswer((_) async {});

    when(() => mockShoppingTemplatesCubit.state).thenReturn(const ShoppingTemplatesState());
    when(() => mockShoppingTemplatesCubit.stream).thenAnswer((_) => Stream<ShoppingTemplatesState>.empty());
    when(() => mockShoppingTemplatesCubit.close()).thenAnswer((_) async {});

    when(() => mockTicketsCubit.state).thenReturn(const TicketsState());
    when(() => mockTicketsCubit.stream).thenAnswer((_) => Stream<TicketsState>.empty());
    when(() => mockTicketsCubit.close()).thenAnswer((_) async {});

    when(() => mockDebtsLoansCubit.state).thenReturn(const DebtsLoansState());
    when(() => mockDebtsLoansCubit.stream).thenAnswer((_) => Stream<DebtsLoansState>.empty());
    when(() => mockDebtsLoansCubit.close()).thenAnswer((_) async {});

    // Registro de Singletons
    getIt.registerSingleton<ThemeCubit>(mockThemeCubit);
    getIt.registerSingleton<SecurityCubit>(mockSecurityCubit);
    getIt.registerSingleton<TotalMoneyCubit>(mockTotalMoneyCubit);
    getIt.registerSingleton<HistoryCubit>(mockHistoryCubit);
    getIt.registerSingleton<LoginCubit>(mockLoginCubit);
    getIt.registerSingleton<ShoppingListCubit>(mockShoppingListCubit);
    getIt.registerSingleton<ShoppingTemplatesCubit>(mockShoppingTemplatesCubit);
    getIt.registerSingleton<TicketsCubit>(mockTicketsCubit);
    getIt.registerSingleton<DebtsLoansCubit>(mockDebtsLoansCubit);

    // Registro de Factorías con sus respectivos stubs
    getIt.registerFactory<NewUserCubit>(() {
      final m = MockNewUserCubit();
      when(() => m.state).thenReturn(const NewUserCubitState());
      when(() => m.stream).thenAnswer((_) => Stream<NewUserCubitState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<ResetPasswordCubit>(() {
      final m = MockResetPasswordCubit();
      when(() => m.state).thenReturn(const ResetPasswordState());
      when(() => m.stream).thenAnswer((_) => Stream<ResetPasswordState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<UpdatePasswordCubit>(() {
      final m = MockUpdatePasswordCubit();
      when(() => m.state).thenReturn(const UpdatePasswordState());
      when(() => m.stream).thenAnswer((_) => Stream<UpdatePasswordState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<UpdateNameCubit>(() {
      final m = MockUpdateNameCubit();
      when(() => m.state).thenReturn(const UpdateNameState(name: ''));
      when(() => m.stream).thenAnswer((_) => Stream<UpdateNameState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<DeleteAcountCubit>(() {
      final m = MockDeleteAcountCubit();
      when(() => m.state).thenReturn(const DeleteCubitState());
      when(() => m.stream).thenAnswer((_) => Stream<DeleteCubitState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<SavingsCubit>(() {
      final m = MockSavingsCubit();
      when(() => m.state).thenReturn(const SavingsCubitState());
      when(() => m.stream).thenAnswer((_) => Stream<SavingsCubitState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<DateCubit>(() {
      final m = MockDateCubit();
      when(() => m.state).thenReturn(const DateCubitState());
      when(() => m.stream).thenAnswer((_) => Stream<DateCubitState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<IncomesCubit>(() {
      final m = MockIncomesCubit();
      when(() => m.state).thenReturn(const IncomesCubitState());
      when(() => m.stream).thenAnswer((_) => Stream<IncomesCubitState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<ExpensesCubit>(() {
      final m = MockExpensesCubit();
      when(() => m.state).thenReturn(const ExpensesCubitState());
      when(() => m.stream).thenAnswer((_) => Stream<ExpensesCubitState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
    getIt.registerFactory<RecurrentExpensesCubit>(() {
      final m = MockRecurrentExpensesCubit();
      when(() => m.state).thenReturn(const RecurrentExpensesState());
      when(() => m.stream).thenAnswer((_) => Stream<RecurrentExpensesState>.empty());
      when(() => m.close()).thenAnswer((_) async {});
      return m;
    });
  });

  testWidgets('MainAppWrapper boots correctly', (WidgetTester tester) async {
    // Configuración de resolución para evitar overflow
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          BlocProvider<SecurityCubit>.value(value: mockSecurityCubit),
        ],
        child: const MainAppWrapper(initialRoute: '/login'),
      )
    );

    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
