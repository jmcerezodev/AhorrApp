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
    // Para que context.pop() funcione sin lanzar "There is nothing to pop",
    // necesitamos que el diálogo se abra SOBRE una ruta existente.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BlocProvider<SavingsCubit>.value(
                    value: mockSavingsCubit,
                    child: const SavingsGoalDialog(),
                  ),
                ),
                child: const Text('Open'),
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
      await tester.pumpAndSettle();

      // Abrimos el diálogo para que esté en el stack de navegación
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('ESTABLECER META'), findsOneWidget);

      final amountField = find.byType(TextField);
      await tester.enterText(amountField, '1000');
      await tester.pump(); 

      final saveButtonFinder = find.text('GUARDAR');
      await tester.tap(saveButtonFinder);
      
      // Ahora context.pop() cerrará el diálogo y volveremos a '/'
      await tester.pumpAndSettle();

      verify(() => mockSavingsCubit.setGoal(1000.0)).called(1);
      expect(find.text('ESTABLECER META'), findsNothing);
    });
  });
}
