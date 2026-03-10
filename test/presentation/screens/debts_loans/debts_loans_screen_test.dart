import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/screens/debts_loans_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockDebtsLoansCubit mockCubit;

  setUp(() {
    mockCubit = MockDebtsLoansCubit();
    when(() => mockCubit.loadDebtsLoans()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: BlocProvider<DebtsLoansCubit>.value(
          value: mockCubit,
          child: const DebtsLoansScreen(),
        ),
      ),
    );
  }

  group('DebtsLoansScreen - Widget Tests', () {
    testWidgets('Debe mostrar estados vacíos si no hay datos', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const DebtsLoansState(debtsLoans: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No tienes deudas pendientes'), findsOneWidget);
      
      // Cambiar a pestaña préstamos
      await tester.tap(find.text('PRÉSTAMOS'));
      await tester.pumpAndSettle();
      expect(find.text('No has realizado préstamos'), findsOneWidget);
    });

    testWidgets('Debe mostrar deudas en la pestaña correspondiente', (WidgetTester tester) async {
      final debts = [
        DebtLoan(id: '1', userId: 'u', name: 'Coche', person: 'Banco', totalAmount: 100, type: DebtLoanType.debt)
      ];
      when(() => mockCubit.state).thenReturn(DebtsLoansState(debtsLoans: debts));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Coche'), findsOneWidget);
      expect(find.text('Banco'), findsNothing); // Porque es un TextSpan con estilo rico
    });

    testWidgets('Debe abrir el diálogo de añadir al pulsar la burbuja de resumen', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const DebtsLoansState(debtsLoans: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('NUEVA DEUDA'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditDebtLoanDialog), findsOneWidget);
    });
  });
}
