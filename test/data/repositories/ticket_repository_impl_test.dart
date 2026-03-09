import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/datasources/local/tickets_local_datasource.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
import 'package:ahorrapp/data/repositories/ticket_repository_impl.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketsLocalDataSource extends Mock implements TicketsLocalDataSource {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  late TicketsRepositoryImpl repository;
  late MockTicketsLocalDataSource mockDataSource;
  late MockLocalDbService mockLocalDb;
  late MockSyncService mockSyncService;

  setUpAll(() {
    registerFallbackValue(LocalTicketItem());
  });

  setUp(() {
    mockDataSource = MockTicketsLocalDataSource();
    mockLocalDb = MockLocalDbService();
    mockSyncService = MockSyncService();

    getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<SyncService>(mockSyncService);

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

    test('unmarkAsTransferred calls data source and adds to sync queue', () async {
      when(() => mockDataSource.updateTransferredStatus(any(), any())).thenAnswer((_) async => {});
      when(() => mockDataSource.getTicketItemById(any())).thenAnswer((_) async => tLocalItems[0]);
      when(() => mockLocalDb.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
          .thenAnswer((_) async => {});
      when(() => mockSyncService.processQueue()).thenAnswer((_) async => {});

      await repository.unmarkAsTransferred('1');
      
      verify(() => mockDataSource.updateTransferredStatus('1', false)).called(1);
      verify(() => mockLocalDb.addPendingSync('save', 'tickets', any(), appwriteId: '1')).called(1);
      verify(() => mockSyncService.processQueue()).called(1);
    });

    test('saveTicketItem calls dataSource and adds to sync queue', () async {
      when(() => mockDataSource.saveTicketItem(any())).thenAnswer((_) async => {});
      // Añadido mock para getTicketItemById que ahora se llama internamente en saveTicketItem
      when(() => mockDataSource.getTicketItemById(any())).thenAnswer((_) async => tLocalItems[0]);
      when(() => mockLocalDb.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
          .thenAnswer((_) async => {});
      when(() => mockSyncService.processQueue()).thenAnswer((_) async => {});

      await repository.saveTicketItem(tEntities[0]);
      
      verify(() => mockDataSource.saveTicketItem(any(that: isA<LocalTicketItem>()))).called(1);
      verify(() => mockDataSource.getTicketItemById('1')).called(1);
      verify(() => mockLocalDb.addPendingSync('save', 'tickets', any(), appwriteId: '1')).called(1);
      verify(() => mockSyncService.processQueue()).called(1);
    });

    test('deleteTicketItem calls dataSource and adds to sync queue', () async {
      when(() => mockDataSource.getTicketItemById(any())).thenAnswer((_) async => tLocalItems[0]);
      when(() => mockDataSource.deleteTicketItem(any())).thenAnswer((_) async => {});
      when(() => mockLocalDb.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
          .thenAnswer((_) async => {});
      when(() => mockSyncService.processQueue()).thenAnswer((_) async => {});

      await repository.deleteTicketItem('1');
      
      verify(() => mockDataSource.deleteTicketItem('1')).called(1);
      verify(() => mockLocalDb.addPendingSync('delete', 'tickets', any(), appwriteId: '1')).called(1);
      verify(() => mockSyncService.processQueue()).called(1);
    });
  });
}
