import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/widgets/login_screen/login_form_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final String yearNow = Date().year();

    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, primary: Colors.blueGrey),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: Responsive.screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Parte superior: Logo y Frase Motivadora
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.h),
                              FadeInDown(
                                duration: const Duration(milliseconds: 800),
                                child: Image.asset(
                                  'assets/imagen_login.png',
                                  height: 13.hp,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              FadeInLeft(
                                delay: const Duration(milliseconds: 400),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      color: Colors.blueGrey.shade900,
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
                                          fontSize: 15.sp,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),

                        // Parte central: Tarjeta del Formulario
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w, 
                              vertical: 20.h
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.w),
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
                                padding: EdgeInsets.only(bottom: 15.h, top: 20.h),
                                child: Text(
                                  'JMCerezoDev - $yearNow ®',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 10.sp,
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
            ),
          ),
        ),
      ),
    );
  }
}
