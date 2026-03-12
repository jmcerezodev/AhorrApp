import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_password_cubit/update_password_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
    const MethodChannel securityChannel = MethodChannel('dev.jmcerezo.ahorrapp/security');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async => {'appName': 'AhorrApp', 'packageName': 'dev.jmcerezo.ahorrapp', 'version': '1.0.0', 'buildNumber': '1'});
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getDeviceInfo') {
        return {
          'model': 'iPhone',
          'identifierForVendor': '12345',
          'systemVersion': '15.0',
          'name': 'Test Device'
        };
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(securityChannel, (MethodCall methodCall) async => null);
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
