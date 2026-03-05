import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}

void main() {
  late MockRecurrentExpensesCubit mockCubit;

  setUp(() {
    mockCubit = MockRecurrentExpensesCubit();
    when(() => mockCubit.loadExpenses()).thenAnswer((_) async => {});
    when(() => mockCubit.reorderExpenses(any(), any())).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<RecurrentExpensesCubit>.value(
        value: mockCubit,
        child: const RecurrentExpensesScreen(),
      ),
    );
  }

  group('RecurrentExpensesScreen - Pruebas de Interfaz', () {
    testWidgets('Debe mostrar el estado vacío con el logo si no hay gastos', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: [],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('SIN GASTOS FIJOS'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de gastos con información dinámica y contador de días', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(
          id: '1', 
          userId: 'u1', 
          name: 'Netflix', 
          amount: 15.99, 
          day: DateTime.now().day, 
          frequency: RecurrentFrequency.monthly,
          startDate: DateTime.now(),
          position: 0,
        ),
        RecurrentExpense(
          id: '2', 
          userId: 'u1', 
          name: 'Seguro', 
          amount: 100.0, 
          day: null, 
          startDate: DateTime.now(),
          position: 1,
        ),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: expenses,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Seguro'), findsOneWidget);
      expect(find.text('¡Se cobra hoy!'), findsOneWidget);
      expect(find.text('Cobro manual'), findsOneWidget);
    });

    testWidgets('Debe abrir el diálogo de confirmación al pulsar el botón de añadir en un gasto manual', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(
          id: '2', 
          userId: 'u1', 
          name: 'Gasto Manual', 
          amount: 10.0, 
          day: null, 
          startDate: DateTime.now(),
          position: 0,
        ),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: expenses,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmManualPaymentDialog), findsOneWidget);
    });

    testWidgets('Debe abrir el diálogo de añadir al pulsar la burbuja de la tarjeta de resumen', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Test', amount: 10.0, day: 1, startDate: DateTime.now()),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: expenses,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('NUEVO GASTO'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditRecurrentExpenseDialog), findsOneWidget);
    });

    group('RecurrentExpensesScreen - Gestos de Deslizamiento', () {
      testWidgets('Debe mostrar el fondo de edición al deslizar a la derecha', (WidgetTester tester) async {
        final expenses = [
          RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 15.99, day: 10, startDate: DateTime.now()),
        ];

        when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
          status: RecurrentExpensesStatus.success,
          expenses: expenses,
        ));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.drag(find.text('Netflix'), const Offset(500.0, 0.0));
        await tester.pump(); 
        await tester.pump(const Duration(milliseconds: 500)); 

        expect(find.descendant(of: find.byType(SwipeBackgroundWidget), matching: find.text('EDITAR')), findsOneWidget);
      });

      testWidgets('Debe mostrar el fondo de eliminación al deslizar a la izquierda', (WidgetTester tester) async {
        final expenses = [
          RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 15.99, day: 10, startDate: DateTime.now()),
        ];

        when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
          status: RecurrentExpensesStatus.success,
          expenses: expenses,
        ));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.drag(find.text('Netflix'), const Offset(-500.0, 0.0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.descendant(of: find.byType(SwipeBackgroundWidget), matching: find.text('ELIMINAR')), findsOneWidget);
      });
    });

    testWidgets('Debe permitir reordenar elementos en la lista', (WidgetTester tester) async {
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Netflix', amount: 15.99, day: 10, startDate: DateTime.now(), position: 0),
        RecurrentExpense(id: '2', userId: 'u1', name: 'HBO', amount: 9.99, day: 15, startDate: DateTime.now(), position: 1),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: expenses,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final firstItem = find.text('Netflix');
      final secondItem = find.text('HBO');

      final TestGesture gesture = await tester.startGesture(tester.getCenter(firstItem));
      await tester.pump(const Duration(milliseconds: 1000));
      
      await gesture.moveTo(tester.getCenter(secondItem));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      
      await tester.pumpAndSettle();

      verify(() => mockCubit.reorderExpenses(any(), any())).called(1);
    });
  });
}
