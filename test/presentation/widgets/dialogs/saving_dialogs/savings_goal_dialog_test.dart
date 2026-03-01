import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_goal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockSavingsCubit extends Mock implements SavingsCubit {}

void main() {
  late MockSavingsCubit mockSavingsCubit;

  setUp(() {
    mockSavingsCubit = MockSavingsCubit();

    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState());
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.close()).thenAnswer((_) async => {});
    when(() => mockSavingsCubit.setGoal(any())).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    // Simulamos la estructura real de la app: una pantalla que abre el diálogo
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BlocProvider<SavingsCubit>.value(
                    value: mockSavingsCubit,
                    child: const SavingsGoalDialog(),
                  ),
                ),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('SavingsGoalDialog - Pruebas de Establecer Meta', () {
    testWidgets('Debe permitir escribir y guardar la meta correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // 1. Abrimos el diálogo
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // 2. Verificamos que el diálogo está ahí
      expect(find.text('ESTABLECER META'), findsOneWidget);

      // 3. Escribimos la meta
      final amountField = find.byType(TextField);
      await tester.enterText(amountField, '1000');
      await tester.pump(); 

      // 4. Pulsamos GUARDAR
      final saveButtonFinder = find.text('GUARDAR');
      await tester.tap(saveButtonFinder);
      
      // 5. Esperamos a que se cierre el diálogo (esto ya no fallará)
      await tester.pumpAndSettle();

      // 6. Verificamos que se llamó a la lógica
      verify(() => mockSavingsCubit.setGoal(1000.0)).called(1);
      
      // 7. Confirmamos que el diálogo se ha cerrado y volvemos a ver el botón OPEN
      expect(find.text('ESTABLECER META'), findsNothing);
      expect(find.text('OPEN'), findsOneWidget);
    });
  });
}
