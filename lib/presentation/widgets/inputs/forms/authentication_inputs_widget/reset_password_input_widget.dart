import 'package:ahorrapp/presentation/bloc/authenticaction_cubits/reset_password_cubit/reset_password_cubit.dart';
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

    final size = MediaQuery.of(context).size;
    final emailCubit = widget.cubit.state.resetPassword;

    return Form(
      child: Column(
        children: [

          SizedBox(height: size.height * 0.02),

          const Text('Recuperacion de contraseña', style: TextStyle(fontWeight: FontWeight.bold),),

          SizedBox(height: size.height * 0.02),

          //* Correo Electronico
          CustomInputTextWidget(
            prefixIcon: Icons.email,
            label: 'Correo Electronico',
            hintText: 'usuario@correo.com',
            onChanged: widget.cubit.emailChanged,
            errorText: emailCubit.errorMessage,
            autoFocus: false,
            textInputType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
          ),
          
          SizedBox(height: size.height * 0.02),

          SizedBox(height: size.height * 0.03),

          FilledButton.tonalIcon(
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
            icon: const Icon(Icons.key),
            label: const Text('Recuperar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          SizedBox(height: size.height * 0.03),

        ],
      ),
    );
  }
}
