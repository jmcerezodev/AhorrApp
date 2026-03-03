import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
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
          day: DateTime.now().day, // Hoy para que diga "¡Se cobra hoy!"
          frequency: RecurrentFrequency.monthly,
          startDate: DateTime.now()
        ),
        RecurrentExpense(
          id: '2', 
          userId: 'u1', 
          name: 'Seguro', 
          amount: 100.0, 
          day: null, 
          startDate: DateTime.now()
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
      
      // Verificamos los textos dinámicos
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
          startDate: DateTime.now()
        ),
      ];

      when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: expenses,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Pulsamos el botón de añadir (playlist_add_rounded)
      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmManualPaymentDialog), findsOneWidget);
    });

    testWidgets('Debe abrir el diálogo de añadir al pulsar el botón circular de la cabecera', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: [],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditRecurrentExpenseDialog), findsOneWidget);
    });
   group('RecurrentExpensesScreen - Gestos de Deslizamiento', () {
      testWidgets('Debe mostrar el fondo de edición al deslizar a la derecha', (WidgetTester tester) async {
        final expenses = [
          RecurrentExpense(
            id: '1', 
            userId: 'u1', 
            name: 'Netflix', 
            amount: 15.99, 
            day: 10, 
            frequency: RecurrentFrequency.monthly,
            startDate: DateTime.now()
          ),
        ];

        when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
          status: RecurrentExpensesStatus.success,
          expenses: expenses,
        ));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Deslizamos a la derecha (start to end)
        await tester.drag(find.text('Netflix'), const Offset(500.0, 0.0));
        await tester.pump();

        expect(find.text('EDITAR'), findsOneWidget);
      });

      testWidgets('Debe mostrar el fondo de eliminación al deslizar a la izquierda', (WidgetTester tester) async {
        final expenses = [
          RecurrentExpense(
            id: '1', 
            userId: 'u1', 
            name: 'Netflix', 
            amount: 15.99, 
            day: 10, 
            frequency: RecurrentFrequency.monthly,
            startDate: DateTime.now()
          ),
        ];

        when(() => mockCubit.state).thenReturn(RecurrentExpensesState(
          status: RecurrentExpensesStatus.success,
          expenses: expenses,
        ));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Deslizamos a la izquierda (end to start)
        await tester.drag(find.text('Netflix'), const Offset(-500.0, 0.0));
        await tester.pump();

        expect(find.text('ELIMINAR'), findsOneWidget);
      });
    });
  });
}
