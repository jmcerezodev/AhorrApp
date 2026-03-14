import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/screens/debts_loans_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:ahorrapp/presentation/widgets/debts_loans_screen/debts_summary_widget.dart';
import 'package:ahorrapp/presentation/widgets/shared/empty_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/mock_platform.dart';

class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDebtsLoansCubit mockCubit;
  late MockThemeCubit mockThemeCubit;

  setUpAll(() {
    setupAllMocks();
  });

  setUp(() {
    mockCubit = MockDebtsLoansCubit();
    mockThemeCubit = MockThemeCubit();
    
    when(() => mockCubit.state).thenReturn(const DebtsLoansState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadDebtsLoans()).thenAnswer((_) async => {});
    
    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DebtsLoansCubit>.value(value: mockCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: DebtsLoansScreen(),
        ),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DebtsLoansScreen - Widget Tests', () {
    testWidgets('Debe mostrar EmptyListWidget si no hay datos', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyListWidget), findsOneWidget);
      expect(find.text('No tienes deudas pendientes.\n¡Estás al día con tus pagos!'), findsOneWidget);
      
      await tester.tap(find.text('PRÉSTAMOS'));
      await tester.pumpAndSettle();
      expect(find.byType(EmptyListWidget), findsOneWidget);
      expect(find.text('No has realizado préstamos.\nNo te debe dinero nadie.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Debe mostrar deudas en la pestaña correspondiente', (WidgetTester tester) async {
      setupScreenSize(tester);
      final debts = [
        DebtLoan(id: '1', userId: 'u', name: 'Coche', person: 'Banco', totalAmount: 100, type: DebtLoanType.debt)
      ];
      when(() => mockCubit.state).thenReturn(DebtsLoansState(debtsLoans: debts));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Coche'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Debe abrir el diálogo de añadir al pulsar la burbuja de resumen', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap efectivo usando el tipo de widget ahora público
      final burbuja = find.byType(BurbujaResumenWidget);
      await tester.tap(burbuja);
      await tester.pump(); 
      await tester.pumpAndSettle(); 

      // Verificación universal por descendencia (TextField)
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
      expect(find.byType(AddEditDebtLoanDialog), findsOneWidget);

      // Limpieza quirúrgica del árbol y timers
      await tester.pumpWidget(Container());
      await tester.pump(const Duration(seconds: 3));
    });

    group('Consistencia de Formato de Moneda', () {
      testWidgets('Debe mostrar importes sin decimales innecesarios', (WidgetTester tester) async {
        setupScreenSize(tester);
        final debts = [
          DebtLoan(id: '1', userId: 'u', name: 'Test', person: 'P', totalAmount: 100, type: DebtLoanType.debt)
        ];
        when(() => mockCubit.state).thenReturn(DebtsLoansState(debtsLoans: debts));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('100€').first, findsOneWidget);
        
        await tester.pump(const Duration(seconds: 3));
      });
    });
  });
}
