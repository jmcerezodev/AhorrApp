import 'package:ahorrapp/presentation/bloc/authentication_cubits/login_cubit/login_cubit.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../../helpers/mock_platform.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}

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
    setupAllMocks();
  });

  group('LoginCubit - Persistencia de Credenciales', () {
    late LoginCubit loginCubit;
    late MockHistoryCubit mockHistoryCubit;

    setUp(() async {
      GetIt.instance.reset();

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
