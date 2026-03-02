import 'package:ahorrapp/presentation/bloc/authentication_cubits/login_cubit/login_cubit.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}

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
    late MockHistoryCubit mockHistoryCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      
      mockHistoryCubit = MockHistoryCubit();
      // Stub para evitar errores cuando se llame a prepareForNewLogin
      when(() => mockHistoryCubit.prepareForNewLogin()).thenAnswer((_) async => {});
      
      // CORREGIDO: Usamos el parámetro con nombre historyCubit
      loginCubit = LoginCubit(historyCubit: mockHistoryCubit);
    });

    tearDown(() {
      loginCubit.close();
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

    test('onSubmit con campos vacíos debe dar error de validación', () async {
      loginCubit.onSubmit();
      expect(loginCubit.state.status, LoginStatus.failure);
      expect(loginCubit.state.errorMessage, 'Formulario no válido');
    });
  });
}
