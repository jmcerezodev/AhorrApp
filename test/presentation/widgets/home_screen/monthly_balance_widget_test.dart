import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/monthly_balance_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockDateCubit extends Mock implements DateCubit {}

void main() {
  late MockHistoryCubit mockHistoryCubit;
  late MockDateCubit mockDateCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockHistoryCubit = MockHistoryCubit();
    mockDateCubit = MockDateCubit();
    mockThemeCubit = MockThemeCubit();

    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState());
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockDateCubit.state).thenReturn(const DateCubitState(month: 'Marzo', year: 2026));
    when(() => mockDateCubit.stream).thenAnswer((_) => const Stream.empty());

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
            BlocProvider<DateCubit>.value(value: mockDateCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const MonthlyBalanceWidget(),
        ),
      ),
    );
  }

  group('MonthlyBalanceWidget - Verificación de Cálculos y Colores', () {
    testWidgets('Debe mostrar balance positivo en VERDE', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
        historyList: [
          {'year': 2026, 'month': 'Marzo', 'money': 100.0, 'type': 'income'}
        ]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final balanceFinder = find.textContaining('100');
      expect(balanceFinder, findsOneWidget);
      
      final Text textWidget = tester.widget(balanceFinder);
      expect(textWidget.style?.color, Colors.green.shade700);
    });

    testWidgets('Debe mostrar balance negativo en ROJO', (WidgetTester tester) async {
      setupScreenSize(tester);
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
      setupScreenSize(tester);
      when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
        historyList: [
          {'year': 2026, 'month': 'Marzo', 'money': 100.0, 'type': 'income'},
          {'year': 2026, 'month': 'Abril', 'money': 500.0, 'type': 'income'},
        ]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.textContaining('100'), findsOneWidget);
      expect(find.textContaining('600'), findsNothing);
    });
  });
}
