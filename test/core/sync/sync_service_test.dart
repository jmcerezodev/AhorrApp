import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocalDbService mockLocalDb;
  late MockAppwriteRepository mockAppwriteRepo;

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    const MethodChannel connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(connectivityChannel, (MethodCall methodCall) async => 'wifi');
  });

  setUp(() {
    mockLocalDb = MockLocalDbService();
    mockAppwriteRepo = MockAppwriteRepository();

    getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<AppwriteRepository>(mockAppwriteRepo);
  });

  group('SyncService - Estructura y Seguridad', () {
    test('Debe inicializar la escucha de conectividad sin crashear', () {
      final syncService = SyncService();
      
      when(() => mockLocalDb.getPendingSyncs()).thenAnswer((_) async => []);

      expect(() => syncService.init(), returnsNormally);
    });
  });
}
