import 'package:ahorrapp/presentation/screens/authentication/confirm_reset_password_screen.dart';
import 'package:ahorrapp/presentation/widgets/inputs/custom_input_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ConfirmResetPasswordScreen debe mostrar los campos de contraseña', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ConfirmResetPasswordScreen(userId: 'user123', secret: 'secretABC'),
    ));
    
    // Dejamos que las animaciones de FadeIn terminen
    await tester.pumpAndSettle();

    expect(find.text('Nueva Contraseña'), findsOneWidget);
    expect(find.byType(CustomInputTextWidget), findsNWidgets(2));
    expect(find.text('GUARDAR CAMBIOS'), findsOneWidget);
  });

  testWidgets('Debe validar que las contraseñas coincidan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ConfirmResetPasswordScreen(userId: 'user123', secret: 'secretABC'),
      ),
    ));
    
    await tester.pumpAndSettle();

    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), 'password123');
    await tester.enterText(inputs.at(1), 'password456');
    
    // Aseguramos que el botón sea visible antes de pulsar (por el scroll)
    final button = find.text('GUARDAR CAMBIOS');
    await tester.ensureVisible(button);
    await tester.tap(button);
    
    // Esperamos a que aparezca el SnackBar
    await tester.pumpAndSettle();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets('Debe validar longitud mínima de contraseña', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ConfirmResetPasswordScreen(userId: 'user123', secret: 'secretABC'),
      ),
    ));
    
    await tester.pumpAndSettle();

    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), '123');
    await tester.enterText(inputs.at(1), '123');
    
    final button = find.text('GUARDAR CAMBIOS');
    await tester.ensureVisible(button);
    await tester.tap(button);

    await tester.pumpAndSettle();

    expect(find.text('La contraseña debe tener al menos 8 caracteres'), findsOneWidget);
  });
}
