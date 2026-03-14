import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}
