import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth & Info
  static String get uId => _prefs.getString('uId') ?? '';
  static set uId(String value) => _prefs.setString('uId', value);

  static String get name => _prefs.getString('name') ?? '';
  static set name(String value) => _prefs.setString('name', value);

  static String get email => _prefs.getString('email') ?? '';
  static set email(String value) => _prefs.setString('email', value);

  static String get password => _prefs.getString('password') ?? '';
  static set password(String value) => _prefs.setString('password', value);

  static bool get isRemember => _prefs.getBool('isRemember') ?? false;
  static set isRemember(bool value) => _prefs.setBool('isRemember', value);

  // Ajustes de App
  static bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  static set isDarkMode(bool value) => _prefs.setBool('isDarkMode', value);

  static bool get isBiometricActive => _prefs.getBool('isBiometricActive') ?? false;
  static set isBiometricActive(bool value) => _prefs.setBool('isBiometricActive', value);

  // Meta de Ahorro (NUEVO)
  static double get savingGoal => _prefs.getDouble('savingGoal') ?? 0.0;
  static set savingGoal(double value) => _prefs.setDouble('savingGoal', value);
}
