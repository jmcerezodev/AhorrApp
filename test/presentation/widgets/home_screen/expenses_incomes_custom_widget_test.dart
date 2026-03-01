import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/expenses_incomes_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockDateCubit extends Mock implements DateCubit {}

void main() {
  late MockHistoryCubit mockHistoryCubit;
  late MockDateCubit mockDateCubit;

  setUp(() {
    mockHistoryCubit = MockHistoryCubit();
    mockDateCubit = MockDateCubit();

    // Mockeamos el estado del historial con datos de prueba
    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
      historyList: [
        {'money': 1000.0, 'type': 'income', 'month': 'Enero', 'year': 2024},
        {'money': 200.0, 'type': 'expense', 'month': 'Enero', 'year': 2024},
      ],
    ));
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async => {});

    // Mockeamos el estado de la fecha
    when(() => mockDateCubit.state).thenReturn(const DateCubitState(month: 'Enero', year: 2024));
    when(() => mockDateCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDateCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
            BlocProvider<DateCubit>.value(value: mockDateCubit),
          ],
          child: const ExpensesIncomesCustomWidget(),
        ),
      ),
    );
  }

  group('ExpensesIncomesCustomWidget - Pruebas Visuales', () {
    testWidgets('Debe mostrar los títulos de INGRESOS y GASTOS', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Esperamos animaciones de animate_do

      expect(find.text('INGRESOS'), findsOneWidget);
      expect(find.text('GASTOS'), findsOneWidget);
    });

    testWidgets('Debe mostrar los montos correctos calculados', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Buscamos los textos que contienen los números (usando containing por seguridad de formato)
      expect(find.textContaining('1.000'), findsOneWidget); // Ingreso
      expect(find.textContaining('200'), findsOneWidget);   // Gasto
    });

    testWidgets('Debe tener los iconos de flecha correctos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });
  });
}
