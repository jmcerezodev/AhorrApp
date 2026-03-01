import 'package:ahorrapp/core/auth/biometric_service.dart';
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
      // 1. Actualizado para usar LoginStatus
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          context.go('/home-screen');
        } else if (state.status == LoginStatus.failure) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AuthErrorDialog(
              errorTitle: '!Se ha producido un error!',
              // 2. Ahora mostramos el mensaje real que devuelve el Cubit
              errorText: state.errorMessage ?? 'Credenciales inválidas o problema de conexión.',
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            Text(
              'ACCESO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 3.0,
              ),
            ),
            
            const SizedBox(height: 25),

            CustomInputTextWidget(
              controller: emailController,
              prefixIcon: Icons.email_outlined,
              label: 'Correo Electrónico',
              onChanged: loginCubit.emailChanged,
              errorText: loginCubit.state.email.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),

            const SizedBox(height: 20),

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
              errorText: loginCubit.state.password.errorMessage,
              textCapitalization: TextCapitalization.none,
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordarme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              value: loginCubit.state.isRemember,
              onChanged: (value) {
                final newValue = value ?? false;
                loginCubit.isRememberChanged(newValue);
                Preferences.isRemember = newValue;
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.orange,
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                // 3. Gestión de estados de carga con LoginStatus
                onPressed: (loginCubit.state.status == LoginStatus.submitting)
                  ? null 
                  : () async {
                      FocusScope.of(context).unfocus();
                      
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: loginCubit.state.status == LoginStatus.submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.login_rounded),
                label: Text(
                  loginCubit.state.status == LoginStatus.submitting ? 'CONECTANDO...' : 'ENTRAR',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)
                ),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              children: [
                TextButton(
                  onPressed: () => context.push('/new-user'),
                  child: const Text(
                    'Crear Nueva Cuenta',
                    style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/reset-password'),
                  child: Text(
                    '¿Olvidaste la contraseña?',
                    style: TextStyle(color: Colors.blueGrey.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600),
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
