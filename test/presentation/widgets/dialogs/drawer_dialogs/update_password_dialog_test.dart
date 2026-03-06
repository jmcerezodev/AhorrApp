import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_password_cubit/update_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/drawer_dialogs/update_password_dialog.dart';
import 'package:ahorrapp/presentation/widgets/inputs/forms/authentication_inputs_widget/update_password_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdatePasswordCubit extends Mock implements UpdatePasswordCubit {}

void main() {
  late MockUpdatePasswordCubit mockCubit;

  setUp(() {
    mockCubit = MockUpdatePasswordCubit();

    when(() => mockCubit.state).thenReturn(const UpdatePasswordState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.resetCubit()).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<UpdatePasswordCubit>.value(
          value: mockCubit,
          child: const UpdatePasswordDialog(
            title: 'Cambiar Contraseña',
            text: 'Introduce tus datos',
          ),
        ),
      ),
    );
  }

  group('UpdatePasswordDialog - Pruebas de Interfaz de Seguridad', () {
    testWidgets('Debe mostrar el título y los iconos de candado', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('CAMBIAR CONTRASEÑA'), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset_rounded), findsNWidgets(2));
    });

    testWidgets('Debe contener el widget de inputs de contraseña', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(UpdatePasswordInputWidget), findsOneWidget);
    });
  });
}
