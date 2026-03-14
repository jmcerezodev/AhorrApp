import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/expenses_incomes_custom_widget.dart';
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

    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState(
      historyList: [
        {'money': 1000.0, 'type': 'income', 'month': 'Enero', 'year': 2024},
        {'money': 200.0, 'type': 'expense', 'month': 'Enero', 'year': 2024},
      ],
    ));
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockDateCubit.state).thenReturn(const DateCubitState(month: 'Enero', year: 2024));
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
          child: const ExpensesIncomesCustomWidget(),
        ),
      ),
    );
  }

  group('ExpensesIncomesCustomWidget - Pruebas Visuales', () {
    testWidgets('Debe mostrar los títulos de INGRESOS y GASTOS', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('INGRESOS'), findsOneWidget);
      expect(find.text('GASTOS'), findsOneWidget);
    });

    testWidgets('Debe mostrar los montos correctos calculados', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Formato limpio: 1000.0 -> 1.000 y 200.0 -> 200
      expect(find.textContaining('1.000'), findsOneWidget);
      expect(find.textContaining('200'), findsOneWidget);
    });

    testWidgets('Debe tener los iconos de flecha correctos', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });
  });
}
