import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/views/Drivers/car_registration/car_registration_template.dart';

import '../../controller/authController.dart';
import '../../widgets/DecisionButton.dart';
import '../../widgets/intro.dart';
import '../login_screen.dart';

class DecisionScreen extends StatelessWidget {
  DecisionScreen({super.key});

  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            greenIntroWidget(),

            const SizedBox(height: 50,),

            DecisionButton(
                'assets/driver.png',
                'Login As Driver',
                    (){
                  //authController.isLoginAsDriver = true;
                  //Get.to(()=> LoginScreen());
                      Get.to(()=>CarRegistrationTemplate());
                },
                Get.width*0.8
            ),

            const SizedBox(height: 20,),
            DecisionButton(
                'assets/customer.png',
                'Login As User',
                    (){
                  authController.isLoginAsDriver = false;
                  Get.to(()=> LoginScreen());




                },
                Get.width*0.8
            ),
          ],
        ),
      ),
    );
  }
}