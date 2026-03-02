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

  group('SyncService - Lógica Avanzada', () {
    test('Debe intentar Silent Login ante un error 401 de Appwrite', () async {
      final syncService = SyncService();
      
      final pending = PendingSync()
        ..id = 1
        ..action = 'create'
        ..collection = 'history'
        ..appwriteId = 'item-123'
        ..dataJson = jsonEncode({'userId': 'u1', 'name': 'Gasto', 'money': 10.0, 'date': '2024-01-01'});

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      
      // Stub para addHistory que lanza 401
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

      // Stub para el silent login exitoso
      when(() => mockAuth.signInEmailAndPassword(any(), any())).thenAnswer((_) async => 'new-session');

      // Ejecutamos la cola
      await syncService.processQueue();

      // Verificamos que se intentó el re-login
      verify(() => mockAuth.signInEmailAndPassword('test@test.com', '123')).called(1);
    });

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
      )).called(1);
    });
  });
}
