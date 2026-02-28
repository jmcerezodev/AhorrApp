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
      listenWhen: (previous, current) => previous.formStatus != current.formStatus,
      listener: (context, state) {
        if (state.formStatus == FormStatusLogin.valid) {
          context.go('/home-screen');
        } else if (state.formStatus == FormStatusLogin.invalid) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AuthErrorDialog(
              errorTitle: '!Se ha producido un error!',
              errorText: 'Credenciales inválidas o problema de conexión.',
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Título interno estilizado
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
              activeColor: Colors.blueGrey,
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.tonalIcon(
                onPressed: (loginCubit.state.formStatus == FormStatusLogin.validating)
                  ? null 
                  : () {
                      FocusScope.of(context).unfocus();
                      loginCubit.onSubmit();
                    },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: loginCubit.state.formStatus == FormStatusLogin.validating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueGrey))
                  : const Icon(Icons.login_rounded),
                label: Text(
                  loginCubit.state.formStatus == FormStatusLogin.validating ? 'CONECTANDO...' : 'ENTRAR',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.2)
                ),
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              children: [
                TextButton(
                  onPressed: () => context.push('/new-user'),
                  child: const Text(
                    'Crear Nueva Cuenta',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/reset-password'),
                  child: const Text(
                    '¿Olvidaste la contraseña?',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w600),
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
