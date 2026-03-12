import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockDebtsLoansCubit mockCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
    mockCubit = MockDebtsLoansCubit();
    when(() => mockCubit.state).thenReturn(const DebtsLoansState());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<DebtsLoansCubit>.value(
          value: mockCubit,
          child: const AddEditDebtLoanDialog(initialType: DebtLoanType.debt),
        ),
      ),
    );
  }

  group('AddEditDebtLoanDialog - Procesamiento Inteligente de Números', () {
    testWidgets('Debe interpretar correctamente el punto como separador de miles (ej. 1.000)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el campo de importe (basado en el orden de los CustomInputTextWidget)
      final amountField = find.byType(TextField).at(2); 
      
      await tester.enterText(amountField, '1.000');
      await tester.pumpAndSettle();

      // Activamos el toggle de pago a plazos (CupertinoSwitch)
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      // Ponemos 10 meses (el campo aparece al activar el toggle)
      final monthsField = find.byType(TextField).at(3);
      await tester.enterText(monthsField, '10');
      await tester.pumpAndSettle();

      // 1000 / 10 = 100.00
      expect(find.text('100.00'), findsOneWidget);
    });

    testWidgets('Debe interpretar correctamente la coma como decimal (ej. 1000,50)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final amountField = find.byType(TextField).at(2);
      await tester.enterText(amountField, '1000,50');
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      final monthsField = find.byType(TextField).at(3);
      await tester.enterText(monthsField, '10');
      await tester.pumpAndSettle();

      // 1000.50 / 10 = 100.05
      expect(find.text('100.05'), findsOneWidget);
    });
  });
}
