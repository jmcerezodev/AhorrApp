import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/monthly_balance_widget.dart';
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

    // Stubs por defecto para evitar errores de 'Null'
    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState());
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async => {});

    when(() => mockDateCubit.state).thenReturn(const DateCubitState(month: 'Marzo', year: 2026));
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
          child: const MonthlyBalanceWidget(),
        ),
      ),
    );
  }

  group('MonthlyBalanceWidget - Verificación de Cálculos y Colores', () {
    testWidgets('Debe mostrar balance positivo en VERDE', (WidgetTester tester) async {
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
        historyList: [
          {'year': 2026, 'month': 'Marzo', 'money': 100.0, 'type': 'income'}
        ]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Aseguramos que el build termine

      // Buscamos el widget que contenga el texto del balance
      final balanceFinder = find.textContaining('100');
      expect(balanceFinder, findsOneWidget);
      
      final Text textWidget = tester.widget(balanceFinder);
      expect(textWidget.style?.color, Colors.green.shade700);
    });

    testWidgets('Debe mostrar balance negativo en ROJO', (WidgetTester tester) async {
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
        historyList: [
          {'year': 2026, 'month': 'Marzo', 'money': 50.0, 'type': 'expense'}
        ]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final balanceFinder = find.textContaining('50');
      expect(balanceFinder, findsOneWidget);
      
      final Text textWidget = tester.widget(balanceFinder);
      expect(textWidget.style?.color, Colors.red.shade700);
    });

    testWidgets('NO debe sumar movimientos de otros meses', (WidgetTester tester) async {
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
        historyList: [
          {'year': 2026, 'month': 'Marzo', 'money': 100.0, 'type': 'income'},
          {'year': 2026, 'month': 'Abril', 'money': 500.0, 'type': 'income'},
        ]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Debe mostrar solo los 100 de Marzo
      expect(find.textContaining('100'), findsOneWidget);
      expect(find.textContaining('600'), findsNothing);
    });
  });
}
