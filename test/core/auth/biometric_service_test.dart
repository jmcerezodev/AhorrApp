import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const <AuthMessages>[]);
  });

  late MockLocalAuthentication mockAuth;
  late BiometricService biometricService;

  setUp(() {
    mockAuth = MockLocalAuthentication();
    biometricService = BiometricService(auth: mockAuth);
  });

  group('BiometricService Tests', () {
    test('canCheckBiometrics debe retornar false si hay una PlatformException', () async {
      when(() => mockAuth.canCheckBiometrics).thenThrow(PlatformException(code: 'error'));
      
      final result = await biometricService.canCheckBiometrics();
      
      expect(result, isFalse);
    });

    test('authenticate debe retornar false si falla la autenticación biométrica', () async {
      when(() => mockAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        authMessages: any(named: 'authMessages'),
        biometricOnly: any(named: 'biometricOnly'),
        sensitiveTransaction: any(named: 'sensitiveTransaction'),
        persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
      )).thenAnswer((_) async => false);

      final result = await biometricService.authenticate();
      
      expect(result, isFalse);
    });

    test('authenticate debe retornar true si la autenticación es exitosa', () async {
      when(() => mockAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        authMessages: any(named: 'authMessages'),
        biometricOnly: any(named: 'biometricOnly'),
        sensitiveTransaction: any(named: 'sensitiveTransaction'),
        persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
      )).thenAnswer((_) async => true);

      final result = await biometricService.authenticate();
      
      expect(result, isTrue);
    });
  });
}
