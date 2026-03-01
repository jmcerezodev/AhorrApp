import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/calendar_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDateCubit extends Mock implements DateCubit {}
class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  late MockDateCubit mockDateCubit;
  late MockLocalDbService mockLocalDb;

  setUpAll(() {
    mockLocalDb = MockLocalDbService();
    getIt.allowReassignment = true;
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
  });

  setUp(() {
    mockDateCubit = MockDateCubit();

    // Stubs de la DB
    when(() => mockLocalDb.getMinYear()).thenAnswer((_) async => 2010);
    when(() => mockLocalDb.getYearlyActivity(any())).thenAnswer((_) async => []);

    // ESTADO INICIAL SEGURO: Usamos 2020 para que ningún mes sea "futuro"
    when(() => mockDateCubit.state).thenReturn(
      const DateCubitState(month: 'Enero', year: 2020, isOpen: true)
    );
    when(() => mockDateCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDateCubit.close()).thenAnswer((_) async => {});
    when(() => mockDateCubit.month(any())).thenReturn(null);
    when(() => mockDateCubit.isOpen(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<DateCubit>.value(
          value: mockDateCubit,
          child: const CalendarPanelWidget(),
        ),
      ),
    );
  }

  group('CalendarPanelWidget - Pruebas de Navegación Mensual', () {
    testWidgets('Debe mostrar las abreviaturas de los meses', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ene'), findsOneWidget);
      expect(find.text('Dic'), findsOneWidget);
    });

    testWidgets('Al pulsar un mes, debe cambiar la fecha y cerrar el panel', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Buscamos 'Abr' (Abril). Ahora está habilitado porque el año es 2020.
      final abrMonth = find.text('Abr');
      await tester.tap(abrMonth);
      await tester.pumpAndSettle();

      // Verificamos que se llamó a cambiar el mes a 'Abril'
      verify(() => mockDateCubit.month('Abril')).called(1);
      // Verificamos que se cerró el panel
      verify(() => mockDateCubit.isOpen(false)).called(1);
    });
  });
}
