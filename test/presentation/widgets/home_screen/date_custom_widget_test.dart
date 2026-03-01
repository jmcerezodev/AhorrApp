import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/home_screen/date_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDateCubit extends Mock implements DateCubit {}

void main() {
  late MockDateCubit mockDateCubit;

  setUp(() {
    mockDateCubit = MockDateCubit();

    // Estado inicial: Enero 2024, cerrado
    when(() => mockDateCubit.state).thenReturn(
      const DateCubitState(month: 'Enero', year: 2024, isOpen: false)
    );
    when(() => mockDateCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDateCubit.close()).thenAnswer((_) async => {});
    
    // Stub para la función que abre/cierra
    when(() => mockDateCubit.isOpen(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<DateCubit>.value(
          value: mockDateCubit,
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: DateCustomWidget(),
          ),
        ),
      ),
    );
  }

  group('DateCustomWidget - Pruebas de Selector de Fecha', () {
    testWidgets('Debe mostrar el mes y año correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Enero 2024'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    });

    testWidgets('Al pulsar, debe llamar a isOpen para abrir el calendario', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Pulsamos el widget
      await tester.tap(find.byType(DateCustomWidget));
      await tester.pump();

      // Verificamos que se intentó abrir (pasando true a isOpen)
      verify(() => mockDateCubit.isOpen(true)).called(1);
    });

    testWidgets('Debe mostrar la flecha hacia arriba cuando está abierto', (WidgetTester tester) async {
      // Cambiamos el estado a abierto
      when(() => mockDateCubit.state).thenReturn(
        const DateCubitState(month: 'Enero', year: 2024, isOpen: true)
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    });
  });
}
