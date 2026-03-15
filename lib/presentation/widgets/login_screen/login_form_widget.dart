import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _formSubmitted = false;

  void isPasswordVisible(BuildContext context) {
    context.read<LoginCubit>().isPasswordVisible();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginCubit = context.read<LoginCubit>();
      loginCubit.resetCubit();
      if (Preferences.isRemember) {
        emailController.text = Preferences.email;
        passwordController.text = Preferences.password;
        loginCubit.emailChanged(Preferences.email);
        loginCubit.passwordChanged(Preferences.password);
        loginCubit.isRememberChanged(true);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.watch<LoginCubit>();
    
    return BlocListener<LoginCubit, LoginCubitState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          context.go('/home-screen');
        } else if (state.status == LoginStatus.failure) {
          if (state.errorMessage != 'Formulario no válido') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AuthErrorDialog(
                errorTitle: '!Se ha producido un error!',
                errorText: state.errorMessage ?? 'Credenciales inválidas.',
              ),
            );
          }
        }
      },
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Text(
              'ACCESO',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 3.0,
              ),
            ),
            SizedBox(height: 25.h),

            CustomInputTextWidget(
              controller: emailController,
              prefixIcon: Icons.email_outlined,
              label: 'Correo Electrónico',
              onChanged: loginCubit.emailChanged,
              errorText: _formSubmitted ? loginCubit.state.email.errorMessage : null,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),

            SizedBox(height: 20.h),

            CustomInputTextWidget(
              controller: passwordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: (loginCubit.state.passwordEncripted == false) 
                ? Icons.visibility_outlined 
                : Icons.visibility_off_outlined,
              onPressedSuffixIcon: () => isPasswordVisible(context),
              label: 'Contraseña',
              obscureText: loginCubit.state.passwordEncripted,
              autoFocus: false,
              onChanged: loginCubit.passwordChanged,
              errorText: _formSubmitted ? loginCubit.state.password.errorMessage : null,
              textCapitalization: TextCapitalization.none,
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Recordarme', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
              value: loginCubit.state.isRemember,
              onChanged: (value) {
                final newValue = value ?? false;
                loginCubit.isRememberChanged(newValue);
                Preferences.isRemember = newValue;
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.orange,
            ),

            SizedBox(height: 15.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton.icon(
                onPressed: (loginCubit.state.status == LoginStatus.submitting)
                  ? null 
                  : () async {
                      FocusScope.of(context).unfocus();
                      setState(() => _formSubmitted = true);

                      if (Preferences.isBiometricActive) {
                        final biometricService = BiometricService();
                        final bool authenticated = await biometricService.authenticate();
                        if (!authenticated) return;
                      }

                      loginCubit.onSubmit();
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                ),
                icon: loginCubit.state.status == LoginStatus.submitting
                  ? SizedBox(
                      width: 20.w, 
                      height: 20.w, 
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : Icon(Icons.login_rounded, size: 20.sp),
                label: Text(
                  loginCubit.state.status == LoginStatus.submitting ? 'CONECTANDO...' : 'ENTRAR',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.2)
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15.w,
              runSpacing: 10.h,
              children: [
                TextButton(
                  onPressed: () => context.push('/new-user'),
                  child: Text(
                    'Crear Nueva Cuenta',
                    style: TextStyle(color: Colors.orange, fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/reset-password'),
                  child: Text(
                    '¿Olvidaste la contraseña?',
                    style: TextStyle(
                      color: Colors.blueGrey.withValues(alpha: 0.6), 
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
