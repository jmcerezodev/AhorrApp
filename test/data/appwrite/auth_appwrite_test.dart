import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/appwrite/appwrite_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAppwriteService extends Mock implements AppwriteService {}
class MockAccount extends Mock implements Account {}

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
        'packageName': 'dev.jmcerezo.ahorrapp',
        'version': '1.0.0',
        'buildNumber': '1',
      };
    });

    const channel = MethodChannel('dev.fluttercommunity.plus/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async => {});
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  group('AuthAppwrite - Recuperación de Contraseña', () {
    test('Constructor debe inicializarse sin errores', () {
      expect(() => AuthAppwrite(), returnsNormally);
    });
  });
}
