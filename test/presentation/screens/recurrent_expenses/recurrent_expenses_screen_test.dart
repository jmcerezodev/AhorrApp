import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
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
      // Verificamos que el logo de la app esté presente
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Debe mostrar la lista de gastos con información dinámica', (WidgetTester tester) async {
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
      
      // Verificamos los nuevos textos dinámicos
      expect(find.text('Día 10 de cada mes'), findsOneWidget);
      expect(find.text('Cobro manual'), findsOneWidget);
    });

    testWidgets('Debe abrir el diálogo de añadir al pulsar el botón circular de la cabecera', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const RecurrentExpensesState(
        status: RecurrentExpensesStatus.success,
        expenses: [],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Buscamos el botón de añadir (el circular en la esquina superior derecha)
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditRecurrentExpenseDialog), findsOneWidget);
    });
  });
}
