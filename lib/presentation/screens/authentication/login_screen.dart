import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/widgets/login_screen/login_form_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String yearNow = Date().year();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Parte superior: Logo y Frase Motivadora
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Image.asset(
                          'assets/imagen_login.png',
                          height: size.height * 0.13,
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
                              fontSize: 24,
                              color: Colors.blueGrey.shade900,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Domina tus ',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              TextSpan(
                                text: 'finanzas\n',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'conquista tus metas',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Parte central: Formulario con Borde Anaranjado
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      // Borde anaranjado para resaltar la tarjeta
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
                    child: const LoginFormWidget(),
                  ),
                ),

                // Parte inferior: Copyright
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FadeIn(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
