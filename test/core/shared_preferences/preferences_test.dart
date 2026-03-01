import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Preferences Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
    });

    test('debe guardar y recuperar el uId correctamente', () {
      Preferences.uId = 'test-uid';
      expect(Preferences.uId, 'test-uid');
    });

    test('debe guardar y recuperar el nombre correctamente', () {
      Preferences.name = 'Juan';
      expect(Preferences.name, 'Juan');
    });

    test('debe manejar correctamente el modo oscuro', () {
      Preferences.isDarkMode = true;
      expect(Preferences.isDarkMode, true);
      Preferences.isDarkMode = false;
      expect(Preferences.isDarkMode, false);
    });

    test('debe manejar correctamente la opción recordar sesión', () {
      Preferences.isRemember = true;
      expect(Preferences.isRemember, true);
    });
  });
}
