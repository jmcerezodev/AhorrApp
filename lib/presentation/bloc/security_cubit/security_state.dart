enum SecurityStatus { locked, unlocked }

class SecurityState {
  final SecurityStatus status;

  SecurityState({required this.status});

  SecurityState copyWith({SecurityStatus? status}) {
    return SecurityState(status: status ?? this.status);
  }
}
