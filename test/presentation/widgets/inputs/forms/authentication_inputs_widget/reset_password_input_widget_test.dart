import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/forms/authentication_inputs_widget/reset_password_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockResetPasswordCubit extends Mock implements ResetPasswordCubit {}

void main() {
  late MockResetPasswordCubit mockResetPasswordCubit;

  setUp(() {
    mockResetPasswordCubit = MockResetPasswordCubit();

    // Estado inicial seguro
    when(() => mockResetPasswordCubit.state).thenReturn(const ResetPasswordState());
    when(() => mockResetPasswordCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockResetPasswordCubit.close()).thenAnswer((_) async => {});
    
    // Stubs para interacciones
    when(() => mockResetPasswordCubit.emailChanged(any())).thenReturn(null);
    when(() => mockResetPasswordCubit.onSubmit()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ResetPasswordInputWidget(
          cubit: mockResetPasswordCubit,
        ),
      ),
    );
  }

  group('ResetPasswordInputWidget - Pruebas de Recuperación', () {
    testWidgets('Debe mostrar el título y el campo de correo', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('RECUPERACIÓN'), findsOneWidget);
      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.text('RECUPERAR'), findsOneWidget);
    });

    testWidgets('Al escribir el correo, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el campo de texto por su hint
      final emailField = find.widgetWithText(TextField, 'usuario@correo.com');
      await tester.enterText(emailField, 'recuperame@test.com');
      
      verify(() => mockResetPasswordCubit.emailChanged('recuperame@test.com')).called(1);
    });

    testWidgets('Debe mostrar el spinner cuando se está enviando la solicitud', (WidgetTester tester) async {
      // Simulamos estado de carga
      when(() => mockResetPasswordCubit.state).thenReturn(
        const ResetPasswordState(status: ResetPasswordStatus.submitting)
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // El icono de la llave debe desaparecer y mostrarse el spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.key_rounded), findsNothing);
    });
  });
}
