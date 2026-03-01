import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/new_user_screen/new_user_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNewUserCubit extends Mock implements NewUserCubit {}

void main() {
  late MockNewUserCubit mockNewUserCubit;

  setUp(() {
    mockNewUserCubit = MockNewUserCubit();

    // Estado inicial seguro
    when(() => mockNewUserCubit.state).thenReturn(const NewUserCubitState());
    when(() => mockNewUserCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockNewUserCubit.close()).thenAnswer((_) async => {});
    
    // Stubs para las funciones de entrada
    when(() => mockNewUserCubit.nameChanged(any())).thenReturn(null);
    when(() => mockNewUserCubit.emailChanged(any())).thenReturn(null);
    when(() => mockNewUserCubit.passwordChanged(any())).thenReturn(null);
    when(() => mockNewUserCubit.onSubmit()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<NewUserCubit>.value(
          value: mockNewUserCubit,
          child: const UserInputWidget(),
        ),
      ),
    );
  }

  group('UserInputWidget - Pruebas de Registro', () {
    testWidgets('Debe mostrar todos los campos de entrada y el botón', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Tu Nombre'), findsOneWidget);
      expect(find.text('Correo Electronico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('CREAR CUENTA'), findsOneWidget);
    });

    testWidgets('Debe mostrar un spinner de carga cuando el estado es submitting', (WidgetTester tester) async {
      when(() => mockNewUserCubit.state).thenReturn(
        const NewUserCubitState(status: NewUserStatus.submitting)
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // El botón debería estar deshabilitado (no detectable directamente por texto pero sí por comportamiento)
    });

    testWidgets('Al escribir el nombre, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Buscamos el campo de nombre (es el primero)
      final nameField = find.widgetWithText(TextField, 'Nombre');
      await tester.enterText(nameField, 'Juan');
      
      verify(() => mockNewUserCubit.nameChanged('Juan')).called(1);
    });
  });
}
