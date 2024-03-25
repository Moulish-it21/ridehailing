import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:taxi/controller/authController.dart';
import 'package:taxi/utils/app_colors.dart';

import '../widgets/intro.dart';
import '../widgets/otp_verification_widget.dart';

class OtpVerificationScreen extends StatefulWidget {

  String phonenumber;
  OtpVerificationScreen(this.phonenumber);


  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {

  AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.phoneAuth(widget.phonenumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                greenIntroWidget(),

                Positioned(
                  top: 60,
                  left: 30,
                  child: InkWell(
                    onTap: (){
                      Get.back();
                    },
                    child: Container(
                      width: 55,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(Icons.arrow_back,color: AppColors.greenColor,size: 20,),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),

            otpVerificationWidget(),
          ],
        ),
      ),
    );
  }
}
