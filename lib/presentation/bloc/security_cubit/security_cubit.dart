import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahorrapp/presentation/bloc/security_cubit/security_state.dart';
import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/di/service_locator.dart';

class SecurityCubit extends Cubit<SecurityState> {
  final BiometricService _biometricService = getIt<BiometricService>();

  SecurityCubit() : super(SecurityState(
    status: Preferences.isBiometricActive ? SecurityStatus.locked : SecurityStatus.unlocked,
    isBiometricEnabled: Preferences.isBiometricActive,
  ));

  Future<void> authenticate() async {
    if (!Preferences.isBiometricActive) {
      emit(state.copyWith(status: SecurityStatus.unlocked));
      return;
    }

    final bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      emit(state.copyWith(status: SecurityStatus.unlocked));
    } else {
      emit(state.copyWith(status: SecurityStatus.locked));
    }
  }

  void lock() {
    if (Preferences.isBiometricActive) {
      emit(state.copyWith(status: SecurityStatus.locked));
    }
  }

  void toggleBiometric(bool value) {
    Preferences.isBiometricActive = value;
    emit(state.copyWith(isBiometricEnabled: value));
  }
}
