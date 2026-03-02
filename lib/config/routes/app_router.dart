import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/screens/screens.dart';
import 'package:ahorrapp/presentation/screens/authentication/confirm_reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter getAppRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/new-user',
        builder: (context, state) => const NewUserScreen(),
      ), 
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      // NUEVA RUTA PARA DEEP LINKING
      GoRoute(
        path: '/reset-password-confirm',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? '';
          final secret = state.uri.queryParameters['secret'] ?? '';
          return ConfirmResetPasswordScreen(userId: userId, secret: secret);
        },
      ),
      GoRoute(
        path: '/home-screen',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/licenses',
        builder: (context, state) {
          final String currentYear = Date().year().toString();
          final String appVersion = state.extra as String? ?? '1.0.0';
          return LicensePage(
            applicationName: 'AhorrApp',
            applicationVersion: appVersion,
            applicationLegalese: '© $currentYear JMCerezoDev',
          );
        },
      ),
    ],
  );
}
