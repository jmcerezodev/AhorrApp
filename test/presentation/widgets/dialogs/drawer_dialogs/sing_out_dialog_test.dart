import 'package:ahorrapp/presentation/widgets/dialogs/drawer_dialogs/sing_out_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: SingOutDialog(),
      ),
    );
  }

  group('SingOutDialog - Pruebas de Interfaz', () {
    testWidgets('Debe mostrar el título y el icono de cerrar sesión', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('¿CERRAR SESIÓN?'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('Debe mostrar el mensaje de confirmación', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('¿Estás seguro de que quieres salir?'), findsOneWidget);
    });

    testWidgets('Debe mostrar los botones de cancelar y salir con colores correctos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('CANCELAR'), findsOneWidget);
      expect(find.text('SALIR'), findsOneWidget);

      // Verificamos el color rojo del botón de salida
      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('SALIR'), matching: find.byType(ElevatedButton))
      );
      expect(elevatedButton.style?.backgroundColor?.resolve({}), Colors.red.shade400);
    });
  });
}
