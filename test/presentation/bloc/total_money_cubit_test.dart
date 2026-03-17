import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../mocks/mock_definitions.dart';

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    // Inyectamos el mock en la clase estática Preferences
    Preferences.setPrefs = mockPrefs;
    
    // Configuración por defecto para evitar nulls
    when(() => mockPrefs.getBool('isSavingsIncludedInBalance')).thenReturn(false);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  group('TotalMoneyCubit - Unit Tests', () {
    test('initial state should read from Preferences', () {
      when(() => mockPrefs.getBool('isSavingsIncludedInBalance')).thenReturn(true);
      
      final cubit = TotalMoneyCubit();
      
      expect(cubit.state.isSavingsIncluded, true);
      expect(cubit.state.totalMoney, 0.0);
    });

    test('addition and subtraction should update totalMoney', () {
      final cubit = TotalMoneyCubit();
      
      cubit.addition(100.5);
      expect(cubit.state.totalMoney, 100.5);
      
      cubit.subtraction(50.0);
      expect(cubit.state.totalMoney, 50.5);
    });

    test('totalMoney(value) should set absolute value', () {
      final cubit = TotalMoneyCubit();
      cubit.totalMoney(1234.56);
      expect(cubit.state.totalMoney, 1234.56);
    });

    test('toggleSavingsInclusion should flip state and save to Preferences', () {
      final cubit = TotalMoneyCubit();
      expect(cubit.state.isSavingsIncluded, false);
      
      cubit.toggleSavingsInclusion();
      
      expect(cubit.state.isSavingsIncluded, true);
      verify(() => mockPrefs.setBool('isSavingsIncludedInBalance', true)).called(1);
    });

    test('resetCubit should restore state from Preferences', () {
      final cubit = TotalMoneyCubit();
      cubit.totalMoney(500);
      
      // Cambiamos el mock para que al reiniciar lea 'true'
      when(() => mockPrefs.getBool('isSavingsIncludedInBalance')).thenReturn(true);
      
      cubit.resetCubit();
      
      expect(cubit.state.totalMoney, 0.0);
      expect(cubit.state.isSavingsIncluded, true);
    });
  });
}
