import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_withdraw_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockSavingsCubit extends Mock implements SavingsCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}
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

    when(() => mockSavingsCubit.state).thenReturn(const SavingsCubitState(savingTotal: 150.0));
    when(() => mockSavingsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSavingsCubit.close()).thenAnswer((_) async => {});
    
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
    final router = GoRouter(
      initialLocation: '/dialog',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('Home'))),
        GoRoute(
          path: '/dialog',
          builder: (context, state) => Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<SavingsCubit>.value(value: mockSavingsCubit),
                BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
              ],
              child: const SavingsWithdrawDialog(),
            ),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('SavingsWithdrawDialog - Pruebas de Retirada de Fondos', () {
    testWidgets('Debe mostrar el título y el saldo disponible para retirar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('RETIRAR AHORRO'), findsOneWidget);
      expect(find.textContaining('150.00€'), findsOneWidget);
    });

    testWidgets('El botón RETIRAR debe estar deshabilitado si la cantidad es mayor al ahorro', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '200');
      await tester.pump();

      final withdrawButton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('RETIRAR'), matching: find.byType(ElevatedButton))
      );
      expect(withdrawButton.onPressed, isNull);
      
      // Limpieza de animaciones antes de terminar el test
      await tester.pumpAndSettle();
    });

    testWidgets('Debe permitir retirar una cantidad válida', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '50');
      await tester.pump();

      final withdrawButton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('RETIRAR'), matching: find.byType(ElevatedButton))
      );
      expect(withdrawButton.onPressed, isNotNull);
      
      await tester.pumpAndSettle();
    });
  });
}
