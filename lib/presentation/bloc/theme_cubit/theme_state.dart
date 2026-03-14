import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool isPrivacyModeActive;

  ThemeState({
    required this.themeMode,
    required this.isPrivacyModeActive,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isPrivacyModeActive,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isPrivacyModeActive: isPrivacyModeActive ?? this.isPrivacyModeActive,
    );
  }
}
