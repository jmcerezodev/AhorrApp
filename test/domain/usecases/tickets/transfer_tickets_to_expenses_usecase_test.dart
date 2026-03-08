import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/clear_tickets_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockClearTicketsUseCase extends Mock implements ClearTicketsUseCase {}

void main() {
  late TransferTicketsToExpensesUseCase useCase;
  late MockSaveMovementUseCase mockSaveMovement;
  late MockClearTicketsUseCase mockClearTickets;

  setUpAll(() {
    registerFallbackValue(Movement(
      id: '', name: '', amount: 0, type: MovementType.expense, 
      isIncome: false, date: '', hour: '', month: '', year: 2024, 
      createdAt: DateTime.now()
    ));
  });

  setUp(() {
    mockSaveMovement = MockSaveMovementUseCase();
    mockClearTickets = MockClearTicketsUseCase();
    useCase = TransferTicketsToExpensesUseCase(
      saveMovementUseCase: mockSaveMovement,
      clearTicketsUseCase: mockClearTickets,
    );
  });

  final tDate = DateTime(2023, 1, 1);
  final tItems = [
    TicketItem(id: '1', userId: 'u1', name: 'Mercadona', amount: 15.5, date: tDate, category: 'alimentación'),
    TicketItem(id: '2', userId: 'u1', name: 'Zara', amount: 45.0, date: tDate, category: 'ocio'),
  ];

  test('should call saveMovementUseCase as a single pack and clear tickets', () async {
    when(() => mockSaveMovement.call(any())).thenAnswer((_) async => {});
    when(() => mockClearTickets.call(any())).thenAnswer((_) async => {});

    await useCase.call(userId: 'u1', items: tItems, asPack: true, packName: 'Gasto total tickets');

    verify(() => mockSaveMovement.call(any(that: isA<Movement>()))).called(1);
    verify(() => mockClearTickets.call('u1')).called(1);
  });

  test('should call saveMovementUseCase for each ticket and clear tickets', () async {
    when(() => mockSaveMovement.call(any())).thenAnswer((_) async => {});
    when(() => mockClearTickets.call(any())).thenAnswer((_) async => {});

    await useCase.call(userId: 'u1', items: tItems, asPack: false);

    verify(() => mockSaveMovement.call(any(that: isA<Movement>()))).called(2);
    verify(() => mockClearTickets.call('u1')).called(1);
  });
}
