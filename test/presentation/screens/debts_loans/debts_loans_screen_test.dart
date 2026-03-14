import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/screens/debts_loans_screen.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/empty_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  late MockDebtsLoansCubit mockCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockCubit = MockDebtsLoansCubit();
    mockThemeCubit = MockThemeCubit();
    
    when(() => mockCubit.loadDebtsLoans()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DebtsLoansCubit>.value(value: mockCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: DebtsLoansScreen(),
        ),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DebtsLoansScreen - Widget Tests', () {
    testWidgets('Debe mostrar EmptyListWidget si no hay datos', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockCubit.state).thenReturn(const DebtsLoansState(debtsLoans: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyListWidget), findsOneWidget);
      expect(find.text('No tienes deudas pendientes.\n¡Estás al día con tus pagos!'), findsOneWidget);
      
      await tester.tap(find.text('PRÉSTAMOS'));
      await tester.pumpAndSettle();
      expect(find.byType(EmptyListWidget), findsOneWidget);
      expect(find.text('No has realizado préstamos.\nNo te debe dinero nadie.'), findsOneWidget);
    });

    testWidgets('Debe mostrar deudas en la pestaña correspondiente', (WidgetTester tester) async {
      setupScreenSize(tester);
      final debts = [
        DebtLoan(id: '1', userId: 'u', name: 'Coche', person: 'Banco', totalAmount: 100, type: DebtLoanType.debt)
      ];
      when(() => mockCubit.state).thenReturn(DebtsLoansState(debtsLoans: debts));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Coche'), findsOneWidget);
      // Ajuste si se busca texto de moneda específico en el futuro
    });

    testWidgets('Debe abrir el diálogo de añadir al pulsar la burbuja de resumen', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockCubit.state).thenReturn(const DebtsLoansState(debtsLoans: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('NUEVA DEUDA'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditDebtLoanDialog), findsOneWidget);
    });
  });
}
