import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // 1. Mock para path_provider
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((methodCall) async => '.');

    // 2. Mock para package_info
    const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return {
          'appName': 'AhorrApp',
          'packageName': 'com.example.ahorrapp',
          'version': '1.0.0',
          'buildNumber': '1',
        };
      }
      return null;
    });

    // 3. Mock para device_info compatible con Windows
    const MethodChannel deviceInfoChannel = MethodChannel('plugins.flutter.io/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
      return {
        'computerName': 'Test-PC',
        'numberOfCores': 4,
        'systemMemoryInMegabytes': 8192,
        'userName': 'tester',
        'majorVersion': 10,
        'minorVersion': 0,
        'buildNumber': 19041,
        'platformId': 2,
        'csdVersion': '',
        'servicePackMajor': 0,
        'servicePackMinor': 0,
        'suitMask': 0,
        'productType': 1,
        'reserved': 0,
        'buildLab': '19041.vb_release.200506-1335',
        'buildLabEx': '19041.1.amd64fre.vb_release.200506-1335',
        'digitalProductId': null,
        'displayVersion': '2004',
        'editionId': 'Professional',
        'installDate': 0,
        'productId': '00000-00000-00000-AAAAA',
        'productName': 'Windows 10 Pro',
        'registeredOwner': 'tester',
        'releaseId': '2004',
        'rootDirectory': 'C:\\',
      };
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
