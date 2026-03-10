import 'package:ahorrapp/config/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GoRouter debe reconocer la ruta de confirmación y sus parámetros', (WidgetTester tester) async {
    const userId = 'user123';
    const secret = 'secretabc';
    final initialLocation = '/reset-password-confirm?userId=$userId&secret=$secret';
    
    final router = getAppRouter(initialLocation);

    // Al usar MaterialApp.router, obligamos a GoRouter a inicializarse correctamente
    // dentro del ciclo de vida de Flutter.
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Esperamos a que las microtareas de navegación se completen
    await tester.pumpAndSettle();

    // Verificamos la URI a través del delegate, que es el estado real tras la navegación
    final uri = router.routerDelegate.currentConfiguration.uri;
    
    expect(uri.path, '/reset-password-confirm');
    expect(uri.queryParameters['userId'], userId);
    expect(uri.queryParameters['secret'], secret);
  });
}
