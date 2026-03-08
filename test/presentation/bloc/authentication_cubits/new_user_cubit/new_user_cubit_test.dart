import 'package:ahorrapp/presentation/bloc/authentication_cubits/new_user_cubit/new_user_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';

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

  group('NewUserCubit - Blindaje Profesional', () {
    late NewUserCubit newUserCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      newUserCubit = NewUserCubit();
    });

    test('Estado inicial debe ser initial y campos vacíos', () {
      expect(newUserCubit.state.status, NewUserStatus.initial);
      expect(newUserCubit.state.isValid, false);
    });

    test('validación correcta de nombre, email y password', () {
      newUserCubit.nameChanged('Juan');
      newUserCubit.emailChanged('juan@test.com');
      newUserCubit.passwordChanged('12345678');

      expect(newUserCubit.state.isValid, true);
    });

    test('onSubmit debe fallar si el formulario está vacío', () async {
      final expectation = [
        isA<NewUserCubitState>().having((s) => s.status, 'status', NewUserStatus.submitting),
        isA<NewUserCubitState>().having((s) => s.status, 'status', NewUserStatus.failure).having((s) => s.errorMessage, 'message', 'Formulario no válido'),
      ];

      expectLater(newUserCubit.stream, emitsInOrder(expectation));
      newUserCubit.onSubmit();
    });
  });
}
