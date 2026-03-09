import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockTicketsRepository extends Mock implements TicketsRepository {}

void main() {
  late TransferTicketsToExpensesUseCase useCase;
  late MockSaveMovementUseCase mockSaveMovement;
  late MockTicketsRepository mockTicketsRepository;

  setUpAll(() {
    registerFallbackValue(Movement(
      id: '', name: '', amount: 0, type: MovementType.expense, 
      isIncome: false, date: '', hour: '', month: '', year: 2024, 
      createdAt: DateTime.now()
    ));
  });

  setUp(() {
    mockSaveMovement = MockSaveMovementUseCase();
    mockTicketsRepository = MockTicketsRepository();
    useCase = TransferTicketsToExpensesUseCase(
      saveMovementUseCase: mockSaveMovement,
      ticketsRepository: mockTicketsRepository,
    );
  });

  final tDate = DateTime(2023, 1, 1);
  final tItems = [
    TicketItem(id: '1', userId: 'u1', name: 'Mercadona', amount: 15.5, date: tDate, category: 'alimentación'),
    TicketItem(id: '2', userId: 'u1', name: 'Zara', amount: 45.0, date: tDate, category: 'ocio'),
  ];

  test('should call saveMovementUseCase as a single pack and not clear tickets', () async {
    when(() => mockTicketsRepository.getTicketItemById(any())).thenAnswer((_) async => tItems.first);
    when(() => mockSaveMovement.call(any())).thenAnswer((_) async => {});

    await useCase.call(userId: 'u1', items: tItems, asPack: true, packName: 'Gasto total tickets');

    verify(() => mockSaveMovement.call(any(that: isA<Movement>()))).called(1);
    verify(() => mockTicketsRepository.getTicketItemById(tItems.first.id)).called(1);
  });

  test('should call saveMovementUseCase for each ticket and not clear tickets', () async {
    when(() => mockTicketsRepository.getTicketItemById('1')).thenAnswer((_) async => tItems[0]);
    when(() => mockTicketsRepository.getTicketItemById('2')).thenAnswer((_) async => tItems[1]);
    when(() => mockSaveMovement.call(any())).thenAnswer((_) async => {});

    await useCase.call(userId: 'u1', items: tItems, asPack: false);

    verify(() => mockSaveMovement.call(any(that: isA<Movement>()))).called(2);
    verify(() => mockTicketsRepository.getTicketItemById('1')).called(1);
    verify(() => mockTicketsRepository.getTicketItemById('2')).called(1);
  });
}
