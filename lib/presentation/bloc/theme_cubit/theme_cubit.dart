import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(
    themeMode: Preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    isPrivacyModeActive: Preferences.isPrivacyModeActive,
  ));

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    Preferences.isDarkMode = newMode == ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));
  }

  void togglePrivacyMode() {
    final newValue = !state.isPrivacyModeActive;
    Preferences.isPrivacyModeActive = newValue;
    emit(state.copyWith(isPrivacyModeActive: newValue));
  }
}
