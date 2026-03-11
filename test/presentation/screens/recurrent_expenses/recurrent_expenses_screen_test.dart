import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/delete_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}
class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockRecurrentExpensesCubit mockCubit;
  late MockDebtsLoansCubit mockDebtsCubit;

  setUp(() {
    mockCubit = MockRecurrentExpensesCubit();
    mockDebtsCubit = MockDebtsLoansCubit();
    
    when(() => mockCubit.loadExpenses()).thenAnswer((_) async => {});
    when(() => mockCubit.reorderExpenses(any(), any(), isIncome: any(named: 'isIncome'))).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    
    // STUB OBLIGATORIO: loadDebtsLoans() para el initState
    when(() => mockDebtsCubit.loadDebtsLoans()).thenAnswer((_) async => {});
    when(() => mockDebtsCubit.state).thenReturn(const DebtsLoansState());
    when(() => mockDebtsCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecurrentExpensesCubit>.value(value: mockCubit),
        BlocProvider<DebtsLoansCubit>.value(value: mockDebtsCubit),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: RecurrentExpensesScreen(),
        ),
      ),
    );
  }

  group('RecurrentExpensesScreen - Pruebas de Interfaz', () {
    testWidgets('Debe mostrar el título MIS FIJOS en la AppBar', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(expenses: []));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text('MIS FIJOS'), findsOneWidget);
    });

    testWidgets('Debe mostrar el estado vacío si no hay registros', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(expenses: []));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text('SIN GASTOS FIJOS'), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de gastos en la pestaña GASTOS', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 10, day: 1, startDate: DateTime.now(), isIncome: false),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      expect(find.text('Netflix'), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de ingresos al cambiar de pestaña', (WidgetTester tester) async {
      final items = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Sueldo', amount: 2000, day: 1, startDate: DateTime.now(), isIncome: true),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: items));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('INGRESOS'));
      await tester.pumpAndSettle();

      expect(find.text('Sueldo'), findsOneWidget);
    });

    testWidgets('Debe abrir el diálogo de añadir con el tipo correcto (Gasto)', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: []));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('NUEVO GASTO'));
      await tester.pumpAndSettle();
      
      final dialog = tester.widget<AddEditRecurrentExpenseDialog>(find.byType(AddEditRecurrentExpenseDialog));
      expect(dialog.isIncome, false);
    });

    testWidgets('Debe abrir el diálogo de añadir con el tipo correcto (Ingreso)', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: []));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('INGRESOS'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('NUEVO INGRESO'));
      await tester.pumpAndSettle();
      
      final dialog = tester.widget<AddEditRecurrentExpenseDialog>(find.byType(AddEditRecurrentExpenseDialog));
      expect(dialog.isIncome, true);
    });

    testWidgets('Debe mostrar el nombre de la deuda y el chip DEUDA si está vinculada', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(id: 'exp1', userId: 'u1', name: 'Gasto Original', amount: 50.0, day: 15, startDate: DateTime.now(), isIncome: false),
      ];
      final debts = [
        DebtLoan(id: 'debt1', userId: 'u1', name: 'Nombre de Deuda', person: 'Banco', totalAmount: 1000, type: DebtLoanType.debt, recurrentExpenseId: 'exp1'),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
      when(() => mockDebtsCubit.state).thenReturn(DebtsLoansState(debtsLoans: debts));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nombre de Deuda'), findsOneWidget);
      expect(find.text('DEUDA'), findsOneWidget);
    });

    testWidgets('Debe mostrar fondo de edición al deslizar a la derecha', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 15, day: 10, startDate: DateTime.now()),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.drag(find.text('Netflix'), const Offset(200.0, 0.0));
      await tester.pump();
      
      expect(find.descendant(of: find.byType(SwipeBackgroundWidget), matching: find.text('EDITAR')), findsOneWidget);
    });

    testWidgets('Debe permitir reordenar la lista', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 10, day: 1, startDate: DateTime.now(), position: 0),
        RecurrentExpense(id: '2', userId: 'u1', name: 'HBO', amount: 10, day: 1, startDate: DateTime.now(), position: 1),
      ];
      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(status: RecurrentExpensesStatus.success, expenses: expenses));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final firstItem = find.text('Netflix');
      final secondItem = find.text('HBO');

      final TestGesture gesture = await tester.startGesture(tester.getCenter(firstItem));
      await tester.pump(const Duration(milliseconds: 500)); 
      await gesture.moveTo(tester.getCenter(secondItem));
      await gesture.up();
      await tester.pumpAndSettle();

      verify(() => mockCubit.reorderExpenses(any(), any(), isIncome: any(named: 'isIncome'))).called(1);
    });
  });
}
