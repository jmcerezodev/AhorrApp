import 'package:ahorrapp/presentation/bloc/authentication_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async => {'appName': 'AhorrApp', 'packageName': 'dev.jmcerezo.ahorrapp', 'version': '1.0.0', 'buildNumber': '1'});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async => {'brand': 'Google', 'device': 'emulator', 'model': 'Pixel 4', 'sdkInt': 30});
  });

  group('ResetPasswordCubit Tests', () {
    late ResetPasswordCubit cubit;

    setUp(() {
      cubit = ResetPasswordCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Estado inicial debe ser initial', () {
      expect(cubit.state.status, ResetPasswordStatus.initial);
      expect(cubit.state.resetPassword.value, '');
    });

    test('emailChanged debe validar el correo correctamente', () {
      cubit.emailChanged('correo-invalido');
      expect(cubit.state.isValid, false);

      cubit.emailChanged('test@test.com');
      expect(cubit.state.isValid, true);
    });

    test('onSubmit con email inválido debe emitir failure', () {
      cubit.emailChanged('mal');
      cubit.onSubmit();
      expect(cubit.state.status, ResetPasswordStatus.failure);
    });
  });
}
