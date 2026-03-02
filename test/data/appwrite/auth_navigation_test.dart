import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // 1. Mock para path_provider (Appwrite lo usa para persistencia)
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((methodCall) async => '.');

    // 2. Mock para package_info (Appwrite lo usa para identificarse)
    const MethodChannel('dev.fluttercommunity.plus/package_info')
        .setMockMethodCallHandler((methodCall) async => {
              'appName': 'AhorrApp',
              'packageName': 'dev.jmcerezo.ahorrapp',
              'version': '1.0.0',
              'buildNumber': '1',
            });

    // 3. Mock para device_info (EVITA EL ERROR QUE TIENES AHORA)
    const MethodChannel('dev.fluttercommunity.plus/device_info')
        .setMockMethodCallHandler((methodCall) async => {
              'board': 'test',
              'brand': 'test',
              'device': 'test',
              'display': 'test',
              'fingerprint': 'test',
              'hardware': 'test',
              'id': 'test',
              'manufacturer': 'test',
              'model': 'test',
              'product': 'test',
              'supportedAbis': [],
              'tags': 'test',
              'type': 'test',
              'isPhysicalDevice': false,
              'systemFeatures': [],
              'version': {'sdkInt': 30}
            });
  });

  group('AuthAppwrite - Lógica de Navegación Offline/Online', () {
    late AuthAppwrite authService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      authService = AuthAppwrite();
    });

    test('getInitialRoute debe retornar /home-screen si isLoggedIn es true (Modo Offline)', () async {
      // Configuramos el estado simulado de sesión iniciada
      Preferences.isLoggedIn = true;
      Preferences.uId = 'user123';

      final route = await authService.getInitialRoute();

      expect(route, '/home-screen');
    });

    test('getInitialRoute debe retornar /login si no hay sesión activa', () async {
      Preferences.isLoggedIn = false;
      Preferences.uId = '';

      final route = await authService.getInitialRoute();

      expect(route, '/login');
    });
  });
}
