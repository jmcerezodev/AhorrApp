import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Cambiamos a una función que genera el router una sola vez o lo mantiene
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
