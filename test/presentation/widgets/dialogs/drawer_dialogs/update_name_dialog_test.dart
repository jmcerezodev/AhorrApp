import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_name/update_name_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/drawer_dialogs/update_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateNameCubit extends Mock implements UpdateNameCubit {}

void main() {
  late MockUpdateNameCubit mockCubit;

  setUp(() {
    mockCubit = MockUpdateNameCubit();

    // Estado inicial: Nombre actual "Juan"
    when(() => mockCubit.state).thenReturn(
      const UpdateNameState(name: 'Juan', status: UpdateNameStatus.initial)
    );
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    
    // Stubs para acciones
    when(() => mockCubit.newNameChanged(any())).thenReturn(null);
    when(() => mockCubit.onSubmit()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<UpdateNameCubit>.value(
          value: mockCubit,
          child: const UpdateNameDialog(title: 'Cambiar Nombre'),
        ),
      ),
    );
  }

  group('UpdateNameDialog - Pruebas de Configuración', () {
    testWidgets('Debe mostrar el título y el nombre actual en el campo', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('CAMBIAR NOMBRE'), findsOneWidget);
      // El CustomInputTextWidget usa el state.name como hintText
      expect(find.text('Juan'), findsOneWidget);
    });

    testWidgets('Al escribir un nuevo nombre, debe notificar al Cubit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField);
      await tester.enterText(nameField, 'Pedro');
      
      verify(() => mockCubit.newNameChanged('Pedro')).called(1);
    });

    testWidgets('Debe mostrar carga al pulsar ACTUALIZAR', (WidgetTester tester) async {
      // Simulamos estado válido para habilitar el botón
      when(() => mockCubit.state).thenReturn(
        const UpdateNameState(name: 'Juan', isValid: true, status: UpdateNameStatus.initial)
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('ACTUALIZAR'));
      await tester.pump();

      verify(() => mockCubit.onSubmit()).called(1);
    });
  });
}
