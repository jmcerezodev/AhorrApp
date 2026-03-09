import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/login_screen/login_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginCubit extends Mock implements LoginCubit {}

void main() {
  late MockLoginCubit mockLoginCubit;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  setUp(() {
    mockLoginCubit = MockLoginCubit();
    when(() => mockLoginCubit.state).thenReturn(const LoginCubitState());
    when(() => mockLoginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLoginCubit.close()).thenAnswer((_) async => {});

    // Stubs para las funciones que vamos a probar
    when(() => mockLoginCubit.emailChanged(any())).thenReturn(null);
    when(() => mockLoginCubit.passwordChanged(any())).thenReturn(null);
    when(() => mockLoginCubit.onSubmit()).thenReturn(null);
    when(() => mockLoginCubit.resetCubit()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<LoginCubit>.value(
          value: mockLoginCubit,
          child: const LoginFormWidget(),
        ),
      ),
    );
  }

  group('LoginFormWidget - Pruebas de Interfaz e Interacción', () {
    testWidgets('Debe mostrar los elementos básicos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('ACCESO'), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
    });

    testWidgets('Al escribir el correo, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el campo de texto por su etiqueta
      final emailField = find.byType(TextField).first;

      // Simulamos que el usuario escribe
      await tester.enterText(emailField, 'test@correo.com');
      
      // Verificamos que el Cubit recibió el correo exacto
      verify(() => mockLoginCubit.emailChanged('test@correo.com')).called(1);
    });

    testWidgets('Al pulsar ENTRAR, debe llamar a onSubmit del Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el botón por el texto
      final loginButton = find.text('ENTRAR');

      // Simulamos el toque
      await tester.tap(loginButton);
      await tester.pump(); // Esperamos a que la UI reaccione

      // Verificamos que se llamó a la función de envío
      verify(() => mockLoginCubit.onSubmit()).called(1);
    });
  });
}
