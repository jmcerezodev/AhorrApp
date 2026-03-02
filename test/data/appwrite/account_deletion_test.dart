import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
  });

  group('Pruebas de Limpieza de Preferencias (clearAll) -', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
    });

    test('Debe borrar uId y resetear sesión pero mantener el Modo Oscuro', () async {
      // Arrange
      Preferences.uId = 'user-123';
      Preferences.isLoggedIn = true;
      Preferences.isDarkMode = true;
      Preferences.isBiometricActive = true;
      
      // Act
      await Preferences.clearAll();
      
      // Assert
      expect(Preferences.uId, '');
      expect(Preferences.isLoggedIn, false);
      expect(Preferences.isBiometricActive, false);
      expect(Preferences.isDarkMode, true); // El tema se preserva
    });

    test('Debe mantener email y password si isRemember es true', () async {
      // Arrange
      Preferences.email = 'mantener@test.com';
      Preferences.password = 'secret123';
      Preferences.isRemember = true;
      
      // Act
      await Preferences.clearAll();
      
      // Assert
      expect(Preferences.email, 'mantener@test.com');
      expect(Preferences.password, 'secret123');
      expect(Preferences.isRemember, true);
    });

    test('Debe limpiar email y password si isRemember es false', () async {
      // Arrange
      Preferences.email = 'borrar@test.com';
      Preferences.password = 'secret123';
      Preferences.isRemember = false;
      
      // Act
      await Preferences.clearAll();
      
      // Assert
      expect(Preferences.email, '');
      expect(Preferences.password, '');
      expect(Preferences.isRemember, false);
    });
  });
}
