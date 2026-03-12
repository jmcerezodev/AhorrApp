import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/debts_loans_screen/debt_loan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockDebtsLoansCubit mockCubit;

  setUp(() {
    mockCubit = MockDebtsLoansCubit();
  });

  Widget createWidgetUnderTest(DebtLoan item) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<DebtsLoansCubit>.value(
          value: mockCubit,
          child: DebtLoanCard(
            item: item,
            isDark: false,
            colorScheme: const ColorScheme.light(),
          ),
        ),
      ),
    );
  }

  group('DebtLoanCard Widget Tests -', () {
    testWidgets('Debe mostrar el botón de pago si NO es a plazos', (WidgetTester tester) async {
      final item = DebtLoan(
        id: '1', userId: 'u', name: 'Test', person: 'P', 
        totalAmount: 100, type: DebtLoanType.debt, isInstallment: false
      );

      await tester.pumpWidget(createWidgetUnderTest(item));
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('Debe ocultar el botón de pago si ES a plazos', (WidgetTester tester) async {
      final item = DebtLoan(
        id: '1', userId: 'u', name: 'Test', person: 'P', 
        totalAmount: 100, type: DebtLoanType.debt, isInstallment: true
      );

      await tester.pumpWidget(createWidgetUnderTest(item));
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsNothing);
    });

    testWidgets('Debe mostrar "Finalizado" si el importe pendiente es 0', (WidgetTester tester) async {
      final item = DebtLoan(
        id: '1', userId: 'u', name: 'Test', person: 'P', 
        totalAmount: 100, paidAmount: 100, type: DebtLoanType.debt, isCompleted: true
      );

      await tester.pumpWidget(createWidgetUnderTest(item));
      expect(find.text('Finalizado'), findsOneWidget);
    });

    testWidgets('Debe mostrar el progreso de cuotas si es a plazos', (WidgetTester tester) async {
      final item = DebtLoan(
        id: '1', userId: 'u', name: 'Test', person: 'P', 
        totalAmount: 100, paidAmount: 20, type: DebtLoanType.debt, 
        isInstallment: true, installmentAmount: 10, totalInstallments: 10
      );

      await tester.pumpWidget(createWidgetUnderTest(item));
      expect(find.text('Cuota 2 de 10'), findsOneWidget);
    });
  });
}
