import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeCubit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
    });

    test('Estado inicial debe ser light por defecto si no hay preferencias', () {
      final themeCubit = ThemeCubit();
      expect(themeCubit.state, ThemeMode.light);
      themeCubit.close();
    });

    test('toggleTheme debe cambiar de light a dark y guardar en preferencias', () {
      final themeCubit = ThemeCubit();
      
      themeCubit.toggleTheme();
      expect(themeCubit.state, ThemeMode.dark);
      expect(Preferences.isDarkMode, true);

      themeCubit.toggleTheme();
      expect(themeCubit.state, ThemeMode.light);
      expect(Preferences.isDarkMode, false);
      
      themeCubit.close();
    });
  });
}
