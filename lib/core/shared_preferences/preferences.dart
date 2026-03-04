import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- SESIÓN Y AUTH ---
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

  static bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  static set isLoggedIn(bool value) => _prefs.setBool('isLoggedIn', value);

  // --- AJUSTES DE INTERFAZ ---
  static bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  static set isDarkMode(bool value) => _prefs.setBool('isDarkMode', value);

  static bool get isBiometricActive => _prefs.getBool('isBiometricActive') ?? false;
  static set isBiometricActive(bool value) => _prefs.setBool('isBiometricActive', value);

  static bool get isSavingsIncludedInBalance => _prefs.getBool('isSavingsIncludedInBalance') ?? true;
  static set isSavingsIncludedInBalance(bool value) => _prefs.setBool('isSavingsIncludedInBalance', value);

  static bool get isProratedView => _prefs.getBool('isProratedView') ?? false; // NUEVO: Valor por defecto mensual
  static set isProratedView(bool value) => _prefs.setBool('isProratedView', value);

  // --- LIMPIEZA SEGURA ---
  static Future<void> clearAll() async {
    // 1. Guardamos lo que queremos preservar
    final currentDarkMode = isDarkMode;
    final currentRemember = isRemember;
    final currentEmail = email;
    final currentPassword = password;
    final currentIsSavingsIncluded = isSavingsIncludedInBalance;
    final currentIsProratedView = isProratedView;
    
    // 2. En lugar de .clear(), reseteamos los valores a su estado inicial
    uId = '';
    name = '';
    isLoggedIn = false;
    isBiometricActive = false;
    isSavingsIncludedInBalance = true;
    isProratedView = false;

    // 3. Restauramos o limpiamos credenciales según la preferencia del usuario
    isDarkMode = currentDarkMode;
    isSavingsIncludedInBalance = currentIsSavingsIncluded;
    isProratedView = currentIsProratedView;
    
    if (currentRemember) {
      isRemember = true;
      email = currentEmail;
      password = currentPassword;
    } else {
      isRemember = false;
      email = '';
      password = '';
    }
  }
}
