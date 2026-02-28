import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(Preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    if (state == ThemeMode.light) {
      Preferences.isDarkMode = true;
      emit(ThemeMode.dark);
    } else {
      Preferences.isDarkMode = false;
      emit(ThemeMode.light);
    }
  }
}
