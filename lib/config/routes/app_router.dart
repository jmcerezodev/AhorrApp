import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


appRouter(String value){

  return GoRouter(
  initialLocation: value,
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
        // Recibe la versión de la aplicación desde el state.extra
        final String appVersion = state.extra as String? ?? 'Versión desconocida';
        return LicensePage(
          applicationName: 'AhorrApp',
          applicationVersion: appVersion,
          applicationLegalese: '© $currentYear JMCerezoDev',
        );
      },
    ),

  ]
);
}  