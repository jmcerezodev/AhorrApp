import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import '../../../../helpers/mock_platform.dart';

class MockAuthAppwrite extends Mock implements AuthAppwrite {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ResetPasswordCubit cubit;
  late MockAuthAppwrite mockAuth;

  setUpAll(() {
    setupMockPlatform();
  });

  setUp(() {
    mockAuth = MockAuthAppwrite();
    cubit = ResetPasswordCubit(auth: mockAuth);
  });

  tearDown(() {
    cubit.close();
  });

  group('ResetPasswordCubit Tests', () {
    test('Estado inicial debe ser initial', () {
      expect(cubit.state.status, ResetPasswordStatus.initial);
      expect(cubit.state.resetPassword.value, '');
    });

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'emailChanged debe validar el correo correctamente',
      build: () => cubit,
      act: (cubit) => cubit.emailChanged('test@test.com'),
      expect: () => [
        predicate<ResetPasswordState>((state) => state.resetPassword.value == 'test@test.com' && state.isValid),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'onSubmit debe emitir [submitting, success] cuando el email es válido y el servicio responde OK',
      build: () {
        when(() => mockAuth.resetPassword(any())).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) {
        cubit.emailChanged('test@test.com');
        cubit.onSubmit();
      },
      expect: () => [
        predicate<ResetPasswordState>((state) => state.resetPassword.value == 'test@test.com' && state.isValid),
        predicate<ResetPasswordState>((state) => state.status == ResetPasswordStatus.submitting),
        predicate<ResetPasswordState>((state) => state.status == ResetPasswordStatus.success),
      ],
      verify: (_) {
        verify(() => mockAuth.resetPassword('test@test.com')).called(1);
      },
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'onSubmit debe emitir [submitting, failure] cuando el servicio lanza una excepción',
      build: () {
        when(() => mockAuth.resetPassword(any())).thenThrow(Exception('Error de red'));
        return cubit;
      },
      act: (cubit) {
        cubit.emailChanged('test@test.com');
        cubit.onSubmit();
      },
      expect: () => [
        predicate<ResetPasswordState>((state) => state.resetPassword.value == 'test@test.com' && state.isValid),
        predicate<ResetPasswordState>((state) => state.status == ResetPasswordStatus.submitting),
        predicate<ResetPasswordState>((state) => state.status == ResetPasswordStatus.failure && state.errorMessage != null),
      ],
    );
  });
}
