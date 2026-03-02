import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TotalMoneyCubit - Lógica de Balance y Ahorros -', () {
    late TotalMoneyCubit totalMoneyCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      totalMoneyCubit = TotalMoneyCubit();
    });

    tearDown(() {
      totalMoneyCubit.close();
    });

    test('El estado inicial debe ser 0 y los ahorros incluidos por defecto', () {
      expect(totalMoneyCubit.state.totalMoney, 0.0);
      expect(totalMoneyCubit.state.isSavingsIncluded, true);
    });

    test('debe cambiar la preferencia de inclusión de ahorros (toggle)', () {
      // 1. Cambiamos a false
      totalMoneyCubit.toggleSavingsInclusion();
      expect(totalMoneyCubit.state.isSavingsIncluded, false);
      expect(Preferences.isSavingsIncludedInBalance, false);

      // 2. Volvemos a cambiar a true
      totalMoneyCubit.toggleSavingsInclusion();
      expect(totalMoneyCubit.state.isSavingsIncluded, true);
      expect(Preferences.isSavingsIncludedInBalance, true);
    });

    test('debe cargar la preferencia guardada al inicializarse', () async {
      // Simular que el usuario tenía la opción desactivada
      SharedPreferences.setMockInitialValues({'isSavingsIncludedInBalance': false});
      await Preferences.init();
      
      final newCubit = TotalMoneyCubit();
      
      expect(newCubit.state.isSavingsIncluded, false);
      newCubit.close();
    });

    test('debe sumar dinero correctamente', () {
      totalMoneyCubit.addition(100.0);
      expect(totalMoneyCubit.state.totalMoney, 100.0);
    });

    test('debe restar dinero correctamente', () {
      totalMoneyCubit.subtraction(50.0);
      expect(totalMoneyCubit.state.totalMoney, -50.0);
    });
  });
}
