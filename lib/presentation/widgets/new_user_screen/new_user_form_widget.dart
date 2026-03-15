import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserInputWidget extends StatefulWidget {
  const UserInputWidget({super.key});

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  
  void isPasswordVisible(BuildContext context) {
    context.read<NewUserCubit>().isPasswordVisible();
  }

  @override
  Widget build(BuildContext context) {
    final newUserCubit = context.watch<NewUserCubit>();
    final nameCubit = newUserCubit.state.name;
    final emailCubit = newUserCubit.state.email;
    final passwordCubit = newUserCubit.state.password;

    return BlocListener<NewUserCubit, NewUserCubitState>(
      listener: (context, state) {
        if (state.status == NewUserStatus.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const _SuccessAccountDialog(),
          );
        } else if (state.status == NewUserStatus.failure) {
          showDialog(
            context: context, 
            builder: (context) => AuthErrorDialog(
              errorTitle: '!Se ha producido un error!', 
              errorText: state.errorMessage ?? 'No se pudo crear la cuenta. Verifica tu conexión.',
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Text(
              'REGISTRO',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 3.0,
              ),
            ),
            SizedBox(height: 25.h),

            CustomInputTextWidget(
              prefixIcon: Icons.person_outline_rounded,
              label: 'Tu Nombre',
              hintText: 'Nombre',
              onChanged: newUserCubit.nameChanged,
              errorText: nameCubit.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            SizedBox(height: 20.h),

            CustomInputTextWidget(
              prefixIcon: Icons.email_outlined,
              label: 'Correo Electronico',
              hintText: 'tucorreo@correo.com',
              onChanged:  newUserCubit.emailChanged,
              errorText: emailCubit.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            
            SizedBox(height: 20.h),

            CustomInputTextWidget(
              prefixIcon: Icons.key_outlined,
              suffixIcon: (newUserCubit.state.passwordEncripted == false) 
              ? Icons.visibility_outlined 
              : Icons.visibility_off_outlined,
              onPressedSuffixIcon: () => isPasswordVisible(context),
              label: 'Contraseña',
              obscureText: newUserCubit.state.passwordEncripted,
              autoFocus: false,
              onChanged: newUserCubit.passwordChanged,
              errorText: passwordCubit.errorMessage,
              textCapitalization: TextCapitalization.none,
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton.icon(
                onPressed: newUserCubit.state.status == NewUserStatus.submitting
                  ? null
                  : () => newUserCubit.onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                ),
                icon: newUserCubit.state.status == NewUserStatus.submitting
                  ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.person_add_rounded, size: 20.sp),
                label: Text(
                  'CREAR CUENTA', 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.2)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessAccountDialog extends StatelessWidget {
  const _SuccessAccountDialog();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(25.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.w),
            border: Border.all(color: Colors.green.shade100, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade400, size: 50.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                '¡CUENTA CREADA!',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black87),
              ),
              SizedBox(height: 10.h),
              Text(
                'Tu cuenta ha sido configurada con éxito. ¡Ya puedes empezar a ahorrar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.5),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home-screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                  ),
                  child: Text('EMPEZAR AHORA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
