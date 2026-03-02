import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/info_global_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}
class MockSavingsCubit extends Mock implements SavingsCubit {}

void main() {
  late MockHistoryCubit mockHistoryCubit;
  late MockTotalMoneyCubit mockTotalMoneyCubit;
  late MockSavingsCubit mockSavingsCubit;

  setUp(() {
    mockHistoryCubit = MockHistoryCubit();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    mockSavingsCubit = MockSavingsCubit();

    // Estado inicial por defecto para los tests
    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(status: HistoryStatus.success));
    when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState(totalMoney: 1250.50, isSavingsIncluded: true));
    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState(savingTotal: 500, savingGoal: 1000));

    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTotalMoneyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
            BlocProvider<TotalMoneyCubit>.value(value: mockTotalMoneyCubit),
            BlocProvider<SavingsCubit>.value(value: mockSavingsCubit),
          ],
          child: const InfoGlogalWidget(),
        ),
      ),
    );
  }

  group('InfoGlogalWidget - Protección de Diseño y Datos', () {
    testWidgets('Debe mostrar el balance total (incluyendo ahorros) con formato correcto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Buscamos el nuevo texto con el salto de línea
      expect(find.text('BALANCE TOTAL\n(CON AHORROS)'), findsOneWidget);
      // Balance = 1250.50 (cartera) + 500 (ahorros) = 1750.50
      expect(find.text('1.750,50€'), findsOneWidget);
    });

    testWidgets('Debe mostrar solo el balance de cartera si la opción está desactivada', (WidgetTester tester) async {
      when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState(totalMoney: 1250.50, isSavingsIncluded: false));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('BALANCE EN\nCARTERA'), findsOneWidget);
      // Solo muestra los 1250.50 de la cartera
      expect(find.text('1.250,50€'), findsOneWidget);
    });

    testWidgets('Debe mostrar la sección de ahorros y la barra de progreso', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('MIS AHORROS'), findsOneWidget);
      expect(find.text('500€'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Debe mostrar un spinner cuando el historial está cargando', (WidgetTester tester) async {
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(status: HistoryStatus.loading));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('1.750,50€'), findsNothing);
    });
  });
}
