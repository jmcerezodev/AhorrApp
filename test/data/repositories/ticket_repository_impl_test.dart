import 'package:ahorrapp/data/datasources/local/tickets_local_datasource.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
import 'package:ahorrapp/data/repositories/ticket_repository_impl.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketsLocalDataSource extends Mock implements TicketsLocalDataSource {}

void main() {
  late TicketsRepositoryImpl repository;
  late MockTicketsLocalDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(LocalTicketItem());
  });

  setUp(() {
    mockDataSource = MockTicketsLocalDataSource();
    repository = TicketsRepositoryImpl(mockDataSource);
  });

  const tUserId = 'u1';
  final tLocalItems = [
    LocalTicketItem()
      ..ticketItemId = '1'
      ..userId = tUserId
      ..name = 'Product 1'
      ..amount = 10.0
      ..quantity = 1
      ..category = 'general'
      ..position = 0,
  ];

  final tEntities = [
    const TicketItem(id: '1', userId: tUserId, name: 'Product 1', amount: 10.0, quantity: 1, category: 'general', position: 0),
  ];

  group('TicketsRepositoryImpl', () {
    test('getTicketItems returns list of TicketItem entities', () async {
      when(() => mockDataSource.getTicketItems(tUserId)).thenAnswer((_) async => tLocalItems);
      final result = await repository.getTicketItems(tUserId);
      expect(result, tEntities);
      verify(() => mockDataSource.getTicketItems(tUserId)).called(1);
    });

    test('saveTicketItem calls dataSource with correct model', () async {
      when(() => mockDataSource.saveTicketItem(any())).thenAnswer((_) async => {});
      await repository.saveTicketItem(tEntities[0]);
      verify(() => mockDataSource.saveTicketItem(any(that: isA<LocalTicketItem>()))).called(1);
    });

    test('deleteTicketItem calls dataSource with correct id', () async {
      when(() => mockDataSource.deleteTicketItem(any())).thenAnswer((_) async => {});
      await repository.deleteTicketItem('1');
      verify(() => mockDataSource.deleteTicketItem('1')).called(1);
    });

    test('clearTicketItems calls dataSource with correct userId', () async {
      when(() => mockDataSource.clearTicketItems(any())).thenAnswer((_) async => {});
      await repository.clearTicketItems(tUserId);
      verify(() => mockDataSource.clearTicketItems(tUserId)).called(1);
    });
  });
}
