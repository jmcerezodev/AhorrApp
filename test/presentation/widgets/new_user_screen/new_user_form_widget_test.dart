import 'dart:async';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/new_user_screen/new_user_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockNewUserCubit extends Mock implements NewUserCubit {}

void main() {
  late MockNewUserCubit mockNewUserCubit;
  late StreamController<NewUserCubitState> stateController;

  setUp(() {
    mockNewUserCubit = MockNewUserCubit();
    stateController = StreamController<NewUserCubitState>.broadcast();

    // Estado inicial: initial
    when(() => mockNewUserCubit.state).thenReturn(const NewUserCubitState(status: NewUserStatus.initial));
    when(() => mockNewUserCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockNewUserCubit.close()).thenAnswer((_) async => stateController.close());
    
    when(() => mockNewUserCubit.nameChanged(any())).thenReturn(null);
    when(() => mockNewUserCubit.emailChanged(any())).thenReturn(null);
    when(() => mockNewUserCubit.passwordChanged(any())).thenReturn(null);
    when(() => mockNewUserCubit.onSubmit()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: UserInputWidget())),
      GoRoute(path: '/home-screen', builder: (context, state) => const Scaffold(body: Text('HOME'))),
    ]);

    return BlocProvider<NewUserCubit>.value(
      value: mockNewUserCubit,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('UserInputWidget - Pruebas de Registro y Éxito', () {
    testWidgets('Debe mostrar todos los campos de entrada y el botón', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Tu Nombre'), findsOneWidget);
      expect(find.text('Correo Electronico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('CREAR CUENTA'), findsOneWidget);
    });

    testWidgets('Al tener éxito, debe mostrar el diálogo profesional de confirmación', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Simulamos el cambio a éxito para que el BlocListener lo detecte
      stateController.add(const NewUserCubitState(status: NewUserStatus.success));
      await tester.pumpAndSettle(); // Esperamos a que el diálogo aparezca

      expect(find.text('¡CUENTA CREADA!'), findsOneWidget);
      expect(find.text('EMPEZAR AHORA'), findsOneWidget);
    });

    testWidgets('Al pulsar EMPEZAR AHORA en el diálogo, debe navegar a Home', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      stateController.add(const NewUserCubitState(status: NewUserStatus.success));
      await tester.pumpAndSettle(); 

      // Pulsamos el botón del diálogo
      final startButton = find.text('EMPEZAR AHORA');
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verificamos que llegamos a la ruta de Home
      expect(find.text('HOME'), findsOneWidget);
    });
  });
}
