import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
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
      if (methodCall.method == 'getDeviceInfo') {
        // Retornamos un mapa que sea compatible tanto con Android como con Windows en el mock
        return {
          'computerName': 'Test-PC',
          'numberOfCores': 4,
          'systemMemoryInMegabytes': 8192,
          // Campos de Android por si acaso
          'brand': 'Google',
          'model': 'Pixel 4',
          'sdkInt': 30,
          'id': 'test-id',
        };
      }
      return null;
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
