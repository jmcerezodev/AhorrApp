import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      // Ajuste para local_auth ^3.0.1: se eliminó el parámetro 'options'
      // y se usan parámetros directos. 'stickyAuth' ahora es 'persistAcrossBackgrounding'.
      return await _auth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder a tus finanzas',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
