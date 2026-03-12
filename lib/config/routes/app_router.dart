import 'package:ahorrapp/presentation/screens/screens.dart';
import 'package:ahorrapp/presentation/screens/authentication/confirm_reset_password_screen.dart';
import 'package:ahorrapp/presentation/screens/main_navigator_screen.dart';
import 'package:ahorrapp/presentation/screens/privacy_policy_screen.dart';
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
      GoRoute(
        path: '/reset-password-confirm',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? '';
          final secret = state.uri.queryParameters['secret'] ?? '';
          return ConfirmResetPasswordScreen(userId: userId, secret: secret);
        },
      ),
      // Cambiamos /home-screen para que use el nuevo MainNavigatorScreen
      GoRoute(
        path: '/home-screen',
        builder: (context, state) => const MainNavigatorScreen(),
      ),
      GoRoute(
        path: '/licenses',
        builder: (context, state) => const LicensesScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}
