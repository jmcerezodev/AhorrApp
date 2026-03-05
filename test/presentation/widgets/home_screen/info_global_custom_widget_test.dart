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
    testWidgets('Debe mostrar el título fijo y el balance total correctamente', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('BALANCE DE CUENTA'), findsOneWidget);
      expect(find.text('AHORROS SUMADOS'), findsOneWidget);
      expect(find.text('1.750,50€'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Debe mostrar solo el balance de cartera si la opción está desactivada', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState(totalMoney: 1250.50, isSavingsIncluded: false));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('BALANCE DE CUENTA'), findsOneWidget);
      expect(find.text('SOLO CARTERA'), findsOneWidget);
      expect(find.text('1.250,50€'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Debe mostrar la sección de ahorros y la meta', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // ACTUALIZADO: El texto cambió de "MIS AHORROS" a "AHORROS" para compactar
      expect(find.text('AHORROS'), findsOneWidget);
      expect(find.text('500€'), findsOneWidget);
      expect(find.text('Meta: 1.000€'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
