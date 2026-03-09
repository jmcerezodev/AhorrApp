import 'dart:io';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/services/ticket_export_service.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:ahorrapp/presentation/bloc/date_cubit/date_cubit.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/ticket_export_dialog.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/ticket_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketsCubit extends Mock implements TicketsCubit {}
class MockHistoryCubit extends Mock implements HistoryCubit {}
class MockDateCubit extends Mock implements DateCubit {}
class MockTransferTicketsToExpensesUseCase extends Mock implements TransferTicketsToExpensesUseCase {}
class MockTicketExportService extends Mock implements TicketExportService {}

void main() {
  late TicketItem testItem;
  late MockTicketsCubit mockTicketsCubit;
  late MockHistoryCubit mockHistoryCubit;
  late MockDateCubit mockDateCubit;
  late MockTicketExportService mockExportService;

  setUpAll(() {
    registerFallbackValue(TicketItem(
      id: '', userId: '', name: '', amount: 0, category: '', date: DateTime.now()
    ));
  });

  setUp(() {
    getIt.reset();
    mockTicketsCubit = MockTicketsCubit();
    mockHistoryCubit = MockHistoryCubit();
    mockDateCubit = MockDateCubit();
    mockExportService = MockTicketExportService();

    getIt.registerSingleton<TransferTicketsToExpensesUseCase>(MockTransferTicketsToExpensesUseCase());
    getIt.registerSingleton<TicketExportService>(mockExportService);

    testItem = TicketItem(
      id: '1',
      userId: 'u1',
      name: 'Ticket Test',
      amount: 10.5,
      category: 'comida',
      date: DateTime.now(),
      imagePath: 'path/to/image.jpg',
    );

    when(() => mockDateCubit.state).thenReturn(const DateCubitState(month: 'enero', year: 2024));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<TicketsCubit>.value(value: mockTicketsCubit),
            BlocProvider<HistoryCubit>.value(value: mockHistoryCubit),
            BlocProvider<DateCubit>.value(value: mockDateCubit),
          ],
          child: TicketItemCard(
            item: testItem,
            humanizeNumbers: HumanizeNumbers(),
            colorScheme: const ColorScheme.light(),
            isDark: false,
          ),
        ),
      ),
    );
  }

  testWidgets('Al mantener pulsado el ticket debe aparecer TicketExportDialog', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final cardFinder = find.byType(GestureDetector).first;
    
    await tester.longPress(cardFinder);
    await tester.pumpAndSettle();

    // Verificamos que el diálogo está presente
    final dialogFinder = find.byType(TicketExportDialog);
    expect(dialogFinder, findsOneWidget);
    
    // Verificamos el texto dentro del diálogo para evitar ambigüedad con la tarjeta de fondo
    expect(find.descendant(of: dialogFinder, matching: find.text('EXPORTAR TICKET')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.text(testItem.name)), findsOneWidget);
  });
}
