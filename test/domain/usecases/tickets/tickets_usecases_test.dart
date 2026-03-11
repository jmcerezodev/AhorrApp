import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/domain/usecases/tickets/clear_tickets_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/save_ticket_item_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketsRepository extends Mock implements TicketsRepository {}
class TicketItemFake extends Fake implements TicketItem {}

void main() {
  late MockTicketsRepository mockRepo;
  late SaveTicketItemUseCase saveUseCase;
  late ClearTicketsUseCase clearUseCase;

  setUpAll(() {
    registerFallbackValue(TicketItemFake());
  });

  setUp(() {
    mockRepo = MockTicketsRepository();
    saveUseCase = SaveTicketItemUseCase(mockRepo);
    clearUseCase = ClearTicketsUseCase(mockRepo);
  });

  group('Tickets UseCases - Domain Coverage', () {
    final tItem = TicketItem(
      id: '1',
      userId: 'u1',
      name: 'Ticket',
      amount: 10.0,
      date: DateTime.now(),
      category: 'general',
    );

    test('SaveTicketItemUseCase debe llamar al repositorio', () async {
      when(() => mockRepo.saveTicketItem(any())).thenAnswer((_) async => {});

      await saveUseCase(tItem);

      verify(() => mockRepo.saveTicketItem(tItem)).called(1);
    });

    test('ClearTicketsUseCase debe llamar al repositorio con el userId', () async {
      when(() => mockRepo.clearTicketItems(any())).thenAnswer((_) async => {});

      await clearUseCase('u1');

      verify(() => mockRepo.clearTicketItems('u1')).called(1);
    });
  });
}
