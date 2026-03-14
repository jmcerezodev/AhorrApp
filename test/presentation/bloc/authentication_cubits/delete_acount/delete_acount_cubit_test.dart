import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/delete_acount/delete_acount_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/mock_platform.dart';

class FakeBuildContext extends Fake implements BuildContext {}

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
    setupMockPlatform();
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
