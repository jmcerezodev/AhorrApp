import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Escudo para que Appwrite no busque carpetas reales en el sistema
  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
  });

  group('AuthAppwrite - Lógica de sesión', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
    });

    test('getInitialRoute debe retornar /login por defecto', () async {
      final auth = AuthAppwrite();
      final route = await auth.getInitialRoute();
      expect(route, '/login');
    });
  });
}
