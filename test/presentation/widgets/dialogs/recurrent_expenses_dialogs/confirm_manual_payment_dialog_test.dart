import 'dart:async';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}
class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockRecurrentExpensesCubit mockCubit;
  late MockDebtsLoansCubit mockDebtsCubit;
  late RecurrentExpense tExpense;

  setUpAll(() {
    registerFallbackValue(RecurrentExpense(
      id: '',
      userId: '',
      name: '',
      amount: 0,
      startDate: DateTime.now(),
    ));
  });

  setUp(() {
    mockCubit = MockRecurrentExpensesCubit();
    mockDebtsCubit = MockDebtsLoansCubit();
    tExpense = RecurrentExpense(
      id: '1',
      userId: 'u1',
      name: 'Netflix',
      amount: 15.99,
      startDate: DateTime.now(),
      isIncome: false,
    );
    
    when(() => mockCubit.applyExpenseManually(any(), debtsCubit: any(named: 'debtsCubit'))).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.state).thenReturn(const RecurrentExpensesState());

    when(() => mockDebtsCubit.state).thenReturn(const DebtsLoansState());
    when(() => mockDebtsCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest({RecurrentExpense? expense}) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RecurrentExpensesCubit>.value(value: mockCubit),
            BlocProvider<DebtsLoansCubit>.value(value: mockDebtsCubit),
          ],
          child: ConfirmManualPaymentDialog(
            expense: expense ?? tExpense,
            amount: '15,99',
          ),
        ),
      ),
    );
  }

  group('ConfirmManualPaymentDialog - Pruebas de Flujo', () {
    testWidgets('Debe mostrar el mensaje de confirmación inicialmente para un GASTO', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('¿ANOTAR GASTO AHORA?'), findsOneWidget);
      expect(find.textContaining('Netflix'), findsOneWidget);
      expect(find.text('ACEPTAR'), findsOneWidget);
    });

    testWidgets('Debe mostrar el mensaje de confirmación inicialmente para un INGRESO', (WidgetTester tester) async {
      final tIncome = tExpense.copyWith(isIncome: true, name: 'Nómina');
      await tester.pumpWidget(createWidgetUnderTest(expense: tIncome));
      await tester.pumpAndSettle();

      expect(find.text('¿ANOTAR INGRESO AHORA?'), findsOneWidget);
      expect(find.textContaining('Nómina'), findsOneWidget);
    });

    testWidgets('Debe cambiar al estado de éxito y mostrar el mensaje final', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('ACEPTAR'));
      await tester.pump(); 

      verify(() => mockCubit.applyExpenseManually(tExpense, debtsCubit: any(named: 'debtsCubit'))).called(1);

      await tester.pumpAndSettle();

      expect(find.text('¡ANOTADO CON ÉXITO!'), findsOneWidget);
      expect(find.text('CERRAR'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
