import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
  });

  group('Borrado de Cuenta -', () {
    late MockAppwriteRepository mockAppwriteRepo;
    late MockLocalDbService mockLocalDb;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'uId': 'user-123',
        'isLoggedIn': true,
        'email': 'test@test.com'
      });
      await Preferences.init();

      mockAppwriteRepo = MockAppwriteRepository();
      mockLocalDb = MockLocalDbService();
      
      // Corregido: Ahora estos métodos devuelven Future<int>
      when(() => mockAppwriteRepo.deleteAllHistory(any(), onDeleted: any(named: 'onDeleted')))
          .thenAnswer((_) async => 0);
      when(() => mockAppwriteRepo.deleteAllSavings(any(), onDeleted: any(named: 'onDeleted')))
          .thenAnswer((_) async => 0);
      when(() => mockLocalDb.clearAll()).thenAnswer((_) async => {});
    });

    test('clearAll de Preferences debe borrar uId pero puede mantener darkMode', () async {
      Preferences.isDarkMode = true;
      Preferences.uId = '123';
      
      await Preferences.clearAll();
      
      expect(Preferences.uId, '');
      expect(Preferences.isDarkMode, true);
    });

    test('clearAll de Preferences debe borrar email y password si isRemember es false', () async {
      Preferences.email = 'test@test.com';
      Preferences.password = '123456';
      Preferences.isRemember = false;
      
      await Preferences.clearAll();
      
      expect(Preferences.email, '');
      expect(Preferences.password, '');
    });
  });
}
