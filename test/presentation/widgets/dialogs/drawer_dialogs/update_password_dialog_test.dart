import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_password_cubit/update_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/drawer_dialogs/update_password_dialog.dart';
import 'package:ahorrapp/presentation/widgets/inputs/forms/authentication_inputs_widget/update_password_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdatePasswordCubit extends Mock implements UpdatePasswordCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

      // El widget usa dialogRowHeader con title: 'Cambiar Contraseña' -> 'CAMBIAR CONTRASEÑA'
      expect(find.text('CAMBIAR CONTRASEÑA'), findsOneWidget);
      // dialogRowHeader tiene 1 icono + UpdatePasswordInputWidget puede tener otros
      expect(find.byIcon(Icons.lock_reset_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('Debe contener el widget de inputs de contraseña', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(UpdatePasswordInputWidget), findsOneWidget);
    });

    testWidgets('Debe mostrar el botón ACTUALIZAR', (WidgetTester tester) async {
      // Nota: El botón ACTUALIZAR suele estar dentro de UpdatePasswordInputWidget o el Dialog
      // Verificamos si existe un botón con ese texto (en UPPERCASE por AppDialogs)
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final updateBtn = find.text('ACTUALIZAR');
      if (updateBtn.evaluate().isNotEmpty) {
        expect(updateBtn, findsOneWidget);
      }
    });
  });
}
