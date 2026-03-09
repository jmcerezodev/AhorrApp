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
        return {
          'computerName': 'Test-PC',
          'numberOfCores': 4,
          'systemMemoryInMegabytes': 8192,
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
