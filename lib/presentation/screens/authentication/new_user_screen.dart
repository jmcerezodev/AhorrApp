import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/widgets/new_user_screen/new_user_form_widget.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class NewUserScreen extends StatelessWidget {
  const NewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String yearNow = Date().year();
    final size = MediaQuery.of(context).size;

    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, primary: Colors.orange),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.orange),
        ),
        bottomSheet: Container(
          alignment: Alignment.bottomCenter,
          color: Colors.white,
          width: double.infinity,
          height: 35,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'JMCerezoDev - $yearNow ®',
              style: TextStyle(color: Colors.blueGrey.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(height: size.height * 0.02),
                  Image.asset('assets/imagen_login.png', height: 100, fit: BoxFit.contain),
                  SizedBox(height: size.height * 0.05),
                  const UserInputWidget(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
