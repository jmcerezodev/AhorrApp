import 'package:ahorrapp/presentation/widgets/dialogs/drawer_dialogs/sing_out_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      await tester.pumpAndSettle();

      // El widget usa dialogHeader con title: '¿Cerrar Sesión?' -> '¿CERRAR SESIÓN?'
      expect(find.text('¿CERRAR SESIÓN?'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('Debe mostrar el mensaje de confirmación', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ajuste para detectar texto con saltos de línea
      expect(
        find.textContaining('¿Estás seguro de que quieres salir', findRichText: true), 
        findsOneWidget
      );
    });

    testWidgets('Debe mostrar los botones de cancelar y salir con colores correctos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final cancelBtn = find.text('CANCELAR');
      final logoutBtn = find.text('SALIR');
      
      expect(cancelBtn, findsOneWidget);
      expect(logoutBtn, findsOneWidget);

      await tester.ensureVisible(logoutBtn);

      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(of: logoutBtn, matching: find.byType(ElevatedButton))
      );
      expect(elevatedButton.style?.backgroundColor?.resolve({}), Colors.red.shade400);
    });
  });
}
