import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSavingsCubit extends Mock implements SavingsCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}

void main() {
  late MockSavingsCubit mockSavingsCubit;
  late MockHistoryCubit mockHistoryCubit;

  setUp(() {
    mockSavingsCubit = MockSavingsCubit();
    mockHistoryCubit = MockHistoryCubit();

    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState());
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.close()).thenAnswer((_) async => {});
    when(() => mockSavingsCubit.resetCubit()).thenReturn(null);
    when(() => mockSavingsCubit.savingChanged(any())).thenReturn(null);

    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState());
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<SavingsCubit>.value(value: mockSavingsCubit),
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
          ],
          child: const SavingsDialog(),
        ),
      ),
    );
  }

  group('SavingsDialog - Pruebas de Gestión de Ahorros', () {
    testWidgets('Debe mostrar el título y los botones de acción', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Importante para las animaciones del Wrapper

      expect(find.text('GESTIÓN AHORROS'), findsOneWidget);
      expect(find.text('AHORRAR'), findsOneWidget);
      expect(find.text('RETIRAR DINERO'), findsOneWidget);
      expect(find.byIcon(Icons.delete_sweep_rounded), findsOneWidget);
    });

    testWidgets('Al escribir la cantidad, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextField);
      await tester.enterText(amountField, '50.25');
      
      verify(() => mockSavingsCubit.savingChanged('50.25')).called(1);
    });

    testWidgets('Debe mostrar carga cuando se está procesando', (WidgetTester tester) async {
      when(() => mockSavingsCubit.state).thenReturn(
        const SavingsCubitState(status: SavingsStatus.loading)
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500)); // Animación de entrada

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // El texto AHORRAR no desaparece ahora, se reemplaza por el cargador dentro del botón estandarizado
      expect(find.text('AHORRAR'), findsNothing);
    });

    testWidgets('Debe asegurar visibilidad antes de pulsar AHORRAR', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final saveBtn = find.text('AHORRAR');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();
    });
  });
}
