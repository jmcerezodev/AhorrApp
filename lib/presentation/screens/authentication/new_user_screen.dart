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

    return Scaffold(
      backgroundColor: Colors.white,
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

                SizedBox(height: size.height * 0.05),
          
                Image.asset('assets/imagen_login.png', scale: 0.5,),

                SizedBox(height: size.height * 0.05),
                
                const UserInputWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

