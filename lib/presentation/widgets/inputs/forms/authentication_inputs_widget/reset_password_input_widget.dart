import 'package:ahorrapp/core/config/responsive_utils.dart';
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
            barrierDismissible: false,
            builder: (context) => const SuccessfulDialog(
              sucessfulName: 'Correo de recuperación enviado',
              routeScreen: '/login',
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
            SizedBox(height: 10.h),
            Text(
              'RECUPERACIÓN',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 3.0,
              ),
            ),
            SizedBox(height: 25.h),
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
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton.icon(
                onPressed: widget.cubit.state.status == ResetPasswordStatus.submitting
                    ? null
                    : () => widget.cubit.onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                ),
                icon: widget.cubit.state.status == ResetPasswordStatus.submitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.key_rounded, size: 20.sp),
                label: Text('RECUPERAR',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.2)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
