import 'package:ahorrapp/config/routes/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GoRouter debe reconocer la ruta de confirmación y sus parámetros', () {
    const userId = 'user123';
    const secret = 'secretabc';
    final router = getAppRouter('/reset-password-confirm?userId=$userId&secret=$secret');

    // En GoRouter, la información de la ruta inicial se encuentra en el routeInformationProvider
    final uri = router.routeInformationProvider.value.uri;
    
    expect(uri.path, '/reset-password-confirm');
    expect(uri.queryParameters['userId'], userId);
    expect(uri.queryParameters['secret'], secret);
  });
}
