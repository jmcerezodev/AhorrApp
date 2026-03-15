import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

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
    Responsive.init(context);

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
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: Responsive.screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        FadeInDown(
                          child: Image.asset(
                            'assets/imagen_login.png', 
                            height: 12.hp,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        FadeInLeft(
                          child: Text(
                            'Nueva Contraseña',
                            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        FadeInLeft(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            'Introduce tu nueva clave de acceso para finalizar la recuperación.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey.shade400),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        
                        FadeInUp(
                          child: Container(
                            padding: EdgeInsets.all(25.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05), 
                                  blurRadius: 20, 
                                  offset: const Offset(0, 10)
                                )
                              ],
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
                                SizedBox(height: 20.h),
                                CustomInputTextWidget(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar contraseña',
                                  obscureText: true,
                                  prefixIcon: Icons.lock_reset_rounded,
                                ),
                                SizedBox(height: 30.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55.h,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _onSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                                    ),
                                    child: _isLoading 
                                      ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, letterSpacing: 1)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
