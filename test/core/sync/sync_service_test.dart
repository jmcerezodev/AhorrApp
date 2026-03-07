import 'dart:convert';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockAuthAppwrite extends Mock implements AuthAppwrite {}
class MockDocument extends Mock implements models.Document {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocalDbService mockLocalDb;
  late MockAppwriteRepository mockAppwriteRepo;
  late MockConnectivityService mockConnectivity;
  late MockAuthAppwrite mockAuth;

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

    // Resetear GetIt y registrar mocks
    getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<AppwriteRepository>(mockAppwriteRepo);
    getIt.registerSingleton<ConnectivityService>(mockConnectivity);
    getIt.registerLazySingleton<AuthAppwrite>(() => mockAuth);

    // Stubs comunes
    when(() => mockConnectivity.status).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
    when(() => mockLocalDb.deletePendingSync(any())).thenAnswer((_) async => {});
  });

  group('SyncService - Lógica de Sincronización', () {
    test('Debe intentar Silent Login ante un error 401 de Appwrite', () async {
      final syncService = SyncService();
      
      final pending = PendingSync()
        ..id = 1
        ..action = 'create'
        ..collection = 'history'
        ..appwriteId = 'item-123'
        ..dataJson = jsonEncode({'userId': 'u1', 'name': 'Gasto', 'money': 10.0, 'date': '2024-01-01'});

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
      )).thenThrow(AppwriteException('Unauthorized', 401));

      when(() => mockAuth.signInEmailAndPassword(any(), any())).thenAnswer((_) async => 'new-session');

      await syncService.processQueue();

      verify(() => mockAuth.signInEmailAndPassword('test@test.com', '123')).called(1);
    });

    test('Debe sincronizar correctamente items de la cesta (shopping_list)', () async {
      final syncService = SyncService();
      final data = {
        'userId': 'u1',
        'name': 'Leche',
        'amount': 1.5,
        'category': 'general',
        'isBought': false,
        'position': 0,
        'quantity': 2
      };
      
      final pending = PendingSync()
        ..id = 10
        ..action = 'save'
        ..collection = 'shopping_list'
        ..appwriteId = 'shop-123'
        ..dataJson = jsonEncode(data);

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      
      // Stub para update (simulamos éxito)
      when(() => mockAppwriteRepo.updateShoppingItem(
        documentId: 'shop-123',
        data: any(named: 'data'),
      )).thenAnswer((_) async => MockDocument());

      await syncService.processQueue();

      // Verificamos que se intentó actualizar con los datos correctos
      final capturedData = verify(() => mockAppwriteRepo.updateShoppingItem(
        documentId: 'shop-123',
        data: captureAny(named: 'data'),
      )).captured.first as Map<String, dynamic>;

      expect(capturedData['quantity'], 2);
      expect(capturedData['name'], 'Leche');
      
      // Verificamos que se eliminó de la cola local al terminar con éxito
      verify(() => mockLocalDb.deletePendingSync(10)).called(1);
    });

    test('Debe crear el item de la cesta si update falla con 404', () async {
      final syncService = SyncService();
      final pending = PendingSync()
        ..id = 11
        ..action = 'save'
        ..collection = 'shopping_list'
        ..appwriteId = 'shop-new'
        ..dataJson = jsonEncode({'userId': 'u1', 'name': 'Pan', 'quantity': 1, 'amount': 0.0, 'category': 'general', 'isBought': false, 'position': 1});

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      
      // Update falla con 404 (No encontrado)
      when(() => mockAppwriteRepo.updateShoppingItem(
        documentId: 'shop-new',
        data: any(named: 'data'),
      )).thenThrow(AppwriteException('Not Found', 404));

      // Entonces debe intentar addShoppingItem
      when(() => mockAppwriteRepo.addShoppingItem(
        documentId: 'shop-new',
        userId: any(named: 'userId'),
        name: any(named: 'name'),
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        isBought: any(named: 'isBought'),
        position: any(named: 'position'),
        quantity: any(named: 'quantity'),
      )).thenAnswer((_) async => MockDocument());

      await syncService.processQueue();

      verify(() => mockAppwriteRepo.addShoppingItem(
        documentId: 'shop-new',
        userId: 'u1',
        name: 'Pan',
        amount: 0.0,
        category: 'general',
        isBought: false,
        position: 1,
        quantity: 1,
      )).called(1);
    });
   group('SyncService - Mapeo de Historial', () {
    test('Debe mapear correctamente date a currentDate si currentDate falta', () async {
      final syncService = SyncService();
      final pending = PendingSync()
        ..id = 1
        ..action = 'create'
        ..collection = 'history'
        ..appwriteId = 'item-123'
        ..dataJson = jsonEncode({
          'userId': 'u1', 
          'name': 'Gasto', 
          'money': 10.0, 
          'date': '2024-05-20',
          'hour': '15:30',
          'month': 'May',
          'year': 2024
        });

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
        category: any(named: 'category'),
      )).thenAnswer((_) async => MockDocument());

      await syncService.processQueue();

      // Verificamos que se llamó con el mapeo correcto
      verify(() => mockAppwriteRepo.addHistory(
        documentId: 'item-123',
        userId: 'u1',
        name: 'Gasto',
        money: 10.0,
        isIncome: false,
        currentDate: '2024-05-20',
        currentHour: '15:30',
        month: 'May',
        year: 2024,
        category: any(named: 'category'),
      )).called(1);
    });
  });
  });
}
