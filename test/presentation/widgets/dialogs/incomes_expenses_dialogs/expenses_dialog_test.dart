import 'package:ahorrapp/core/inputs/expenses_inputs/expense_money_input.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/incomes_expenses_dialogs/expenses_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpensesCubit extends Mock implements ExpensesCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}

void main() {
  late MockExpensesCubit mockExpensesCubit;
  late MockHistoryCubit mockHistoryCubit;
  late MockTotalMoneyCubit mockTotalMoneyCubit;

  setUp(() {
    mockExpensesCubit = MockExpensesCubit();
    mockHistoryCubit = MockHistoryCubit();
    mockTotalMoneyCubit = MockTotalMoneyCubit();

    // Estado inicial seguro para Expenses
    when(() => mockExpensesCubit.state).thenReturn(const ExpensesCubitState());
    when(() => mockExpensesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockExpensesCubit.close()).thenAnswer((_) async => {});
    when(() => mockExpensesCubit.resetCubit()).thenReturn(null);
    when(() => mockExpensesCubit.expenseNameChanged(any())).thenReturn(null);
    when(() => mockExpensesCubit.expenseMoneyChanged(any())).thenReturn(null);

    // Estado inicial para History
    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState());
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async => {});

    // Estado inicial para TotalMoney (Simulamos que tiene 100€)
    when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState(totalMoney: 100.0));
    when(() => mockTotalMoneyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTotalMoneyCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ExpensesCubit>.value(value: mockExpensesCubit),
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
            BlocProvider<TotalMoneyCubit>.value(value: mockTotalMoneyCubit),
          ],
          child: const ExpensesDialog(),
        ),
      ),
    );
  }

  group('ExpensesDialog - Pruebas de Formulario de Gastos', () {
    testWidgets('Debe mostrar el título y el saldo disponible', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('NUEVO GASTO'), findsOneWidget);
      // Verificamos que aparezca el saldo de 100€ que configuramos en el mock
      expect(find.textContaining('100.00€'), findsOneWidget);
    });

    testWidgets('Debe mostrar error si el gasto supera el saldo disponible', (WidgetTester tester) async {
      // CORREGIDO: Eliminado const y ajustado el valor sucio correctamente
      when(() => mockExpensesCubit.state).thenReturn(
        const ExpensesCubitState(expenseMoney: ExpenseMoneyInput.dirty(value: '150'))
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Debería aparecer el aviso de falta de saldo
      expect(find.text('Excede el saldo disponible'), findsOneWidget);
    });

    testWidgets('Al escribir el concepto, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final nameField = find.widgetWithText(TextField, 'Concepto del gasto');
      await tester.enterText(nameField, 'Cena amigos');
      
      verify(() => mockExpensesCubit.expenseNameChanged('Cena amigos')).called(1);
    });
  });
}
