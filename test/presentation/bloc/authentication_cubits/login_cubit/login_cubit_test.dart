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

  group('LoginCubit - Persistencia de Credenciales', () {
    late LoginCubit loginCubit;
    late MockHistoryCubit mockHistoryCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      mockHistoryCubit = MockHistoryCubit();
      when(() => mockHistoryCubit.prepareForNewLogin()).thenAnswer((_) async => {});
      loginCubit = LoginCubit(historyCubit: mockHistoryCubit);
    });

    tearDown(() {
      loginCubit.close();
    });

    test('resetCubit debe cargar credenciales si isRemember es true', () async {
      // 1. Preparamos el mock de SharedPreferences con datos
      SharedPreferences.setMockInitialValues({
        'email': 'test@recordado.com',
        'password': 'password123',
        'isRemember': true,
      });
      await Preferences.init();

      // 2. Reiniciamos el cubit para que lea las nuevas preferencias
      loginCubit.resetCubit();

      // 3. Verificamos que se hayan cargado
      expect(loginCubit.state.email.value, 'test@recordado.com');
      expect(loginCubit.state.password.value, 'password123');
      expect(loginCubit.state.isRemember, true);
    });

    test('resetCubit NO debe cargar credenciales si isRemember es false', () async {
      // 1. Datos guardados pero recordarme en false
      SharedPreferences.setMockInitialValues({
        'email': 'test@no-recordado.com',
        'password': 'password123',
        'isRemember': false,
      });
      await Preferences.init();

      // 2. Reiniciamos el cubit
      loginCubit.resetCubit();

      // 3. Verificamos que los campos estén vacíos
      expect(loginCubit.state.email.value, '');
      expect(loginCubit.state.password.value, '');
      expect(loginCubit.state.isRemember, false);
    });

    test('Constructor debe cargar credenciales iniciales si existen', () async {
      // 1. Simular datos persistidos antes de crear el cubit
      SharedPreferences.setMockInitialValues({
        'email': 'constructor@test.com',
        'password': 'admin',
        'isRemember': true,
      });
      await Preferences.init();

      // 2. Creamos un nuevo cubit
      final newLoginCubit = LoginCubit(historyCubit: mockHistoryCubit);

      // 3. Verificar estado inicial
      expect(newLoginCubit.state.email.value, 'constructor@test.com');
      expect(newLoginCubit.state.isRemember, true);
      
      newLoginCubit.close();
    });
  });
}
