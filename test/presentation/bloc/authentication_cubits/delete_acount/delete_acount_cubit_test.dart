import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/delete_acount/delete_acount_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
    const MethodChannel securityChannel = MethodChannel('dev.jmcerezo.ahorrapp/security');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async => {'appName': 'AhorrApp', 'packageName': 'dev.jmcerezo.ahorrapp', 'version': '1.0.0', 'buildNumber': '1'});
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (methodCall) async {
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

  group('DeleteAcountCubit Tests', () {
    late DeleteAcountCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'password': 'password123'});
      await Preferences.init();
      cubit = DeleteAcountCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Estado inicial debe ser initial y campo vacío', () {
      expect(cubit.state.deleteAcountValueInput, '');
      expect(cubit.state.status, DeleteAccountStatus.initial);
    });

    test('onSubmit con contraseña incorrecta debe emitir failure', () async {
      cubit.inputValueDeleteAcount('MAL');
      cubit.onSubmit(FakeBuildContext());
      
      expect(cubit.state.status, DeleteAccountStatus.failure);
      expect(cubit.state.errorMessage, 'Contraseña incorrecta');
    });
  });
}
