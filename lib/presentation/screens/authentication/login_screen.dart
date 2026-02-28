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

    // FORZAMOS TEMA CLARO PARA ESTA PANTALLA
    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, primary: Colors.orange),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBF5), // Naranja Crema Original
        resizeToAvoidBottomInset: true,
        body: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return SingleChildScrollView(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBF5),
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
                              FadeInDown(
                                duration: const Duration(milliseconds: 800),
                                child: Image.asset(
                                  'assets/imagen_login.png',
                                  height: size.height * 0.13,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 25),
                              FadeInLeft(
                                delay: const Duration(milliseconds: 400),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.blueGrey,
                                      height: 1.2,
                                      letterSpacing: -0.5,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Domina tus ',
                                        style: TextStyle(fontWeight: FontWeight.w300),
                                      ),
                                      const TextSpan(
                                        text: 'finanzas\n',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: 'conquista tus metas',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey.withValues(alpha: 0.5),
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

                        // Parte central: Tarjeta del Formulario
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.orange.shade300.withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.shade100.withValues(alpha: 0.05),
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
                                    color: Colors.blueGrey.withValues(alpha: 0.3),
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
        ),
      ),
    );
  }
}
