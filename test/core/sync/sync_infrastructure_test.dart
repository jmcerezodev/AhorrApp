import 'dart:convert';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart' as isar;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/appwrite.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockAuthAppwrite extends Mock implements AuthAppwrite {}
class MockIsar extends Mock implements isar.Isar {}

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
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true, 
      'email': 'test@test.com', 
      'password': '123'
    });
    await Preferences.init();

    mockLocalDb = MockLocalDbService();
    mockAppwriteRepo = MockAppwriteRepository();
    mockConnectivity = MockConnectivityService();
    mockAuth = MockAuthAppwrite();

    getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<AppwriteRepository>(mockAppwriteRepo);
    getIt.registerSingleton<ConnectivityService>(mockConnectivity);
    getIt.registerSingleton<AuthAppwrite>(mockAuth);

    when(() => mockConnectivity.status).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
    when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => []);
  });

  group('SyncService - Infraestructura de Sincronización', () {
    
    test('forceSync debe resetear estados y emitir success si no hay pendientes', () async {
      final syncService = SyncService();
      final states = <SyncStatus>[];
      syncService.syncStatusNotifier.addListener(() {
        states.add(syncService.syncStatusNotifier.value);
      });

      await syncService.forceSync();

      // Debería pasar por syncing y terminar en success
      expect(states, contains(SyncStatus.syncing));
      expect(states.last, SyncStatus.success);
    });

    test('Exponential Backoff debe activar el estado de error ante fallos de red', () async {
      final syncService = SyncService();
      // El appwriteId es obligatorio en la lógica de syncHistory/addHistory, si es null rompe antes del catch
      final pending = PendingSync()
        ..id = 1
        ..appwriteId = 'test-id'
        ..action = 'create'
        ..collection = 'history'
        ..dataJson = jsonEncode({'name': 'test'});

      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => [pending]);
      
      // Simular fallo de red
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
      )).thenThrow(AppwriteException('Network Error', 500));

      // Primer fallo: En sincronización manual para asegurar que el notifier se actualice
      await syncService.processQueue(isManual: true);

      expect(syncStatusNotifierValue(syncService), SyncStatus.error);
    });

    test('Sincronización automática debe ser ignorada si no hay conexión', () async {
      when(() => mockConnectivity.isConnected).thenAnswer((_) async => false);
      final syncService = SyncService();
      
      await syncService.processQueue(isManual: false);
      
      expect(syncService.syncStatusNotifier.value, SyncStatus.idle);
      verifyNever(() => mockLocalDb.getPendingSyncs());
    });
  });
}

SyncStatus syncStatusNotifierValue(SyncService service) => service.syncStatusNotifier.value;
