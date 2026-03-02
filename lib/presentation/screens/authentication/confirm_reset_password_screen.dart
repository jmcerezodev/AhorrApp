import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/error_dialog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmResetPasswordScreen extends StatefulWidget {
  final String userId;
  final String secret;

  const ConfirmResetPasswordScreen({
    super.key, 
    required this.userId, 
    required this.secret
  });

  @override
  State<ConfirmResetPasswordScreen> createState() => _ConfirmResetPasswordScreenState();
}

class _ConfirmResetPasswordScreenState extends State<ConfirmResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres'))
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'))
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthAppwrite();
    final success = await authService.confirmResetPassword(
      userId: widget.userId,
      secret: widget.secret,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const SuccessfulDialog(
          sucessfulName: 'Contraseña restablecida',
          routeScreen: '/login',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          errorMessage: 'El enlace ha expirado o es inválido.\nPor favor, solicita uno nuevo.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, primary: Colors.orange),
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  FadeInDown(
                    child: Image.asset('assets/imagen_login.png', height: size.height * 0.12),
                  ),
                  const SizedBox(height: 30),
                  FadeInLeft(
                    child: const Text(
                      'Nueva Contraseña',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Introduce tu nueva clave de acceso para finalizar la recuperación.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  FadeInUp(
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          CustomInputTextWidget(
                            controller: _passwordController,
                            label: 'Contraseña nueva',
                            obscureText: !_isPasswordVisible,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            onPressedSuffixIcon: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          const SizedBox(height: 20),
                          CustomInputTextWidget(
                            controller: _confirmPasswordController,
                            label: 'Confirmar contraseña',
                            obscureText: true,
                            prefixIcon: Icons.lock_reset_rounded,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
