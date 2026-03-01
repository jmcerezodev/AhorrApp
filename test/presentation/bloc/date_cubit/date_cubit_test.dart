import 'package:ahorrapp/presentation/bloc/date_cubit/date_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateCubit Tests', () {
    late DateCubit dateCubit;

    setUp(() {
      dateCubit = DateCubit();
    });

    tearDown(() {
      dateCubit.close();
    });

    test('Estado inicial debe tener valores por defecto', () {
      expect(dateCubit.state.year, 0);
      expect(dateCubit.state.month, '');
      expect(dateCubit.state.isOpen, false);
    });

    test('isOpen debe cambiar el estado correctamente', () {
      dateCubit.isOpen(true);
      expect(dateCubit.state.isOpen, true);
      
      dateCubit.isOpen(false);
      expect(dateCubit.state.isOpen, false);
    });

    test('yearIncrement y yearDecrement deben funcionar correctamente', () {
      dateCubit.yearIncrement(1);
      expect(dateCubit.state.year, 1);
      
      dateCubit.yearDecrement(1);
      expect(dateCubit.state.year, 0);
    });

    test('month debe actualizar el mes correctamente', () {
      dateCubit.month('Octubre');
      expect(dateCubit.state.month, 'Octubre');
    });
  });
}
