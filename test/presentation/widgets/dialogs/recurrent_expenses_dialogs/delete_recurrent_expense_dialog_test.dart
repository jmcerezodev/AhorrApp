import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/delete_recurrent_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}
class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockRecurrentExpensesCubit mockRecurrentCubit;
  late MockDebtsLoansCubit mockDebtsCubit;

  setUpAll(() {
    registerFallbackValue(MockDebtsLoansCubit());
  });

  setUp(() {
    mockRecurrentCubit = MockRecurrentExpensesCubit();
    mockDebtsCubit = MockDebtsLoansCubit();

    when(() => mockRecurrentCubit.state).thenReturn(const RecurrentExpensesState());
    when(() => mockRecurrentCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDebtsCubit.state).thenReturn(const DebtsLoansState());
    when(() => mockDebtsCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest(String id, String name) {
    // Usamos un Navigator real con una página debajo para que pop() no rompa GoRouter
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<RecurrentExpensesCubit>.value(value: mockRecurrentCubit),
                    BlocProvider<DebtsLoansCubit>.value(value: mockDebtsCubit),
                  ],
                  child: DeleteRecurrentExpenseDialog(expenseId: id, expenseName: name),
                ),
              );
            },
            child: const Text('SHOW DIALOG'),
          ),
        ),
      ),
    );
  }

  group('DeleteRecurrentExpenseDialog - Pruebas de Sincronización', () {
    testWidgets('Debe mostrar advertencia de DEUDA vinculada', (WidgetTester tester) async {
      final linkedDebt = DebtLoan(id: 'd1', userId: 'u1', name: 'Deuda Coche', person: 'Banco', totalAmount: 1000, type: DebtLoanType.debt, recurrentExpenseId: 'exp1');
      when(() => mockDebtsCubit.state).thenReturn(DebtsLoansState(debtsLoans: [linkedDebt]));
      when(() => mockRecurrentCubit.state).thenReturn(RecurrentExpensesState(expenses: [
        RecurrentExpense(id: 'exp1', userId: 'u1', name: 'Netflix', amount: 10, startDate: DateTime.now(), isIncome: false)
      ]));

      await tester.pumpWidget(createWidgetUnderTest('exp1', 'Netflix'));
      
      final showBtn = find.text('SHOW DIALOG');
      await tester.ensureVisible(showBtn);
      await tester.tap(showBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('vinculado a la deuda "Deuda Coche"'), findsOneWidget);
    });

    testWidgets('Debe llamar a eliminar y cerrar el diálogo', (WidgetTester tester) async {
      when(() => mockDebtsCubit.state).thenReturn(const DebtsLoansState(debtsLoans: []));
      when(() => mockRecurrentCubit.state).thenReturn(RecurrentExpensesState(expenses: [
        RecurrentExpense(id: 'exp1', userId: 'u1', name: 'Netflix', amount: 10, startDate: DateTime.now(), isIncome: false)
      ]));
      when(() => mockRecurrentCubit.deleteExpense(any(), debtsCubit: any(named: 'debtsCubit'), deleteDebt: any(named: 'deleteDebt')))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest('exp1', 'Netflix'));
      
      final showBtn = find.text('SHOW DIALOG');
      await tester.ensureVisible(showBtn);
      await tester.tap(showBtn);
      await tester.pumpAndSettle();

      final deleteBtn = find.text('ELIMINAR');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle(); 
      
      verify(() => mockRecurrentCubit.deleteExpense(any(), debtsCubit: any(named: 'debtsCubit'), deleteDebt: any(named: 'deleteDebt'))).called(1);
      expect(find.byType(DeleteRecurrentExpenseDialog), findsNothing);
    });
  });
}
