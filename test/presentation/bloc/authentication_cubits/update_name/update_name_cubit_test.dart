import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_name/update_name_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpdateNameCubit Tests', () {
    late UpdateNameCubit updateNameCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'name': 'Juan Original'});
      await Preferences.init();
      updateNameCubit = UpdateNameCubit();
    });

    test('Estado inicial debe tener el nombre actual de preferencias', () {
      expect(updateNameCubit.state.name, 'Juan Original');
      expect(updateNameCubit.state.status, UpdateNameStatus.initial);
    });

    test('newNameChanged debe actualizar el input y validar', () {
      updateNameCubit.newNameChanged('Juan Nuevo');
      expect(updateNameCubit.state.newName.value, 'Juan Nuevo');
      expect(updateNameCubit.state.isValid, true);
    });

    test('onSubmit debe cambiar el nombre y guardar en preferencias', () {
      updateNameCubit.newNameChanged('Juan Final');
      updateNameCubit.onSubmit();

      expect(updateNameCubit.state.status, UpdateNameStatus.success);
      expect(updateNameCubit.state.name, 'Juan Final');
      expect(Preferences.name, 'Juan Final');
    });
  });
}
