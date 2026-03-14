import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/info_global_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}
class MockSavingsCubit extends Mock implements SavingsCubit {}

void main() {
  late MockHistoryCubit mockHistoryCubit;
  late MockTotalMoneyCubit mockTotalMoneyCubit;
  late MockSavingsCubit mockSavingsCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockHistoryCubit = MockHistoryCubit();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    mockSavingsCubit = MockSavingsCubit();
    mockThemeCubit = MockThemeCubit();

    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(status: HistoryStatus.success, isSyncing: false));
    when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState(totalMoney: 1250.50, isSavingsIncluded: true));
    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState(savingTotal: 500, savingGoal: 1000));

    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTotalMoneyCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
            BlocProvider<TotalMoneyCubit>.value(value: mockTotalMoneyCubit),
            BlocProvider<SavingsCubit>.value(value: mockSavingsCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const InfoGlogalWidget(),
        ),
      ),
    );
  }

  group('InfoGlogalWidget - Protección de Diseño y Datos', () {
    testWidgets('Debe mostrar el indicador de carga cuando el historial se está sincronizando', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(status: HistoryStatus.loading, isSyncing: true));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Debe mostrar el título fijo y el balance total correctamente', (WidgetTester tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('BALANCE DE CUENTA'), findsOneWidget);
      expect(find.text('AHORROS SUMADOS'), findsOneWidget);
      // 1250.5 + 500 = 1750.5 -> "1.750,5€" con el nuevo formato
      expect(find.text('1.750,5€'), findsOneWidget);
    });

    testWidgets('Debe mostrar solo el balance de cartera si la opción está desactivada', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockTotalMoneyCubit.state).thenReturn(const TotalMoneyCubitState(totalMoney: 1250.50, isSavingsIncluded: false));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('BALANCE DE CUENTA'), findsOneWidget);
      expect(find.text('SOLO CARTERA'), findsOneWidget);
      // 1250.5 -> "1.250,5€"
      expect(find.text('1.250,5€'), findsOneWidget);
    });

    testWidgets('Debe mostrar la sección de ahorros y la meta sin decimales innecesarios', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('AHORROS'), findsOneWidget);
      expect(find.text('500€'), findsOneWidget);
      expect(find.text('Meta: 1.000€'), findsOneWidget);
    });

    group('Interacciones', () {
      testWidgets('Debe llamar a toggleSavingsInclusion al pulsar el chip de modo', (WidgetTester tester) async {
        setupScreenSize(tester);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final modeChip = find.text('AHORROS SUMADOS');
        await tester.tap(modeChip);
        await tester.pump();

        verify(() => mockTotalMoneyCubit.toggleSavingsInclusion()).called(1);
      });
    });
  });
}
