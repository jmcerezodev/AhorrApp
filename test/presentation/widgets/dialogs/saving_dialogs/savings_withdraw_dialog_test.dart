import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_withdraw_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSavingsCubit extends Mock implements SavingsCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}

// Fake para que mocktail sepa manejar el tipo HistoryCubit en las verificaciones
class FakeHistoryCubit extends Fake implements HistoryCubit {}

void main() {
  late MockSavingsCubit mockSavingsCubit;
  late MockHistoryCubit mockHistoryCubit;

  setUpAll(() {
    registerFallbackValue(FakeHistoryCubit());
  });

  setUp(() {
    mockSavingsCubit = MockSavingsCubit();
    mockHistoryCubit = MockHistoryCubit();

    // Simulamos que el usuario tiene 150€ ahorrados
    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState(savingTotal: 150.0));
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.close()).thenAnswer((_) async => {});
    
    // Mock del método addSaving para las retiradas
    when(() => mockSavingsCubit.addSaving(
      any(), 
      customAmount: any(named: 'customAmount'), 
      customName: any(named: 'customName')
    )).thenAnswer((_) async => {});

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
          child: const SavingsWithdrawDialog(),
        ),
      ),
    );
  }

  group('SavingsWithdrawDialog - Pruebas de Retirada de Fondos', () {
    testWidgets('Debe mostrar el título y el saldo disponible para retirar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('RETIRAR AHORRO'), findsOneWidget);
      // Verificamos que aparezcan los 150.00€ del mock
      expect(find.textContaining('150.00€'), findsOneWidget);
    });

    testWidgets('El botón RETIRAR debe estar deshabilitado si la cantidad es mayor al ahorro', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Intentamos retirar 200€ (teniendo solo 150€)
      final amountField = find.widgetWithText(TextField, 'Cantidad a retirar');
      await tester.enterText(amountField, '200');
      await tester.pump();

      // Buscamos el botón y verificamos que su onPressed sea null (deshabilitado)
      final withdrawButton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('RETIRAR'), matching: find.byType(ElevatedButton))
      );
      expect(withdrawButton.onPressed, isNull);
    });

    testWidgets('Debe permitir retirar una cantidad válida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Retiramos 50€ (válido)
      final amountField = find.widgetWithText(TextField, 'Cantidad a retirar');
      await tester.enterText(amountField, '50');
      await tester.pump();

      final withdrawButton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('RETIRAR'), matching: find.byType(ElevatedButton))
      );
      expect(withdrawButton.onPressed, isNotNull); // El botón debe estar activo
    });
  });
}
