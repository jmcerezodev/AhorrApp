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
  final tDate = DateTime(2023, 1, 1);
  final tLocalItems = [
    LocalTicketItem()
      ..ticketItemId = '1'
      ..userId = tUserId
      ..name = 'Establecimiento 1'
      ..amount = 10.0
      ..date = tDate
      ..category = 'general'
      ..position = 0
      ..isTransferred = true
      ..imagePath = 'path/to/image.jpg',
  ];

  final tEntities = [
    TicketItem(
      id: '1', 
      userId: tUserId, 
      name: 'Establecimiento 1', 
      amount: 10.0, 
      date: tDate, 
      category: 'general', 
      position: 0,
      isTransferred: true,
      imagePath: 'path/to/image.jpg',
    ),
  ];

  group('TicketsRepositoryImpl', () {
    test('getTicketItems returns list of TicketItem entities', () async {
      when(() => mockDataSource.getTicketItems(tUserId)).thenAnswer((_) async => tLocalItems);
      final result = await repository.getTicketItems(tUserId);
      expect(result, tEntities);
      verify(() => mockDataSource.getTicketItems(tUserId)).called(1);
    });

    test('getTicketItemById returns entity if found', () async {
      when(() => mockDataSource.getTicketItemById('1')).thenAnswer((_) async => tLocalItems[0]);
      final result = await repository.getTicketItemById('1');
      expect(result, tEntities[0]);
    });

    test('unmarkAsTransferred calls data source', () async {
      when(() => mockDataSource.updateTransferredStatus(any(), any())).thenAnswer((_) async => {});
      await repository.unmarkAsTransferred('1');
      verify(() => mockDataSource.updateTransferredStatus('1', false)).called(1);
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
  });
}
