import 'package:ahorrapp/core/config/app_input_styles.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordInputWidget extends StatefulWidget {
  final ResetPasswordCubit cubit;
  const ResetPasswordInputWidget({super.key, required this.cubit});

  @override
  State<ResetPasswordInputWidget> createState() => _ResetPasswordInputWidgetState();
}

class _ResetPasswordInputWidgetState extends State<ResetPasswordInputWidget> {
  final TextEditingController emailController = TextEditingController();
  bool _formSubmitted = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordCubit = widget.cubit;
    final emailState = resetPasswordCubit.state.resetPassword;

    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      bloc: resetPasswordCubit,
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se ha enviado un correo para restablecer tu contraseña.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state.status == ResetPasswordStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error al enviar el correo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Text(
              'RECUPERAR CONTRASEÑA',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'Introduce tu correo electrónico para recibir las instrucciones de recuperación.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blueGrey.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            SizedBox(height: 30.h),

            TextFormField(
              controller: emailController,
              onChanged: resetPasswordCubit.emailChanged,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autofocus: true,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              decoration: AppInputStyles.decoration(
                labelText: 'Correo Electrónico',
                hintText: 'tu@correo.com',
                prefixIcon: Icons.email_outlined,
                errorText: _formSubmitted ? emailState.errorMessage : null,
              ),
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton.icon(
                onPressed: resetPasswordCubit.state.status == ResetPasswordStatus.submitting
                  ? null
                  : () {
                      setState(() => _formSubmitted = true);
                      resetPasswordCubit.onSubmit();
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                ),
                icon: resetPasswordCubit.state.status == ResetPasswordStatus.submitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : Icon(Icons.send_rounded, size: 20.sp),
                label: Text(
                  'ENVIAR INSTRUCCIONES',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.2)
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Volver al Acceso',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
