import 'package:ahorrapp/presentation/bloc/authentication_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordInputWidget extends StatefulWidget {
  final ResetPasswordCubit cubit;

  const ResetPasswordInputWidget({
    super.key,
    required this.cubit,
  });

  @override
  State<ResetPasswordInputWidget> createState() => _ResetPasswordInputWidgetState();
}

class _ResetPasswordInputWidgetState extends State<ResetPasswordInputWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      bloc: widget.cubit,
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.success) {
          showDialog(
            context: context,
            builder: (context) => const ResetPasswordDialog(
              errorTitle: 'Correo Enviado',
              errorText:
                  'Se ha enviado un correo para recuperar la contraseña. Revisa tu bandeja de entrada y spam.',
            ),
          );
        } else if (state.status == ResetPasswordStatus.failure) {
          showDialog(
            context: context,
            builder: (context) => AuthErrorDialog(
              errorTitle: '!Error al enviar!',
              errorText: state.errorMessage ?? 'No se pudo procesar la solicitud.',
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'RECUPERACIÓN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 25),
            CustomInputTextWidget(
              prefixIcon: Icons.email_outlined,
              label: 'Correo Electrónico',
              hintText: 'usuario@correo.com',
              onChanged: widget.cubit.emailChanged,
              errorText: widget.cubit.state.resetPassword.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: widget.cubit.state.status == ResetPasswordStatus.submitting
                    ? null
                    : () => widget.cubit.onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: widget.cubit.state.status == ResetPasswordStatus.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.key_rounded),
                label: const Text('RECUPERAR',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
