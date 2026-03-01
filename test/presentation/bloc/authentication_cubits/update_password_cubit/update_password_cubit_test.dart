import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_password_cubit/update_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
  });

  group('UpdatePasswordCubit Tests', () {
    late UpdatePasswordCubit cubit;

    setUp(() {
      cubit = UpdatePasswordCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Estado inicial debe ser initial', () {
      expect(cubit.state.status, UpdatePasswordStatus.initial);
      expect(cubit.state.isValid, false);
    });

    test('validación de contraseñas debe funcionar correctamente', () {
      cubit.currentPasswordChanged('12345678');
      cubit.newPasswordChanged('87654321');
      cubit.confirmedPasswordChanged('87654321');
      
      expect(cubit.state.isValid, true);
    });

    test('onSubmit con contraseñas que no coinciden debe emitir failure', () {
      cubit.currentPasswordChanged('12345678');
      cubit.newPasswordChanged('87654321');
      cubit.confirmedPasswordChanged('diferente');
      
      cubit.onSubmit(FakeBuildContext());
      expect(cubit.state.status, UpdatePasswordStatus.failure);
    });
  });
}
