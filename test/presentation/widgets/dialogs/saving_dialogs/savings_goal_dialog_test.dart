import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_goal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSavingsCubit extends Mock implements SavingsCubit {}

void main() {
  late MockSavingsCubit mockSavingsCubit;

  setUp(() {
    mockSavingsCubit = MockSavingsCubit();

    // Estado inicial
    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState());
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.close()).thenAnswer((_) async => {});
    
    // Stub para la acción de guardar meta
    when(() => mockSavingsCubit.setGoal(any())).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SavingsCubit>.value(
          value: mockSavingsCubit,
          child: const SavingsGoalDialog(),
        ),
      ),
    );
  }

  group('SavingsGoalDialog - Pruebas de Establecer Meta', () {
    testWidgets('Debe mostrar el título y el campo de entrada', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('ESTABLECER META'), findsOneWidget);
      expect(find.text('¿Cuál es tu objetivo de ahorro?'), findsOneWidget);
      expect(find.text('GUARDAR'), findsOneWidget);
    });

    testWidgets('El botón GUARDAR debe estar deshabilitado al inicio', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final saveButton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('GUARDAR'), matching: find.byType(ElevatedButton))
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Debe habilitar el botón y guardar al introducir un número válido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Escribimos "1000"
      final amountField = find.byType(TextField);
      await tester.enterText(amountField, '1000');
      await tester.pump();

      // Buscamos el botón de nuevo (ahora debería estar activo)
      final saveButton = find.ancestor(of: find.text('GUARDAR'), matching: find.byType(ElevatedButton));
      await tester.tap(saveButton);
      await tester.pump();

      // Verificamos que se llamó a setGoal con 1000.0
      verify(() => mockSavingsCubit.setGoal(1000.0)).called(1);
    });
  });
}
