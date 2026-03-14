import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/empty_list_widget.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}
class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockRecurrentExpensesCubit mockCubit;
  late MockDebtsLoansCubit mockDebtsCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockCubit = MockRecurrentExpensesCubit();
    mockDebtsCubit = MockDebtsLoansCubit();
    mockThemeCubit = MockThemeCubit();
    
    when(() => mockCubit.loadExpenses()).thenAnswer((_) async => {});
    when(() => mockCubit.reorderExpenses(any(), any(), isIncome: any(named: 'isIncome'))).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.state).thenReturn(const RecurrentExpensesState());
    
    when(() => mockDebtsCubit.loadDebtsLoans()).thenAnswer((_) async => {});
    when(() => mockDebtsCubit.state).thenReturn(const DebtsLoansState());
    when(() => mockDebtsCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecurrentExpensesCubit>.value(value: mockCubit),
        BlocProvider<DebtsLoansCubit>.value(value: mockDebtsCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: RecurrentExpensesScreen(),
        ),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RecurrentExpensesScreen - Pruebas de Interfaz', () {
    testWidgets('Debe mostrar el título MIS FIJOS en la AppBar', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text('MIS FIJOS'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar EmptyListWidget si no hay registros', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(EmptyListWidget), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar la lista de gastos en la pestaña GASTOS', (WidgetTester tester) async {
      setupScreenSize(tester);
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 10, day: 1, startDate: DateTime.now(), isIncome: false),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      expect(find.text('Netflix'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar la lista de ingresos al cambiar de pestaña', (WidgetTester tester) async {
      setupScreenSize(tester);
      final items = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Sueldo', amount: 2000, day: 1, startDate: DateTime.now(), isIncome: true),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: items));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('INGRESOS'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Sueldo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe abrir el diálogo de añadir con el tipo correcto (Gasto)', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: []));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('NUEVO GASTO'));
      await tester.pumpAndSettle();
      
      final dialog = tester.widget<AddEditRecurrentExpenseDialog>(find.byType(AddEditRecurrentExpenseDialog));
      expect(dialog.isIncome, false);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe abrir el diálogo de añadir con el tipo correcto (Ingreso)', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: []));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('INGRESOS'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('NUEVO INGRESO'));
      await tester.pumpAndSettle();
      
      final dialog = tester.widget<AddEditRecurrentExpenseDialog>(find.byType(AddEditRecurrentExpenseDialog));
      expect(dialog.isIncome, true);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar el nombre de la deuda y el chip DEUDA si está vinculada', (WidgetTester tester) async {
      setupScreenSize(tester);
      final expenses = [
        RecurrentExpense(id: 'exp1', userId: 'u1', name: 'Gasto Original', amount: 50.0, day: 15, startDate: DateTime.now(), isIncome: false),
      ];
      final debts = [
        DebtLoan(id: 'debt1', userId: 'u1', name: 'Nombre de Deuda', person: 'Banco', totalAmount: 1000, type: DebtLoanType.debt, recurrentExpenseId: 'exp1'),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
      when(() => mockDebtsCubit.state).thenReturn(DebtsLoansState(debtsLoans: debts));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Nombre de Deuda'), findsOneWidget);
      expect(find.text('DEUDA'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar fondo de edición al deslizar a la derecha', (WidgetTester tester) async {
      setupScreenSize(tester);
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 15, day: 10, startDate: DateTime.now()),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      await tester.drag(find.text('Netflix'), const Offset(200.0, 0.0));
      await tester.pumpAndSettle();
      
      expect(find.descendant(of: find.byType(SwipeBackgroundWidget), matching: find.text('EDITAR')), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe permitir reordenar la lista', (WidgetTester tester) async {
      setupScreenSize(tester);
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 10, day: 1, startDate: DateTime.now(), position: 0),
        RecurrentExpense(id: '2', userId: 'u1', name: 'HBO', amount: 10, day: 1, startDate: DateTime.now(), position: 1),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final firstItem = find.text('Netflix');
      final secondItem = find.text('HBO');

      final TestGesture gesture = await tester.startGesture(tester.getCenter(firstItem));
      await tester.pump(const Duration(milliseconds: 500)); 
      await gesture.moveTo(tester.getCenter(secondItem));
      await gesture.up();
      await tester.pumpAndSettle();

      verify(() => mockCubit.reorderExpenses(any(), any(), isIncome: any(named: 'isIncome'))).called(1);
      await tester.pump(const Duration(seconds: 5));
    });
   group('RecurrentHistoryWidget Animation Tests', () {
      testWidgets('Debe utilizar FadeInUp para el listado', (WidgetTester tester) async {
        setupScreenSize(tester);
        final expenses = [
          RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 10, day: 1, startDate: DateTime.now()),
        ];
        when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
        
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));
        
        expect(find.byType(FadeInUp).first, findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
      });
    });
  });
}
