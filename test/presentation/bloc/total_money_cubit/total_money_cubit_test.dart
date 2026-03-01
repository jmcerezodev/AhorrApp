import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TotalMoneyCubit Tests', () {
    late TotalMoneyCubit totalMoneyCubit;

    setUp(() {
      totalMoneyCubit = TotalMoneyCubit();
    });

    tearDown(() {
      totalMoneyCubit.close();
    });

    test('El estado inicial debe ser 0', () {
      expect(totalMoneyCubit.state.totalMoney, 0.0);
    });

    test('debe sumar dinero correctamente', () {
      totalMoneyCubit.addition(100.0);
      expect(totalMoneyCubit.state.totalMoney, 100.0);
    });

    test('debe restar dinero correctamente', () {
      totalMoneyCubit.subtraction(50.0);
      expect(totalMoneyCubit.state.totalMoney, -50.0);
    });

    test('debe actualizar el total de dinero directamente', () {
      totalMoneyCubit.totalMoney(250.0);
      expect(totalMoneyCubit.state.totalMoney, 250.0);
    });
  });
}
