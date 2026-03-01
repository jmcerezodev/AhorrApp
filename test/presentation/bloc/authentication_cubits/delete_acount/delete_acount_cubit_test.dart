import 'package:ahorrapp/presentation/bloc/authentication_cubits/delete_acount/delete_acount_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
  });

  group('DeleteAcountCubit Tests', () {
    late DeleteAcountCubit cubit;

    setUp(() {
      cubit = DeleteAcountCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Estado inicial debe ser initial y campo vacío', () {
      expect(cubit.state.deleteAcountValueInput, '');
      expect(cubit.state.status, DeleteAccountStatus.initial);
    });

    test('inputValueDeleteAcount debe actualizar el valor y resetear status', () {
      cubit.inputValueDeleteAcount('BORRAR');
      expect(cubit.state.deleteAcountValueInput, 'BORRAR');
      expect(cubit.state.status, DeleteAccountStatus.initial);
    });

    test('onSubmit con confirmación incorrecta debe emitir failure', () async {
      cubit.inputValueDeleteAcount('MAL');
      cubit.onSubmit(FakeBuildContext());
      
      expect(cubit.state.status, DeleteAccountStatus.failure);
      expect(cubit.state.errorMessage, 'Confirmación incorrecta');
    });
  });
}
