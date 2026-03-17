enum SecurityStatus { locked, unlocked }

class SecurityState {
  final SecurityStatus status;
  final bool isBiometricEnabled;

  SecurityState({
    required this.status,
    required this.isBiometricEnabled,
  });

  SecurityState copyWith({
    SecurityStatus? status,
    bool? isBiometricEnabled,
  }) {
    return SecurityState(
      status: status ?? this.status,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}
