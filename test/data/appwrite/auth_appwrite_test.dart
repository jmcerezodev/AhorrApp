import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/appwrite/appwrite_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/mock_platform.dart';

class MockAppwriteService extends Mock implements AppwriteService {}
class MockAccount extends Mock implements Account {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/device_info'),
            (methodCall) async {
      return <String, dynamic>{
        'identifierForVendor': 'test-id',
        'brand': 'apple',
        'model': 'iphone',
        'androidId': 'test-id',
      };
    });
    setupAllMocks();
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
