import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/incomes_expenses_dialogs/incomes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIncomesCubit extends Mock implements IncomesCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}

void main() {
  late MockIncomesCubit mockIncomesCubit;
  late MockHistoryCubit mockHistoryCubit;

  setUp(() {
    mockIncomesCubit = MockIncomesCubit();
    mockHistoryCubit = MockHistoryCubit();

    // Estado inicial seguro para Incomes
    when(() => mockIncomesCubit.state).thenReturn(const IncomesCubitState());
    when(() => mockIncomesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockIncomesCubit.close()).thenAnswer((_) async => {});
    when(() => mockIncomesCubit.resetCubit()).thenReturn(null);
    when(() => mockIncomesCubit.incomeNameChanged(any())).thenReturn(null);
    when(() => mockIncomesCubit.incomeMoneyChanged(any())).thenReturn(null);

    // Estado inicial para History
    when(() => mockHistoryCubit.state).thenReturn(const HistoryCubitState());
    when(() => mockHistoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHistoryCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<IncomesCubit>.value(value: mockIncomesCubit),
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
          ],
          child: const IncomesDialog(),
        ),
      ),
    );
  }

  group('IncomesDialog - Pruebas de Formulario de Ingresos', () {
    testWidgets('Debe mostrar el título y los campos de entrada', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('NUEVO INGRESO'), findsOneWidget);
      expect(find.text('ORIGEN DEL INGRESO'), findsOneWidget);
      expect(find.text('IMPORTE'), findsOneWidget);
      expect(find.text('GUARDAR'), findsOneWidget);
    });

    testWidgets('Al escribir el origen, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Venta Wallapop');
      
      verify(() => mockIncomesCubit.incomeNameChanged('Venta Wallapop')).called(1);
    });

    testWidgets('Debe mostrar carga cuando se está guardando', (WidgetTester tester) async {
      when(() => mockIncomesCubit.state).thenReturn(
        const IncomesCubitState(status: IncomesStatus.posting)
      );

      await tester.pumpWidget(createWidgetUnderTest());
      // No usamos pumpAndSettle porque el CircularProgressIndicator anima infinitamente
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('GUARDAR'), findsNothing);
    });
  });
}
