import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock de Path Provider
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      return '.';
    });

    // Mock de Package Info
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

    // Mock de Device Info (Compatible con casting de Windows)
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
