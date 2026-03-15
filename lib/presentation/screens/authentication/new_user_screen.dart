import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class NewUserScreen extends StatelessWidget {
  const NewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final String yearNow = Date().year();

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
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  children: [
                    // Parte superior: Logo y Título
                    SizedBox(height: 10.h),
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Image.asset(
                        'assets/imagen_login.png',
                        height: 10.hp,
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
                            fontSize: 22.sp,
                            color: Colors.blueGrey.shade900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Únete a ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            const TextSpan(
                              text: 'nosotros\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'empieza a ahorrar hoy mismo',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Parte central: Tarjeta del Formulario
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
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
                        child: const UserInputWidget(),
                      ),
                    ),

                    // Parte inferior: Copyright
                    SizedBox(height: 40.h),
                    FadeIn(
                      delay: const Duration(milliseconds: 1000),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 15.h),
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
