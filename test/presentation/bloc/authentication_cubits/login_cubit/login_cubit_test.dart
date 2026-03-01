import 'package:ahorrapp/presentation/bloc/authentication_cubits/login_cubit/login_cubit.dart';
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async => {'board': 'test', 'brand': 'test', 'device': 'test', 'display': 'test', 'fingerprint': 'test', 'hardware': 'test', 'id': 'test', 'manufacturer': 'test', 'model': 'test', 'product': 'test', 'supportedAbis': [], 'tags': 'test', 'type': 'test', 'isPhysicalDevice': false, 'systemFeatures': [], 'version': {'sdkInt': 30}});
  });

  group('LoginCubit - Limpieza Profesional', () {
    late LoginCubit loginCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      loginCubit = LoginCubit();
    });

    test('Estado inicial debe ser initial', () {
      expect(loginCubit.state.status, LoginStatus.initial);
      expect(loginCubit.state.isValid, false);
    });

    test('validación de email y password correcta', () {
      loginCubit.emailChanged('test@test.com');
      loginCubit.passwordChanged('123456');
      expect(loginCubit.state.isValid, true);
    });

    test('onSubmit debe pasar por submitting y terminar en failure con campos vacíos', () async {
      final expectation = [
        isA<LoginCubitState>().having((s) => s.status, 'status', LoginStatus.submitting),
        isA<LoginCubitState>().having((s) => s.status, 'status', LoginStatus.failure).having((s) => s.errorMessage, 'message', 'Formulario no válido'),
      ];

      expectLater(loginCubit.stream, emitsInOrder(expectation));
      loginCubit.onSubmit();
    });
  });
}
