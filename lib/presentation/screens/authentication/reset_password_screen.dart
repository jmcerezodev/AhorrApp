import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/bloc/authenticaction_cubits/reset_password_cubit/reset_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/inputs/forms/authentication_inputs_widget/reset_password_input_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String yearNow = Date().year();
    final size = MediaQuery.of(context).size;
    final resetPasswordCubit = context.watch<ResetPasswordCubit>();

    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, primary: Colors.orange),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.blueGrey,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Parte superior: Logo y Título
                    const SizedBox(height: 10),
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Image.asset(
                        'assets/imagen_login.png',
                        height: size.height * 0.10,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 400),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey.shade900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Recupera tu ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            TextSpan(
                              text: 'cuenta\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'te ayudamos a volver a entrar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Parte central: Tarjeta del Formulario
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.orange.shade300.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade100.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ResetPasswordInputWidget(cubit: resetPasswordCubit),
                      ),
                    ),

                    // Parte inferior: Copyright
                    const SizedBox(height: 40),
                    FadeIn(
                      delay: const Duration(milliseconds: 1000),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          'JMCerezoDev - $yearNow ®',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
