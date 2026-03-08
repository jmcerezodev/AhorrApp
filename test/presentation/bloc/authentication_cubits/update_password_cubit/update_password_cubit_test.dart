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
    const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async => {'appName': 'AhorrApp', 'packageName': 'dev.jmcerezo.ahorrapp', 'version': '1.0.0', 'buildNumber': '1'});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async => {'brand': 'Google', 'device': 'emulator', 'model': 'Pixel 4', 'sdkInt': 30});
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
