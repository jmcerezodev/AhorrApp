import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/bloc/authenticaction_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/inputs/forms/authentication_inputs_widget/reset_password_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final yearNow = Date().year();

    final size = MediaQuery.of(context).size;
    final resetPasswordCubit = context.watch<ResetPasswordCubit>();

    return Scaffold(
      appBar: AppBar(),
      bottomSheet: Container(
        alignment: Alignment.bottomCenter,
        color: Colors.white,
        width: double.infinity,
        height: 35,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('JMCerezoDev - $yearNow ®'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: ListView(
              children: [
          
                SizedBox(height: size.height * 0.10),
          
                const FlutterLogo(size: 200,),

                SizedBox(height: size.height * 0.05),

                ResetPasswordInputWidget(cubit: resetPasswordCubit),
                
                //SizedBox(height: size.height * 0.05),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}