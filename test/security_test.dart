import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Para hacer la lógica testeable de forma aislada, la encapsulamos aquí.
class SecurityService {
  static const platform = MethodChannel('dev.jmcerezo.ahorrapp/security');

  static Future<void> updateAppSecurity() async {
    try {
      await platform.invokeMethod('setSecure', {'secure': Preferences.isBiometricActive});
    } on PlatformException catch (e) {
      print("Error al configurar FLAG_SECURE: ${e.message}");
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('dev.jmcerezo.ahorrapp/security');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    // Corregido: En versiones recientes de Flutter se usa tester.binding.defaultBinaryMessenger
    // o simplemente el binding directamente si no estamos en un widgetTest.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel, 
      (MethodCall methodCall) async {
        log.add(methodCall);
        return null; 
      }
    );
    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('Pruebas del servicio de seguridad de la app -', () {
    test('Debe llamar a "setSecure" con "true" si la biometría está activada', () async {
      SharedPreferences.setMockInitialValues({'isBiometricActive': true});
      await Preferences.init();

      await SecurityService.updateAppSecurity();

      expect(log, contains(
        isA<MethodCall>()
            .having((m) => m.method, 'method', 'setSecure')
            .having((m) => m.arguments['secure'], 'arguments', true),
      ));
    });

    test('Debe llamar a "setSecure" con "false" si la biometría está desactivada', () async {
      SharedPreferences.setMockInitialValues({'isBiometricActive': false});
      await Preferences.init();

      await SecurityService.updateAppSecurity();

      expect(log, contains(
        isA<MethodCall>()
            .having((m) => m.method, 'method', 'setSecure')
            .having((m) => m.arguments['secure'], 'arguments', false),
      ));
    });
  });
}
