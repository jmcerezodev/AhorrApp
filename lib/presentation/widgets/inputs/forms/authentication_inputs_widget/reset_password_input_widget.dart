import 'package:ahorrapp/presentation/bloc/authentication_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/authenticacion_dialogs/reset_password_dialog.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';

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
    final emailCubit = widget.cubit.state.resetPassword;

    return Form(
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

          //* Correo Electronico
          CustomInputTextWidget(
            prefixIcon: Icons.email_outlined,
            label: 'Correo Electrónico',
            hintText: 'usuario@correo.com',
            onChanged: widget.cubit.emailChanged,
            errorText: emailCubit.errorMessage,
            autoFocus: false,
            textInputType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
          ),
          
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                widget.cubit.onSubmit();

                if(widget.cubit.state.isValid == true){
                   showDialog(
                    context: context, 
                    builder: (context) => const ResetPasswordDialog(
                      errorTitle: 'Correo Enviado', 
                      errorText: 'Se ha enviado un correo para recuperar la contraseña si no esta en tu bandeja de entrada revisa la carpeta de correo no deseado o spam.',
                    ),
                  );
                 }
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.key_rounded),
              label: const Text(
                'RECUPERAR', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
