import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');

    const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async {
      return {
        'appName': 'AhorrApp',
        'packageName': 'com.example.ahorrapp',
        'version': '1.0.0',
        'buildNumber': '1',
      };
    });

    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
      return {
        'brand': 'Google',
        'device': 'emulator',
        'model': 'Pixel 4',
        'manufacturer': 'Google',
        'product': 'sdk_gphone_x86',
        'hardware': 'goldfish',
        'isPhysicalDevice': false,
        'sdkInt': 30,
        'id': 'test-id',
        'host': 'test-host',
        'tags': 'test-tags',
        'type': 'test-type',
        'board': 'test-board',
        'display': 'test-display',
        'fingerprint': 'test-fingerprint',
        'supportedAbis': ['arm64-v8a'],
        'supported32BitAbis': [],
        'supported64BitAbis': ['arm64-v8a'],
        'version': {
          'sdkInt': 30,
          'baseOS': '',
          'codename': 'REL',
          'incremental': '',
          'previewSdkInt': 0,
          'release': '11',
          'securityPatch': '2021-01-01',
        },
        'systemFeatures': ['feature-test'],
        'serialNumber': 'unknown'
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
