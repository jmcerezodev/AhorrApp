import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/history_custom_widget.dart';
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

    // Estado inicial con movimientos de prueba
    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
      showIncomes: true,
      showExpenses: true,
      showSavings: true,
      listOrder: 'descending',
      historyList: [
        {
          'id': '1',
          'name': 'Sueldo Mensual',
          'money': 2500.0,
          'type': 'income',
          'year': 2024,
          'month': 'Enero',
          'currentDate': '01/01/2024',
          'currentHour': '09:00 AM',
          'createdAt': '2024-01-01T09:00:00Z'
        },
        {
          'id': '2',
          'name': 'Compra Super',
          'money': 85.50,
          'type': 'expense',
          'year': 2024,
          'month': 'Enero',
          'currentDate': '02/01/2024',
          'currentHour': '10:30 AM',
          'createdAt': '2024-01-02T10:30:00Z'
        },
      ],
    ));
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async => {});

    when(() => mockDateCubit.state).thenReturn(const DateCubitState(month: 'Enero', year: 2024));
    when(() => mockDateCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDateCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
        BlocProvider<DateCubit>.value(value: mockDateCubit),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: HistoryCustomWidget(),
        ),
      ),
    );
  }

  group('HistoryCustomWidget - Pruebas de Lista y Filtros', () {
    testWidgets('Debe mostrar los nombres y montos de los movimientos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Sueldo Mensual'), findsOneWidget);
      expect(find.text('Compra Super'), findsOneWidget);
      
      // Verificamos los montos formateados
      expect(find.textContaining('2.500'), findsOneWidget);
      expect(find.textContaining('85,50'), findsOneWidget);
    });

    testWidgets('Debe ocultar los gastos si el filtro está desactivado', (WidgetTester tester) async {
      // Cambiamos el estado para ocultar gastos
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
        showIncomes: true,
        showExpenses: false, // OCULTAR
        showSavings: true,
        historyList: [
          {'id': '1', 'name': 'Sueldo Mensual', 'money': 2500.0, 'type': 'income', 'year': 2024, 'month': 'Enero'},
          {'id': '2', 'name': 'Compra Super', 'money': 85.50, 'type': 'expense', 'year': 2024, 'month': 'Enero'},
        ],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Sueldo Mensual'), findsOneWidget);
      expect(find.text('Compra Super'), findsNothing); // Confirmamos que ha desaparecido
    });
  });
}
