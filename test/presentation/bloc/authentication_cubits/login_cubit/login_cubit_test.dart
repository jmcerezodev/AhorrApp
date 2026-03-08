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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
      return {
        'brand': 'Google',
        'device': 'emulator',
        'model': 'Pixel 4',
        'manufacturer': 'Google',
        'product': 'sdk_gphone_x86',
        'hardware': 'goldfish',
        'isPhysicalDevice': false,
        'sdkInt': 30,
        'id': 'test-id',
        'host': 'test-host',
        'tags': 'test-tags',
        'type': 'test-type',
        'board': 'test-board',
        'display': 'test-display',
        'fingerprint': 'test-fingerprint',
        'supportedAbis': ['arm64-v8a'],
        'supported32BitAbis': [],
        'supported64BitAbis': ['arm64-v8a'],
        'version': {
          'sdkInt': 30,
          'baseOS': '',
          'codename': 'REL',
          'incremental': '',
          'previewSdkInt': 0,
          'release': '11',
          'securityPatch': '2021-01-01',
        },
        'systemFeatures': ['feature-test'],
        'serialNumber': 'unknown'
      };
    });
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
      SharedPreferences.setMockInitialValues({
        'email': 'test@recordado.com',
        'password': 'password123',
        'isRemember': true,
      });
      await Preferences.init();

      loginCubit.resetCubit();

      expect(loginCubit.state.email.value, 'test@recordado.com');
      expect(loginCubit.state.password.value, 'password123');
      expect(loginCubit.state.isRemember, true);
    });

    test('resetCubit NO debe cargar credenciales si isRemember es false', () async {
      SharedPreferences.setMockInitialValues({
        'email': 'test@no-recordado.com',
        'password': 'password123',
        'isRemember': false,
      });
      await Preferences.init();

      loginCubit.resetCubit();

      expect(loginCubit.state.email.value, '');
      expect(loginCubit.state.password.value, '');
      expect(loginCubit.state.isRemember, false);
    });

    test('Constructor debe cargar credenciales iniciales si existen', () async {
      SharedPreferences.setMockInitialValues({
        'email': 'constructor@test.com',
        'password': 'admin',
        'isRemember': true,
      });
      await Preferences.init();

      final newLoginCubit = LoginCubit(historyCubit: mockHistoryCubit);

      expect(newLoginCubit.state.email.value, 'constructor@test.com');
      expect(newLoginCubit.state.isRemember, true);
      
      newLoginCubit.close();
    });
  });
}
