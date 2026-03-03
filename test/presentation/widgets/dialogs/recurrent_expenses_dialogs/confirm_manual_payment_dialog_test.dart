import 'dart:async';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}

void main() {
  late MockRecurrentExpensesCubit mockCubit;
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
    tExpense = RecurrentExpense(
      id: '1',
      userId: 'u1',
      name: 'Netflix',
      amount: 15.99,
      startDate: DateTime.now(),
    );
    
    when(() => mockCubit.applyExpenseManually(any())).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.state).thenReturn(const RecurrentExpensesState());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<RecurrentExpensesCubit>.value(
          value: mockCubit,
          child: ConfirmManualPaymentDialog(
            expense: tExpense,
            amount: '15,99',
          ),
        ),
      ),
    );
  }

  group('ConfirmManualPaymentDialog - Pruebas de Flujo', () {
    testWidgets('Debe mostrar el mensaje de confirmación inicialmente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('¿ANOTAR GASTO AHORA?'), findsOneWidget);
      expect(find.textContaining('Netflix'), findsOneWidget);
      expect(find.text('ACEPTAR'), findsOneWidget);
    });

    testWidgets('Debe cambiar al estado de éxito y mostrar el mensaje final', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('ACEPTAR'));
      await tester.pump(); // Llama al cubit y cambia _isSuccess = true

      verify(() => mockCubit.applyExpenseManually(tExpense)).called(1);

      // Esperamos a que las animaciones terminen
      await tester.pumpAndSettle();

      expect(find.text('¡ANOTADO CON ÉXITO!'), findsOneWidget);
      expect(find.text('CERRAR'), findsOneWidget);
      
      // Limpiamos el Timer de autocierre para que el test no falle
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
