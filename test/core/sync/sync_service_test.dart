import 'dart:convert';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart' as isar;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockAuthAppwrite extends Mock implements AuthAppwrite {}
class MockDebtLoanRepository extends Mock implements DebtLoanRepository {}
class MockDocument extends Mock implements models.Document {}
class MockIsar extends Mock implements isar.Isar {}
class MockLocalTicketItemCollection extends Mock implements isar.IsarCollection<LocalTicketItem> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocalDbService mockLocalDb;
  late MockAppwriteRepository mockAppwriteRepo;
  late MockConnectivityService mockConnectivity;
  late MockAuthAppwrite mockAuth;
  late MockDebtLoanRepository mockDebtRemoteRepo;
  late MockIsar mockIsar;
  late MockLocalTicketItemCollection mockTicketCollection;

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': true, 'email': 'test@test.com', 'password': '123'});
    await Preferences.init();

    mockLocalDb = MockLocalDbService();
    mockAppwriteRepo = MockAppwriteRepository();
    mockConnectivity = MockConnectivityService();
    mockAuth = MockAuthAppwrite();
    mockDebtRemoteRepo = MockDebtLoanRepository();
    mockIsar = MockIsar();
    mockTicketCollection = MockLocalTicketItemCollection();

    getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<AppwriteRepository>(mockAppwriteRepo);
    getIt.registerSingleton<ConnectivityService>(mockConnectivity);
    getIt.registerSingleton<AuthAppwrite>(mockAuth);
    getIt.registerLazySingleton<DebtLoanRepository>(() => mockDebtRemoteRepo, instanceName: 'debt_remote');

    when(() => mockConnectivity.status).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
    when(() => mockLocalDb.deletePendingSync(any())).thenAnswer((_) async => {});
    when(() => mockLocalDb.isar).thenReturn(mockIsar);
    when(() => mockIsar.localTicketItems).thenReturn(mockTicketCollection);
  });

  group('SyncService - Suite Completa de Sincronización', () {
    test('Debe intentar Silent Login ante un error 401 de Appwrite (Recuperado)', () async {
      final syncService = SyncService();
      final pending = PendingSync()
        ..id = 1
        ..action = 'create'
        ..collection = 'history'
        ..appwriteId = 'item-123'
        ..dataJson = jsonEncode({'userId': 'u1', 'name': 'Gasto'});

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      when(() => mockAppwriteRepo.addHistory(
        documentId: any(named: 'documentId'),
        userId: any(named: 'userId'),
        name: any(named: 'name'),
        money: any(named: 'money'),
        isIncome: any(named: 'isIncome'),
        currentDate: any(named: 'currentDate'),
        currentHour: any(named: 'currentHour'),
        month: any(named: 'month'),
        year: any(named: 'year'),
        isRecurrent: any(named: 'isRecurrent'),
        category: any(named: 'category'),
      )).thenThrow(AppwriteException('Unauthorized', 401));

      when(() => mockAuth.signInEmailAndPassword(any(), any())).thenAnswer((_) async => 'new-session');

      await syncService.processQueue();

      verify(() => mockAuth.signInEmailAndPassword('test@test.com', '123')).called(1);
    });

    test('Debe sincronizar correctamente la actualización del nombre de usuario (Offline support)', () async {
      final syncService = SyncService();
      final pending = PendingSync()..id = 20..action = 'update_name'..collection = 'user'..dataJson = jsonEncode({'name': 'Nuevo Nombre'});
      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      when(() => mockAuth.updateRemoteName('Nuevo Nombre')).thenAnswer((_) async => true);

      await syncService.processQueue();

      verify(() => mockAuth.updateRemoteName('Nuevo Nombre')).called(1);
      verify(() => mockLocalDb.deletePendingSync(20)).called(1);
    });

    test('Debe sincronizar items de la cesta y manejar reintento si falla update (Recuperado)', () async {
      final syncService = SyncService();
      final data = {'userId': 'u1', 'name': 'Leche', 'amount': 1.5, 'isBought': false, 'position': 0, 'quantity': 2, 'category': 'general'};
      final pending = PendingSync()..id = 10..action = 'save'..collection = 'shopping_list'..appwriteId = 'shop-123'..dataJson = jsonEncode(data);

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      
      // Simula que falla el update (404) y debe intentar el add
      when(() => mockAppwriteRepo.updateShoppingItem(documentId: 'shop-123', data: any(named: 'data'))).thenThrow(AppwriteException('Not Found', 404));
      when(() => mockAppwriteRepo.addShoppingItem(
        documentId: 'shop-123',
        userId: 'u1',
        name: 'Leche',
        amount: 1.5,
        category: 'general',
        isBought: false,
        position: 0,
        quantity: 2,
      )).thenAnswer((_) async => MockDocument());

      await syncService.processQueue();

      verify(() => mockAppwriteRepo.addShoppingItem(documentId: 'shop-123', userId: 'u1', name: 'Leche', amount: 1.5, category: 'general', isBought: false, position: 0, quantity: 2)).called(1);
      verify(() => mockLocalDb.deletePendingSync(10)).called(1);
    });

    test('Debe mapear correctamente date/hour a currentDate/currentHour en historial (Recuperado)', () async {
      final syncService = SyncService();
      final pending = PendingSync()
        ..id = 5
        ..action = 'create'
        ..collection = 'history'
        ..appwriteId = 'h-5'
        ..dataJson = jsonEncode({
          'userId': 'u1',
          'name': 'Compra',
          'money': 25.0,
          'date': '2024-05-20',
          'hour': '15:30',
          'month': 'May',
          'year': 2024
        });

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      when(() => mockAppwriteRepo.addHistory(
        documentId: 'h-5',
        userId: 'u1',
        name: 'Compra',
        money: 25.0,
        isIncome: any(named: 'isIncome'),
        currentDate: '2024-05-20', // Mapeado desde 'date'
        currentHour: '15:30',      // Mapeado desde 'hour'
        month: 'May',
        year: 2024,
        isRecurrent: any(named: 'isRecurrent'),
        category: any(named: 'category'),
      )).thenAnswer((_) async => MockDocument());

      await syncService.processQueue();

      verify(() => mockAppwriteRepo.addHistory(
        documentId: 'h-5',
        userId: 'u1',
        name: 'Compra',
        money: 25.0,
        isIncome: any(named: 'isIncome'),
        currentDate: '2024-05-20',
        currentHour: '15:30',
        month: 'May',
        year: 2024,
        isRecurrent: any(named: 'isRecurrent'),
        category: any(named: 'category'),
      )).called(1);
    });
  });
}
