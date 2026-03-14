import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_password_cubit/update_password_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/mock_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/device_info'),
            (methodCall) async {
      return <String, dynamic>{
        'identifierForVendor': 'test-id',
        'brand': 'apple',
        'model': 'iphone',
        'androidId': 'test-id',
      };
    });
    setupMockPlatform();
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

    test('onSubmit con contraseñas que no coinciden debe emitir failure', () async {
      cubit.currentPasswordChanged('12345678');
      cubit.newPasswordChanged('87654321');
      cubit.confirmedPasswordChanged('diferente');

      await cubit.onSubmit();
      expect(cubit.state.status, UpdatePasswordStatus.failure);
    });
  });
}
