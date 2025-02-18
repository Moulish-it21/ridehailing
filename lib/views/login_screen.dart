import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/views/otp_verification_screen.dart';
import 'package:taxi/widgets/intro.dart';
import 'package:taxi/widgets/login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final countrypicker = const FlCountryCodePicker();

  CountryCode countryCode = const CountryCode(name: 'India', code: 'IN', dialCode: '+91');

  onSubmit(String? input){
    Get.to(()=>OtpVerificationScreen(countryCode.dialCode+input!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            greenIntroWidget(),

            const SizedBox(height: 50,),

            loginWidget(countryCode, ()async{
              final code = await countrypicker.showPicker(context: context);
              if (code != null) countryCode = code;
              setState(() {});
            },onSubmit)
          ],
        ),
      ),
    );
  }
}
